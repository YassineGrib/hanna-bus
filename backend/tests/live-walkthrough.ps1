# Live API walkthrough against a running server (php artisan serve) on a freshly seeded DB:
#   php artisan migrate:fresh --seed; php artisan serve; then run this script.
# Exercises the full driver day (start flow, boarding, location, messages, end) and the parent view.
$ErrorActionPreference = "Continue"
$b = "http://127.0.0.1:8000/api/v1"
function Call($method, $path, $body, $token) {
    $h = @{ Accept = "application/json" }
    if ($token) { $h["Authorization"] = "Bearer $token" }
    $args = @{ Uri = "$b$path"; Method = $method; Headers = $h; UseBasicParsing = $true }
    if ($body) { $args["Body"] = ($body | ConvertTo-Json -Depth 6); $args["ContentType"] = "application/json" }
    try {
        $r = Invoke-WebRequest @args
        return @{ code = [int]$r.StatusCode; json = ($r.Content | ConvertFrom-Json); raw = $r.Content }
    } catch {
        $resp = $_.Exception.Response
        $txt = ""
        if ($resp) { $sr = New-Object IO.StreamReader($resp.GetResponseStream()); $txt = $sr.ReadToEnd() }
        $j = $null; try { $j = $txt | ConvertFrom-Json } catch {}
        return @{ code = [int]$resp.StatusCode; json = $j; raw = $txt }
    }
}
function Step($name, $res, $expect) {
    $ok = ($res.code -eq $expect)
    $mark = if ($ok) { "PASS" } else { "FAIL" }
    $extra = ""
    if (-not $ok) { $extra = " -> " + $res.json.message }
    "{0} [{1}] {2} (got {3}, expected {4}){5}" -f $mark, $res.code, $name, $res.code, $expect, $extra
}

$d = Call POST "/driver/auth/login" @{ email = "ahmed.benali@mail.dz"; password = "Password123!" } $null
Step "driver login" $d 200
$dt = $d.json.token
$p = Call POST "/auth/login" @{ email = "k.mansouri@mail.dz"; password = "Password123!" } $null
Step "parent login" $p 200
$pt = $p.json.token

Step "driver profile" (Call GET "/driver/profile" $null $dt) 200
$buses = Call GET "/driver/buses" $null $dt
Step "driver buses" $buses 200
"   buses: " + (($buses.json | ForEach-Object { "$($_.number)=$($_.status)$(if ($_.is_current) {'*'})" }) -join ", ")
$cur = $buses.json | Where-Object { $_.is_current } | Select-Object -First 1
Step "rotation" (Call GET "/driver/rotation" $null $dt) 200

$trips = Call GET "/driver/trips/today" $null $dt
Step "trips today" $trips 200
$all = @($trips.json)
"   trips: " + (($all | ForEach-Object { "$($_.id):$($_.period):$($_.status):stations=$(@($_.stations).Count)" }) -join " | ")
$trip = $all | Where-Object { $_.status -eq "en_route" } | Select-Object -First 1
$ret = $all | Where-Object { $_.status -eq "scheduled" } | Select-Object -First 1
$tid = $trip.id
"   working on seeded en_route trip: $tid ; scheduled trip for later: $($ret.id)"
Step "start while another trip is running (409)" (Call POST "/driver/trips/$($ret.id)/start" $null $dt) 409

$st = @($trip.stations)
$s0 = $st[0]
Step "location point 1" (Call POST "/driver/trips/$tid/location" @{ lat = [double]$s0.lat; lng = [double]$s0.lng; speed_kmh = 32; heading = 80 } $dt) 200
$students = Call GET "/driver/trips/$tid/students" $null $dt
Step "students" $students 200
$present = @($students.json) | Where-Object { -not $_.absent } | Select-Object -First 1
$absent = @($students.json) | Where-Object { $_.absent } | Select-Object -First 1
"   roster: " + @($students.json).Count + " students, absent: " + @(@($students.json) | Where-Object { $_.absent }).Count
Step "board present child by QR" (Call POST "/driver/trips/$tid/boarding" @{ student_code = $present.student_code; type = "boarded"; method = "qr" } $dt) 201
Step "board same child again (idempotent 200)" (Call POST "/driver/trips/$tid/boarding" @{ student_code = $present.student_code; type = "boarded"; method = "qr" } $dt) 200
if ($absent) { Step "board absent child (422)" (Call POST "/driver/trips/$tid/boarding" @{ student_code = $absent.student_code; type = "boarded"; method = "qr" } $dt) 422 }
Step "board unknown code (404)" (Call POST "/driver/trips/$tid/boarding" @{ student_code = "NOPE-000"; type = "boarded"; method = "qr" } $dt) 404

Step "student dossier" (Call GET "/driver/students/$($present.child_id)" $null $dt) 200
$dossier = (Call GET "/driver/students/$($present.child_id)" $null $dt).raw
Step "arrive first station" (Call POST "/driver/trips/$tid/stations/$($s0.id)/arrive" $null $dt) 200
Step "delay broadcast" (Call POST "/driver/trips/$tid/delay" @{ minutes = 6; reason = "traffic" } $dt) 200

$at = Call GET "/parent/tracking/active-trip" $null $pt
Step "parent active trip" $at 200
"   parent sees: status=$($at.json.status) onboard=$($at.json.onboard_count) location=$(if ($at.json.location) { '' + $at.json.location.lat + ',' + $at.json.location.lng } else { 'null' }) route_points=$(@($at.json.route_points).Count) station0=$($at.json.stations[0].lat),$($at.json.stations[0].lng)"
$pn = Call GET "/parent/notifications" $null $pt
Step "parent notifications" $pn 200
"   parent notifications: " + @($pn.json.notifications).Count + $(if ($pn.json -is [array]) { " (array " + $pn.json.Count + ")" } else { "" })

$child = Call GET "/parent/children" $null $pt
$childId = @($child.json.data)[0].id
Step "parent sends message to driver" (Call POST "/parent/support/messages" @{ recipient_type = "driver"; child_id = $childId; message = "Please wait for me at the gate" } $pt) 201
$inbox = Call GET "/driver/messages" $null $dt
Step "driver inbox" $inbox 200
$thread = @($inbox.json) | Select-Object -First 1
"   inbox: " + @($inbox.json).Count + " threads, first unread=" + $thread.unread_count
$parentId = $thread.parent.id
Step "driver thread" (Call GET "/driver/messages/${parentId}?child_id=$childId" $null $dt) 200
Step "driver replies" (Call POST "/driver/messages/$parentId" @{ child_id = $childId; message = "OK, I will wait" } $dt) 201
$pm = Call GET "/parent/support/messages" $null $pt
Step "parent reads driver reply" $pm 200
"   parent thread messages: " + @($pm.json.messages).Count + @($pm.json).Count

Step "driver stats" (Call GET "/driver/stats" $null $dt) 200
Step "driver telemetry" (Call GET "/driver/telemetry/today" $null $dt) 200
Step "driver contacts" (Call GET "/driver/contacts" $null $dt) 200
Step "driver settings get" (Call GET "/driver/settings" $null $dt) 200
Step "driver settings put" (Call PUT "/driver/settings" @{ glare_mode = "night"; scan_chime = $true } $dt) 200
Step "driver settings unknown key (422)" (Call PUT "/driver/settings" @{ bogus = 1 } $dt) 422
Step "vehicle passport" (Call GET "/driver/buses/$($cur.id)" $null $dt) 200
Step "sos" (Call POST "/driver/sos" @{ type = "breakdown"; trip_id = $tid; lat = [double]$s0.lat; lng = [double]$s0.lng } $dt) 201

Step "end without safety walk (422)" (Call POST "/driver/trips/$tid/end" @{ safety_walk_confirmed = $false } $dt) 422
Step "end trip" (Call POST "/driver/trips/$tid/end" @{ safety_walk_confirmed = $true } $dt) 200
Step "end again idempotent" (Call POST "/driver/trips/$tid/end" @{ safety_walk_confirmed = $true } $dt) 200
Step "board after end (409)" (Call POST "/driver/trips/$tid/boarding" @{ student_code = $present.student_code; type = "alighted"; method = "qr" } $dt) 409
"--- second trip: full start flow"
$rid = $ret.id
Step "start without inspection (422)" (Call POST "/driver/trips/$rid/start" $null $dt) 422
Step "inspection" (Call POST "/driver/inspections" @{ bus_id = $cur.id; passed = $true; items = @{ tires = $true; brakes = $true; lights = $true; fuel = $true } } $dt) 201
Step "start return trip" (Call POST "/driver/trips/$rid/start" $null $dt) 200
$r0 = @($ret.stations)[0]
Step "return trip location" (Call POST "/driver/trips/$rid/location" @{ lat = [double]$r0.lat; lng = [double]$r0.lng; speed_kmh = 28; heading = 200 } $dt) 200
$at2 = Call GET "/parent/tracking/active-trip" $null $pt
"   parent now sees trip=$($at2.json.id) status=$($at2.json.status) location=$(if ($at2.json.location) { 'set' } else { 'null' })"
Step "end return trip" (Call POST "/driver/trips/$rid/end" @{ safety_walk_confirmed = $true } $dt) 200
Step "driver history" (Call GET "/driver/history?period=all" $null $dt) 200
$ph = Call GET "/parent/tracking/history" $null $pt
Step "parent history" $ph 200

Step "driver token on parent route (403)" (Call GET "/parent/profile" $null $dt) 403
Step "parent token on driver route (403)" (Call GET "/driver/profile" $null $pt) 403
Step "no token (401)" (Call GET "/driver/profile" $null $null) 401
"--- privacy check on driver responses"
$leak = ($dossier + (Call GET "/driver/trips/today" $null $dt).raw)
foreach ($k in @("national_id", "insurance_number", "birth_date", "pediatrician")) { "   contains '$k': " + ($leak -match $k) }

