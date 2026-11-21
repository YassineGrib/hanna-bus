<?php

namespace App\Console\Commands;

use App\Support\CarryOverAssignments;
use App\Support\GenerateDailyTrips;
use Carbon\CarbonImmutable;
use Illuminate\Console\Attributes\Description;
use Illuminate\Console\Attributes\Signature;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Validator;

#[Signature('hanna:generate-trips {--date= : Service date (YYYY-MM-DD), defaults to today} {--carry-assignments : Copy assignments from the previous service date}')]
#[Description('Generate scheduled morning and return trips for assigned buses')]
class GenerateTrips extends Command
{
    public function handle(GenerateDailyTrips $generate): int
    {
        $date = $this->option('date') ?? today()->toDateString();
        if (Validator::make(['date' => $date], ['date' => ['required', 'date_format:Y-m-d']])->fails()) {
            $this->error('Invalid date. Use --date=YYYY-MM-DD with a valid calendar date.');

            return self::FAILURE;
        }

        if ($this->option('carry-assignments')) {
            $assignments = app(CarryOverAssignments::class)->handle(CarbonImmutable::createFromFormat('!Y-m-d', $date));
            $this->info("Created {$assignments['created']} assignments; skipped {$assignments['skipped']} assignments.");
        }
        $counts = $generate->handle(CarbonImmutable::createFromFormat('!Y-m-d', $date));
        $this->info("Created {$counts['created']} trips; skipped {$counts['skipped']} trips for {$date}.");

        foreach ($generate->warnings(CarbonImmutable::createFromFormat('!Y-m-d', $date)) as $warning) {
            $this->warn($warning);
        }

        return self::SUCCESS;
    }
}
