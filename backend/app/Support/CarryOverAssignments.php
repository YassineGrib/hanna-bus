<?php

namespace App\Support;

use App\Models\BusAssignment;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;

class CarryOverAssignments
{
    /** @return array{created: int, skipped: int} */
    public function handle(CarbonImmutable $date): array
    {
        $previous = $date->subDay();
        while (in_array($previous->dayOfWeek, [5, 6], true)) {
            $previous = $previous->subDay();
        }

        return DB::transaction(function () use ($previous, $date): array {
            $counts = ['created' => 0, 'skipped' => 0];
            foreach (BusAssignment::whereDate('date', $previous)->orderBy('id')->get() as $source) {
                $copy = BusAssignment::firstOrCreate(
                    ['driver_id' => $source->driver_id, 'date' => $date->toDateString()],
                    ['bus_id' => $source->bus_id],
                );
                $counts[$copy->wasRecentlyCreated ? 'created' : 'skipped']++;
            }

            return $counts;
        });
    }
}
