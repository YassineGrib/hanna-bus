<div>
    <p>{{ __('admin.qr_code') }}</p>
    <img alt="{{ __('admin.qr_code') }}" width="200" height="200" src="{{ (new \chillerlan\QRCode\QRCode(new \chillerlan\QRCode\QROptions(['outputType' => 'svg', 'outputBase64' => true])))->render($getRecord()->student_code) }}">
    <p>{{ $getRecord()->student_code }}</p>
</div>
