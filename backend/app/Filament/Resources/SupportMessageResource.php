<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SupportMessageResource\Pages;
use App\Models\SupportMessage;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Components\View;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class SupportMessageResource extends AdminResource
{
    protected static ?string $model = SupportMessage::class;

    protected static ?string $recordTitleAttribute = 'message';

    protected const LABEL = 'support_messages';

    protected const GROUP = 'nav_communication';

    protected const ICON = 'chat-bubble-left-right';

    protected const SORT = 2;

    protected const READ_ONLY = true;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with(['parent', 'driver', 'child'])
            ->whereIn('id', SupportMessage::query()->selectRaw('MAX(id)')->groupBy('parent_id', 'driver_id', 'recipient_type'))
            ->addSelect(['unread_count' => SupportMessage::query()->from('support_messages as thread')
                ->selectRaw('COUNT(*)')->whereColumn('thread.parent_id', 'support_messages.parent_id')
                ->whereColumn('thread.recipient_type', 'support_messages.recipient_type')
                ->whereRaw('(thread.driver_id = support_messages.driver_id OR (thread.driver_id IS NULL AND support_messages.driver_id IS NULL))')
                ->whereNull('thread.read_at')]);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([static::input('recipient_type'), static::input('direction'), Textarea::make('message')->label(__('admin.message')), View::make('filament.support-thread')->viewData(fn (SupportMessage $record): array => ['threadMessages' => $record->adminThread()])]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([static::column('parent.name', 'parent_id'), static::column('driver.name', 'driver_id'), static::column('child.full_name', 'students'), static::column('message')->limit(80), IconColumn::make('read_at')->label(__('admin.unread'))->state(fn (SupportMessage $record): bool => $record->unread_count > 0)->boolean(), static::column('created_at')->dateTime()])->filters([SelectFilter::make('parent_id')->label(__('admin.parent_id'))->relationship('parent', 'name'), SelectFilter::make('driver_id')->label(__('admin.driver_id'))->relationship('driver', 'name'), Filter::make('unread')->label(__('admin.unread'))->query(fn (Builder $query): Builder => $query->whereRaw('(SELECT COUNT(*) FROM support_messages AS unread_thread WHERE unread_thread.parent_id = support_messages.parent_id AND unread_thread.recipient_type = support_messages.recipient_type AND (unread_thread.driver_id = support_messages.driver_id OR (unread_thread.driver_id IS NULL AND support_messages.driver_id IS NULL)) AND unread_thread.read_at IS NULL) > 0'))])->recordActions([ViewAction::make()])->defaultSort('created_at', 'desc');
    }

    public static function getPages(): array
    {
        return ['index' => Pages\ListSupportMessages::route('/'), 'view' => Pages\ViewSupportMessage::route('/{record}')];
    }
}
