<div style="display:flex;flex-direction:column;gap:.75rem">
    <h2 style="font-weight:700;font-size:1.1rem">{{ __('admin.thread') }}</h2>
    @foreach ($threadMessages as $message)
        <article style="padding:.75rem 1rem;border:1px solid rgba(128,128,128,.3);border-radius:.75rem">
            <p style="font-size:.8rem;opacity:.75;margin-bottom:.35rem">
                {{ __('admin.'.$message->direction) }} · {{ $message->created_at }}
                @if ($message->read_at === null)
                    <x-filament::badge color="warning" size="sm" style="margin-inline-start:.5rem">{{ __('admin.unread') }}</x-filament::badge>
                @endif
            </p>
            <p>{{ $message->message }}</p>
        </article>
    @endforeach
</div>
