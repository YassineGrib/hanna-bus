<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Child;
use App\Models\SupportMessage;
use App\Support\DriverPortal;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DriverMessageController extends Controller
{
    private function query(Request $request): Builder
    {
        return SupportMessage::with(['parent', 'child'])->where('driver_id', $request->user()->id)
            ->whereIn('child_id', DriverPortal::accessibleChildren($request)->select('id'));
    }

    public function index(Request $request): JsonResponse
    {
        $threads = $this->query($request)->latest('created_at')->orderByDesc('id')->get()
            ->groupBy(fn ($m) => $m->parent_id.':'.$m->child_id);

        return response()->json($threads->map(function ($messages) {
            $last = $messages->first();

            return ['parent' => $last->parent->only(['id', 'name']),
                'child' => ['id' => $last->child->id, 'name' => $last->child->full_name, 'stop_name' => $last->child->stop_name],
                'last_message' => $last->message, 'last_at' => $last->created_at->toISOString(),
                'unread_count' => $messages->where('direction', 'parent_to_driver')->whereNull('read_at')->count(),
                'is_urgent' => $messages->contains(fn ($m) => $m->isUrgent())];
        })->values());
    }

    private function child(Request $request, string $parent, string $child): Child
    {
        return DriverPortal::accessibleChildren($request)->with('parent')->where('parent_id', $parent)->findOrFail($child);
    }

    public function show(Request $request, string $parent): JsonResponse
    {
        $v = $request->validate(['child_id' => ['required', 'string']]);
        $child = $this->child($request, $parent, $v['child_id']);
        $query = $this->query($request)->where('parent_id', $parent)->where('child_id', $child->id);
        (clone $query)->where('direction', 'parent_to_driver')->whereNull('read_at')->update(['read_at' => now()]);

        return response()->json(['parent' => $child->parent->only(['id', 'name']),
            'child' => ['id' => $child->id, 'name' => $child->full_name, 'stop_name' => $child->stop_name],
            'messages' => $query->oldest()->orderBy('id')->get()->map(fn ($m) => $m->threadItem())]);
    }

    public function store(Request $request, string $parent): JsonResponse
    {
        $v = $request->validate(['child_id' => ['required', 'string'], 'message' => ['required', 'string', 'min:3', 'max:600']]);
        $child = $this->child($request, $parent, $v['child_id']);

        return DB::transaction(function () use ($request, $parent, $v, $child) {
            $msg = SupportMessage::create(['parent_id' => $parent, 'child_id' => $child->id,
                'driver_id' => $request->user()->id, 'recipient_type' => 'driver',
                'direction' => 'driver_to_parent', 'message' => $v['message'], 'status' => 'sent']);
            DriverPortal::notify(new Collection([$child]),
                ['New message from your driver.', 'رسالة جديدة من السائق.', 'Nouveau message de votre chauffeur.']);

            return response()->json($msg->threadItem(), 201);
        });
    }
}
