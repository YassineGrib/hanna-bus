<?php

namespace App\Filament\Pages;

use App\Filament\Resources\AssignmentResource;
use App\Models\ActiveTrip;
use App\Models\BusAssignment;
use App\Support\CarryOverAssignments;
use App\Support\GenerateDailyTrips;
use Carbon\CarbonImmutable;
use Filament\Actions\Action;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Tables\Concerns\InteractsWithTable;
use Filament\Tables\Contracts\HasTable;
use Filament\Tables\Table;

class DailyPlanning extends Page implements HasTable
{
    use InteractsWithTable;

    protected string $view = 'filament.daily-planning';

    public string $date = '';

    public static function canAccess(): bool
    {
        return auth()->user()?->role === 'admin';
    }

    public static function getNavigationLabel(): string
    {
        return __('admin.daily_planning');
    }

    public function getTitle(): string
    {
        return __('admin.daily_planning');
    }

    public function mount(): void
    {
        $this->date = today()->toDateString();
    }

    public function updatedDate(): void
    {
        $this->resetTable();
    }

    protected function getHeaderActions(): array
    {
        return [
            Action::make('carryOver')->label(__('admin.carry_over'))->requiresConfirmation()->action(fn () => $this->carryOver()),
            Action::make('generateTrips')->label(__('admin.generate_trips'))->requiresConfirmation()->action(fn () => $this->generateTrips()),
        ];
    }

    public function carryOver(): void
    {
        abort_unless(static::canAccess(), 403);
        $this->validate(['date' => ['required', 'date_format:Y-m-d']]);
        $carryOver = app(CarryOverAssignments::class);
        $target = CarbonImmutable::parse($this->date);
        $source = $carryOver->sourceDate($target);

        if ($source === null) {
            Notification::make()->title(__('admin.carry_over_none'))->warning()->send();

            return;
        }

        $counts = $carryOver->handle($target);
        Notification::make()
            ->title(__('admin.operation_result', $counts))
            ->body(__('admin.carry_over_from', ['date' => $source->toDateString()]))
            ->success()
            ->send();
        $this->resetTable();
    }

    public function generateTrips(): void
    {
        abort_unless(static::canAccess(), 403);
        $this->validate(['date' => ['required', 'date_format:Y-m-d']]);
        $this->notifyResult(app(GenerateDailyTrips::class)->handle(CarbonImmutable::parse($this->date)));
    }

    /** @param array{created: int, skipped: int} $counts */
    private function notifyResult(array $counts): void
    {
        Notification::make()->title(__('admin.operation_result', $counts))->success()->send();
        $this->resetTable();
    }

    public function table(Table $table): Table
    {
        return AssignmentResource::table($table)->query(BusAssignment::with(['driver', 'bus'])->whereDate('date', $this->date))
            ->heading(__('admin.assignments'))->filters([])->recordActions([]);
    }

    protected function getViewData(): array
    {
        return ['trips' => ActiveTrip::with(['driver', 'bus'])->whereDate('service_date', $this->date)->orderBy('scheduled_start')->get()];
    }
}
