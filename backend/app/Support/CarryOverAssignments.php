<?php

namespace App\Support;

use App\Models\BusAssignment;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;

class CarryOverAssignments
{
    /**
     * The most recent day before $date that has assignments. Looking for the latest day with
     * data (not just yesterday) keeps carry over working after weekends and holidays.
     */
    public function sourceDate(CarbonImmutable $date): ?CarbonImmutable
    {
        $latest = BusAssignment::whereDate('date', '<', $date->toDateString())->max('date');

        return $latest === null ? null : CarbonImmutable::parse($latest)->startOfDay();
    }

    /** @return array{created: int, skipped: int} */
    public function handle(CarbonImmutable $date): array
    {
        $previous = $this->sourceDate($date);
        if ($previous === null) {
            return ['created' => 0, 'skipped' => 0];
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
