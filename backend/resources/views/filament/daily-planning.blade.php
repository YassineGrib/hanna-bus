<x-filament-panels::page>
    <label style="display:flex;align-items:center;gap:.75rem;font-weight:600">
        {{ __('admin.date') }}
        <input
            type="date"
            wire:model.live="date"
            required
            style="padding:.4rem .7rem;border:1px solid rgba(128,128,128,.4);border-radius:.5rem;background:transparent;color:inherit"
        >
    </label>
    @error('date') <p style="color:#dc2626">{{ $message }}</p> @enderror
    {{ $this->table }}
    <x-filament::section :heading="__('admin.trips')">
        @if ($routeWarnings)
            <div
                role="alert"
                style="display:flex;gap:.75rem;align-items:flex-start;padding:.85rem 1rem;margin-bottom:1rem;border:1px solid rgba(217,119,6,.45);background:rgba(245,158,11,.12);border-radius:.75rem"
            >
                <x-filament::icon
                    icon="heroicon-o-exclamation-triangle"
                    style="width:1.35rem;height:1.35rem;flex-shrink:0;color:#d97706"
                />
                <div>
                    <p style="font-weight:600;margin-bottom:.25rem">{{ __('admin.missing_routes') }}</p>
                    <ul style="margin:0;padding-inline-start:1.1rem;list-style:disc">
                        @foreach ($routeWarnings as $warning)
                            <li>{{ $warning }}</li>
                        @endforeach
                    </ul>
                    <a
                        href="{{ \App\Filament\Resources\RouteResource::getUrl('index') }}"
                        style="display:inline-block;margin-top:.5rem;font-weight:600;color:#b45309;text-decoration:underline"
                    >
                        {{ __('admin.routes') }}
                    </a>
                </div>
            </div>
        @endif
        <div style="overflow-x:auto">
            <table style="width:100%;border-collapse:collapse;text-align:start">
                <thead>
                    <tr>
                        @foreach (['route_name', 'driver_id', 'bus_id', 'status', 'delay_minutes'] as $label)
                            <th style="padding:.6rem .9rem;font-weight:600;text-align:start;border-bottom:1px solid rgba(128,128,128,.3)">{{ __('admin.'.$label) }}</th>
                        @endforeach
                    </tr>
                </thead>
                <tbody>
                    @forelse ($trips as $trip)
                        <tr>
                            <td style="padding:.6rem .9rem;border-bottom:1px solid rgba(128,128,128,.15)">{{ $trip->route_name }}</td>
                            <td style="padding:.6rem .9rem;border-bottom:1px solid rgba(128,128,128,.15)">{{ $trip->driver?->name }}</td>
                            <td style="padding:.6rem .9rem;border-bottom:1px solid rgba(128,128,128,.15)">{{ $trip->bus?->number }}</td>
                            <td style="padding:.6rem .9rem;border-bottom:1px solid rgba(128,128,128,.15)">
                                <x-filament::badge :color="match ($trip->status) { 'en_route' => 'warning', 'completed' => 'success', default => 'gray' }">
                                    {{ __('admin.'.$trip->status) }}
                                </x-filament::badge>
                            </td>
                            <td style="padding:.6rem .9rem;border-bottom:1px solid rgba(128,128,128,.15)">{{ $trip->delay_minutes }}</td>
                        </tr>
                    @empty
                        <tr><td colspan="5" style="padding:.9rem;text-align:center;opacity:.7">{{ __('admin.no_trips') }}</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </x-filament::section>
</x-filament-panels::page>
