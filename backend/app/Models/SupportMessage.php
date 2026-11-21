<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SupportMessage extends Model
{
    public function parent(): BelongsTo
    {
        return $this->belongsTo(User::class, 'parent_id');
    }

    public function child(): BelongsTo
    {
        return $this->belongsTo(Child::class);
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    public function threadItem(): array
    {
        return ['id' => $this->id, 'direction' => $this->direction, 'message' => $this->message,
            'created_at' => $this->created_at->toISOString(), 'read_at' => $this->read_at?->toISOString()];
    }

    public function isUrgent(): bool
    {
        if ($this->urgent) {
            return true;
        }
        $keywords = ['allergy', 'allergic', 'medical', 'asthma', 'inhaler', 'epipen', 'allergie', 'médical', 'حساسية', 'ربو', 'طبي'];
        foreach ([$this->child?->allergies, $this->child?->chronic_conditions] as $condition) {
            foreach (preg_split('/[^\pL\pN]+/u', mb_strtolower($condition ?? '')) as $word) {
                if (mb_strlen($word) > 3 && ! in_array($word, ['none', 'reported', 'verified', 'medical', 'alerts'], true)) {
                    $keywords[] = $word;
                }
            }
        }

        return collect($keywords)->contains(fn ($word) => str_contains(mb_strtolower($this->message), $word));
    }

    protected $fillable = [
        'driver_id',
        'direction',
        'read_at',
        'urgent',
        'parent_id',
        'recipient_type',
        'child_id',
        'message',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'read_at' => 'datetime',
            'urgent' => 'boolean',
        ];
    }
}
