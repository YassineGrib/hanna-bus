<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class AdminLocaleController extends Controller
{
    public function __invoke(Request $request): RedirectResponse
    {
        abort_unless($request->user()?->role === 'admin', 403);
        $data = $request->validate(['locale' => ['required', Rule::in(['en', 'ar'])]]);
        $request->user()->update($data);

        return redirect()->route('filament.admin.pages.dashboard');
    }
}
