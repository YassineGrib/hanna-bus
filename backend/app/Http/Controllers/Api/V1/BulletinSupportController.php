<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
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
        ]);

        $msg = SupportMessage::create([
            'parent_id' => $request->user()->id,
            'recipient_type' => $v['recipient_type'],
            'child_id' => $v['child_id'] ?? null,
            'message' => $v['message'],
            'status' => 'sent',
        ]);

        return response()->json([
            'id' => $msg->id,
            'status' => $msg->status,
            'message' => $msg->message,
        ], 201);
    }
}
