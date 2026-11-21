{{--
    OpenStreetMap picker for a station: click the map or drag the pin to fill the sibling
    `lat` and `lng` fields. It binds to those two fields only and stores nothing itself.
--}}
@php
    $parentPath = \Illuminate\Support\Str::beforeLast($getStatePath(), '.');
@endphp
<div
    wire:ignore
    x-data="{
        lat: $wire.$entangle('{{ $parentPath }}.lat'),
        lng: $wire.$entangle('{{ $parentPath }}.lng'),
        map: null,
        pin: null,
        loadLeaflet() {
            if (window.hannaLeaflet) {
                return window.hannaLeaflet;
            }
            window.hannaLeaflet = new Promise((resolve, reject) => {
                const css = document.createElement('link');
                css.rel = 'stylesheet';
                css.href = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css';
                document.head.appendChild(css);
                const js = document.createElement('script');
                js.src = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js';
                js.onload = () => resolve(window.L);
                js.onerror = reject;
                document.head.appendChild(js);
            });
            return window.hannaLeaflet;
        },
        valid(value, limit) {
            const number = parseFloat(value);
            return Number.isFinite(number) && Math.abs(number) <= limit ? number : null;
        },
        place(L, latitude, longitude, recentre) {
            if (this.pin) {
                this.pin.setLatLng([latitude, longitude]);
            } else {
                this.pin = L.marker([latitude, longitude], { draggable: true }).addTo(this.map);
                this.pin.on('dragend', () => this.pick(this.pin.getLatLng()));
            }
            if (recentre) {
                this.map.setView([latitude, longitude], Math.max(this.map.getZoom(), 15));
            }
        },
        pick(point) {
            this.lat = point.lat.toFixed(6);
            this.lng = point.lng.toFixed(6);
        },
        async init() {
            const L = await this.loadLeaflet();
            const latitude = this.valid(this.lat, 90);
            const longitude = this.valid(this.lng, 180);
            this.map = L.map(this.$refs.canvas).setView(
                latitude !== null && longitude !== null ? [latitude, longitude] : [28.0339, 1.6596],
                latitude !== null && longitude !== null ? 15 : 5,
            );
            L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 19,
                attribution: '&copy; OpenStreetMap contributors',
            }).addTo(this.map);
            if (latitude !== null && longitude !== null) {
                this.place(L, latitude, longitude, false);
            }
            this.map.on('click', (event) => {
                this.pick(event.latlng);
                this.place(L, event.latlng.lat, event.latlng.lng, false);
            });
            const sync = () => {
                const a = this.valid(this.lat, 90);
                const b = this.valid(this.lng, 180);
                if (a !== null && b !== null) {
                    this.place(L, a, b, true);
                }
            };
            this.$watch('lat', sync);
            this.$watch('lng', sync);
            setTimeout(() => this.map.invalidateSize(), 250);
        },
    }"
    class="hanna-location-picker"
>
    <p class="fi-fo-field-wrp-hint" style="margin-bottom:.4rem;font-size:.85rem;opacity:.75">
        {{ __('admin.map_picker_help') }}
    </p>
    <div
        x-ref="canvas"
        style="height:280px;width:100%;border-radius:.75rem;border:1px solid rgba(128,128,128,.35);overflow:hidden;z-index:0"
    ></div>
</div>
