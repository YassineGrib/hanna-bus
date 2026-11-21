<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RouteResource\Pages;
use App\Models\Route;
use Filament\Actions\Action;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\TimePicker;
use Filament\Forms\Components\Toggle;
use Filament\Notifications\Notification;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class RouteResource extends AdminResource
{
    protected static ?string $model = Route::class;

    protected static ?string $recordTitleAttribute = 'name';

    protected const LABEL = 'routes';

    protected const GROUP = 'nav_fleet';

    protected const ICON = 'map-pin';

    protected const SORT = 2;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with('bus')->withCount('stations');
    }

    public static function coordinate(string $name, bool $required = false): TextInput
    {
        return TextInput::make($name)->label(__('admin.'.$name))->required($required)->numeric()
            ->minValue($name === 'lat' ? -90 : -180)
            ->maxValue($name === 'lat' ? 90 : 180);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('bus_id')->label(__('admin.bus_id'))->relationship('bus', 'number')
                ->searchable()->preload()->required()->live(),
            Select::make('period')->label(__('admin.period'))
                ->options(static::options(['morning', 'return']))->required()
                ->rules(fn (Get $get, ?Route $record): array => [
                    Rule::unique('routes', 'period')->where('bus_id', $get('bus_id'))->ignore($record?->id),
                ])->validationMessages(['unique' => __('admin.route_unique')]),
            static::input('name'),
            TimePicker::make('scheduled_start')->label(__('admin.scheduled_start'))->seconds(false),
            Toggle::make('is_active')->label(__('admin.is_active'))->default(true)->live(),
            Repeater::make('stations')->label(__('admin.stations'))->relationship()->orderColumn('sort_order')
                ->defaultItems(2)->minItems(fn (Get $get): int => $get('is_active') ? 2 : 0)
                ->validationMessages(['min' => __('admin.route_min_stations')])
                ->schema([
                    static::input('name_en'),
                    static::input('name_ar', false)->helperText(__('admin.translation_fallback')),
                    static::input('name_fr', false)->helperText(__('admin.translation_fallback')),
                    static::input('subtitle_en'),
                    static::input('subtitle_ar', false)->helperText(__('admin.translation_fallback')),
                    static::input('subtitle_fr', false)->helperText(__('admin.translation_fallback')),
                    static::input('scheduled_time'),
                    static::coordinate('lat')->helperText(__('admin.coordinates_help')),
                    static::coordinate('lng'),
                ])->columns(3)->columnSpanFull(),
            Section::make(__('admin.advanced_route_points'))->collapsible()->collapsed()->schema([
                Repeater::make('route_points_json')->label(__('admin.route_points_json'))
                    ->helperText(__('admin.route_points_help'))->defaultItems(0)
                    ->afterStateHydrated(function (Repeater $component, ?array $state): void {
                        $component->state(array_map(fn (array $point): array => [
                            'lat' => $point[0] ?? $point['lat'] ?? null,
                            'lng' => $point[1] ?? $point['lng'] ?? null,
                        ], $state ?? []));
                    })
                    ->dehydrateStateUsing(fn (?array $state): array => array_values(array_map(
                        fn (array $point): array => [(float) $point['lat'], (float) $point['lng']], $state ?? [],
                    )))
                    ->schema([static::coordinate('lat', true), static::coordinate('lng', true)])
                    ->columns(2),
            ])->columnSpanFull(),
        ]);
    }

    public static function duplicateAction(): Action
    {
        return Action::make('duplicateReturn')->label(__('admin.duplicate_return'))
            ->visible(fn (Route $record): bool => $record->period === 'morning')
            ->action(function (Route $record): void {
                abort_unless(static::canCreate(), 403);
                $copy = DB::transaction(function () use ($record): ?Route {
                    $record->bus()->lockForUpdate()->first();
                    if (Route::where('bus_id', $record->bus_id)->where('period', 'return')->exists()) {
                        return null;
                    }
                    $copy = $record->replicate(['stations_count']);
                    $copy->period = 'return';
                    $copy->name = __('admin.return_route_name', ['name' => $record->name]);
                    $copy->scheduled_start = null;
                    $copy->route_points_json = array_reverse($record->route_points_json ?? []);
                    $copy->is_active = $record->is_active && $record->stations()->count() >= 2;
                    $copy->save();
                    foreach ($record->stations()->get()->reverse()->values() as $index => $station) {
                        $copy->stations()->create([
                            ...$station->only(['name_en', 'name_ar', 'name_fr', 'subtitle_en', 'subtitle_ar',
                                'subtitle_fr', 'scheduled_time', 'lat', 'lng']),
                            'sort_order' => $index + 1,
                        ]);
                    }

                    return $copy;
                });
                $notification = Notification::make();
                if ($copy) {
                    $notification->title(__('admin.return_route_created'))->body(__('admin.return_route_review'))->success();
                } else {
                    $notification->title(__('admin.return_route_exists'))->warning();
                }
                $notification->send();
            });
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            static::column('bus.number', 'bus_id'),
            TextColumn::make('period')->label(__('admin.period'))->badge()
                ->formatStateUsing(fn (string $state): string => __('admin.'.$state)),
            static::column('name'),
            TextColumn::make('stations_count')->label(__('admin.stations_count'))->counts('stations'),
            ToggleColumn::make('is_active')->label(__('admin.is_active'))
                ->updateStateUsing(function (Route $record, bool $state): bool {
                    abort_unless(static::canEdit($record), 403);
                    if ($state && $record->stations()->count() < 2) {
                        Notification::make()->title(__('admin.route_min_stations'))->warning()->send();

                        return false;
                    }
                    $record->update(['is_active' => $state]);

                    return $state;
                }),
        ])->recordActions([EditAction::make(), static::duplicateAction(), DeleteAction::make()]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRoutes::route('/'),
            'create' => Pages\CreateRoute::route('/create'),
            'edit' => Pages\EditRoute::route('/{record}/edit'),
        ];
    }
}
