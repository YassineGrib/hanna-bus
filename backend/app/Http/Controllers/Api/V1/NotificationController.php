<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\SafetyNotification;
use App\Support\Trilingual;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $lang = Trilingual::lang($request);
        $items = $request->user()->notifications()->latest('id')->get();

        return response()->json([
            'data' => $items->map(fn ($n) => [
                'id' => $n->id,
                'child_id' => $n->child_id,
                'category' => $n->category,
                'title' => Trilingual::pick($lang, $n->title_en, $n->title_ar, $n->title_fr),
                'body' => Trilingual::pick($lang, $n->body_en, $n->body_ar, $n->body_fr),
                'day_group' => $n->day_group,
                'time_label' => $n->time_label,
                'is_read' => $n->is_read,
            ])->values(),
        ]);
    }

    public function markAsRead(Request $request, int $id): JsonResponse
    {
        $n = SafetyNotification::where('id', $id)
            ->where('parent_id', $request->user()->id)
            ->firstOrFail();

        $n->update(['is_read' => true]);

        return response()->json(['id' => $n->id, 'is_read' => true]);
    }

    public function markAllAsRead(Request $request): JsonResponse
    {
        SafetyNotification::where('parent_id', $request->user()->id)->update(['is_read' => true]);

        return response()->json(['all_read' => true]);
    }
}
