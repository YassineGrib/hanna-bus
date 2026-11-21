<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ActiveTrip;
use App\Models\BusAssignment;
use App\Models\SchoolBulletin;
use App\Models\SupportMessage;
use App\Support\Trilingual;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BulletinSupportController extends Controller
{
    public function bulletins(Request $request): JsonResponse
    {
        $lang = Trilingual::lang($request);
        $items = SchoolBulletin::latest('published_at')->get();

        return response()->json([
            'data' => $items->map(fn ($b) => [
                'id' => $b->id,
                'tag' => $b->tag,
                'title' => Trilingual::pick($lang, $b->title_en, $b->title_ar, $b->title_fr),
                'body' => Trilingual::pick($lang, $b->body_en, $b->body_ar, $b->body_fr),
                'published_at' => optional($b->published_at)->toIso8601String(),
            ])->values(),
        ]);
    }

    public function storeMessage(Request $request): JsonResponse
    {
        $v = $request->validate([
            'recipient_type' => ['required', 'in:driver,coordinator'],
            'child_id' => ['nullable', 'string'],
            'message' => ['required', 'string', 'min:3', 'max:600'],
            'urgent' => ['sometimes', 'boolean'],
        ]);

        $child = isset($v['child_id']) ? $request->user()->children()->findOrFail($v['child_id']) : null;
        $driverId = null;
        if ($v['recipient_type'] === 'driver') {
            $child ??= $request->user()->children()->first();
            if ($child) {
                $driverId = BusAssignment::whereDate('date', today())
                    ->whereHas('bus', fn ($q) => $q->where('number', $child->bus_number))->value('driver_id')
                    ?? ActiveTrip::where('bus_number', $child->bus_number)->whereNotNull('driver_id')->value('driver_id');
            }
        }
        $msg = SupportMessage::create([
            'parent_id' => $request->user()->id,
            'recipient_type' => $v['recipient_type'],
            'child_id' => $child?->id,
            'driver_id' => $driverId,
            'urgent' => $v['urgent'] ?? false,
            'message' => $v['message'],
            'status' => 'sent',
        ]);

        return response()->json([
            'id' => $msg->id,
            'status' => $msg->status,
            'message' => $msg->message,
        ], 201);
    }

    public function messages(Request $request): JsonResponse
    {
        $query = SupportMessage::where('parent_id', $request->user()->id)->where('recipient_type', 'driver');
        (clone $query)->where('direction', 'driver_to_parent')->whereNull('read_at')->update(['read_at' => now()]);

        return response()->json($query->oldest()->orderBy('id')->get()->map(fn ($m) => $m->threadItem()));
    }
}
