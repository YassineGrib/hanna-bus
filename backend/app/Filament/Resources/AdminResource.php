<?php

namespace App\Filament\Resources;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\Filter;
use Illuminate\Auth\Access\Response;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

abstract class AdminResource extends Resource
{
    protected const LABEL = '';

    protected const READ_ONLY = false;

    /** Translation key (under `admin.`) of the sidebar group; empty means no group. */
    protected const GROUP = '';

    /** Heroicon outlined name without the `o-` prefix, for example `truck`. */
    protected const ICON = '';

    protected const SORT = 0;

    public static function getNavigationGroup(): ?string
    {
        return static::GROUP === '' ? null : __('admin.'.static::GROUP);
    }

    public static function getNavigationIcon(): ?Heroicon
    {
        return static::ICON === '' ? null : Heroicon::from('o-'.static::ICON);
    }

    public static function getNavigationSort(): ?int
    {
        return static::SORT;
    }

    /** Singular label (for titles such as "Create Bus"); falls back to the plural when no `_one` key exists. */
    public static function getModelLabel(): string
    {
        $singular = 'admin.'.static::LABEL.'_one';

        return trans()->has($singular) ? __($singular) : static::getPluralModelLabel();
    }

    public static function getPluralModelLabel(): string
    {
        return __('admin.'.static::LABEL);
    }

    public static function getAuthorizationResponse(string|UnitEnum $action, ?Model $record = null): Response
    {
        return auth()->user()?->role === 'admin' && (! static::READ_ONLY || in_array($action, ['viewAny', 'view'], true))
            ? Response::allow() : Response::deny();
    }

    public static function input(string $name, bool $required = true): TextInput
    {
        return TextInput::make($name)->label(__('admin.'.$name))->required($required)->maxLength(255);
    }

    public static function column(string $name, ?string $label = null): TextColumn
    {
        return TextColumn::make($name)->label(__('admin.'.($label ?? $name)))->searchable()->sortable();
    }

    public static function options(array $values): array
    {
        return array_combine($values, array_map(fn (string $value): string => __('admin.'.$value), $values));
    }

    public static function status(string $name = 'status'): TextColumn
    {
        return static::column($name)->badge()->formatStateUsing(fn (string $state): string => __('admin.'.$state))
            ->color(fn (string $state): string => match ($state) {
                'open','workshop','cancelled' => 'danger', 'en_route','in_service','on_bus' => 'warning',
                'completed','available','closed','at_school','at_home' => 'success', default => 'gray',
            });
    }

    public static function dateFilter(string $column): Filter
    {
        return Filter::make('service_date')->label(__('admin.date'))->schema([
            Select::make('period')->label(__('admin.date'))->options(static::options(['today', 'tomorrow', 'custom_date']))->default('today')->live(),
            DatePicker::make('date')->label(__('admin.date'))->default(today())->visible(fn (Get $get): bool => $get('period') === 'custom_date'),
        ])->query(function (Builder $query, array $data) use ($column): Builder {
            $date = match ($data['period'] ?? 'today') {
                'tomorrow' => today()->addDay()->toDateString(),
                'custom_date' => $data['date'] ?? today()->toDateString(),
                default => today()->toDateString(),
            };

            return $query->whereDate($column, $date);
        });
    }

    public static function userSelect(string $field, string $relationship, string $role): Select
    {
        return Select::make($field)->label(__('admin.'.$field))->relationship($relationship, 'name',
            fn (Builder $query): Builder => $query->where('role', $role))->searchable()->preload()->required();
    }
}
