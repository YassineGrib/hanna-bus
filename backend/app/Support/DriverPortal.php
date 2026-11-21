<?php

namespace App\Support;

use App\Models\ActiveTrip;
use App\Models\BusAssignment;
use App\Models\Child;
use App\Models\SafetyNotification;
use App\Models\TripStation;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Http\Request;

class DriverPortal
{
    public static function trip(Request $request, string $id): ActiveTrip
    {
        return ActiveTrip::where('driver_id', $request->user()->id)->findOrFail($id);
    }

    public static function children(ActiveTrip $trip): Collection
    {
        return Child::with(['absenceReports' => fn ($q) => $q->whereDate('absence_date', today())])
            ->where('bus_number', $trip->bus_number)->get();
    }

    public static function absent(Child $child): bool
    {
        return $child->absenceReports->contains(fn ($a) => $a->absence_date->isToday());
    }

    public static function station(ActiveTrip $trip, Child $child): ?TripStation
    {
        // Existing children store a stop label, not a station FK. Compare the
        // normalized labels (the demo uses both comma and parenthesis forms).
        $normalize = fn (string $s) => preg_replace('/[^\pL\pN]/u', '', mb_strtolower($s));

        return $trip->stations->first(fn ($s) => in_array($normalize($child->stop_name), [
            $normalize($s->name_en), $normalize($s->name_ar), $normalize($s->name_fr),
        ], true));
    }

    public static function accessibleChildren(Request $request): Builder
    {
        $numbers = ActiveTrip::where('driver_id', $request->user()->id)->pluck('bus_number')
            ->merge(BusAssignment::with('bus')->where('driver_id', $request->user()->id)
                ->whereDate('date', today())
                ->get()->pluck('bus.number'))->filter()->unique();

        return Child::whereIn('bus_number', $numbers);
    }

    public static function notify(Collection $children, array $text): int
    {
        $parents = $children->whereNotNull('parent_id')->unique('parent_id');
        foreach ($parents as $child) {
            $attributes = ['parent_id' => $child->parent_id, 'child_id' => $child->id,
                'category' => 'bus', 'time_label' => now()->format('H:i'), 'day_group' => 'today'];
            foreach (['en', 'ar', 'fr'] as $lang) {
                $attributes['title_'.$lang] = Trilingual::pick($lang, ...$text);
                $attributes['body_'.$lang] = Trilingual::pick($lang, ...$text);
            }
            SafetyNotification::create($attributes);
        }

        return $parents->count();
    }
}
