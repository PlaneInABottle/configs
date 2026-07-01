# Flight API Discovery Notes

Date: 2026-06-29

## FlightConnections: Turkish Airlines Route Map

Target page:

```text
https://www.flightconnections.com/route-map-turkish-airlines-tk
```

Confirmed airline identifiers from page globals:

```text
URLairline_id = 4913
URLairline_iata = tk
databaseAndTilesVersion = 260601/
```

### Confirmed Endpoints

These endpoints were observed from browser performance entries and validated with plain HTTP when a browser-like `User-Agent` and `Referer` are sent.

```http
GET https://www.flightconnections.com/filter_ar_4913.json?v=1097&lang=en&dep=&des=&ids=4913&cl=&flight_direction=from&flight_type=round&airlines=4913&alliance=&classes=&dates=&dates_type=&days_in_destination=&aircrafts=
Referer: https://www.flightconnections.com/route-map-turkish-airlines-tk
User-Agent: Mozilla/5.0 ...
Accept: application/json,text/plain,*/*
```

Response shape:

```json
{
  "pts": [12, 15, 16],
  "ctr": 0,
  "classes": 5
}
```

For TK, `pts` contained 288 internal airport IDs.

```http
GET https://www.flightconnections.com/airline_routes.php?v=1097&lang=en&type=ar&ids=4913&cl=&flight_direction=from&flight_type=round&airlines=4913&alliance=&classes=&dates=&dates_type=&days_in_destination=&aircrafts=&dep_country=&des_country=
Referer: https://www.flightconnections.com/route-map-turkish-airlines-tk
User-Agent: Mozilla/5.0 ...
Accept: application/json,text/plain,*/*
```

Response shape:

```json
{
  "route": [
    {
      "id": 12,
      "pts": [12, 131],
      "c": [0, 215],
      "crd": [52.308601, 4.76389, 41.261297, 28.741951]
    }
  ],
  "routes": [
    {
      "des": [131, 131],
      "...": "grouped/compressed route data"
    }
  ]
}
```

For TK, `route` contained 288 route objects. The page assigns this response to `window.airline_routes`.

Airport ID/name lookup is available through CDN tile JSON:

```http
GET https://cdn.flightconnections.com/tiles/260601/en/2/1-1.json
GET https://cdn.flightconnections.com/tiles/260601/en/2/2-1.json
...
```

Tile response shape:

```json
{
  "geom": [
    {
      "s": 4,
      "p": [60, 108],
      "a": "Arad (ARW)",
      "c": 18
    }
  ]
}
```

`c` is the internal airport ID, `a` is the display name including IATA. Sampling zoom `2` tiles `0-0` through `3-3` produced 3973 airport mappings and decoded all TK route `pts`.

Known ID:

```text
131 = Istanbul (IST)
```

Sample decoded TK routes:

```text
12: Amsterdam (AMS) -> Istanbul (IST)
15: Ankara (ESB) -> Istanbul (IST)
16: Antalya (AYT) -> Istanbul (IST) -> Moscow Vnukovo (VKO) -> Saint Petersburg (LED) -> Kazan (KZN) -> Ercan, Northern Cyprus (ECN)
21: Athens (ATH) -> Istanbul (IST)
23: Barcelona (BCN) -> Istanbul (IST)
44: Bodrum (BJV) -> Istanbul (IST) -> Moscow Vnukovo (VKO) -> Saint Petersburg (LED)
```

### Repro Script

```python
import json
import urllib.request

UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126 Safari/537.36"
HEADERS = {
    "User-Agent": UA,
    "Referer": "https://www.flightconnections.com/route-map-turkish-airlines-tk",
    "Accept": "application/json,text/plain,*/*",
}

def get_json(url):
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=20) as r:
        return json.load(r)

routes = get_json(
    "https://www.flightconnections.com/airline_routes.php"
    "?v=1097&lang=en&type=ar&ids=4913&cl=&flight_direction=from"
    "&flight_type=round&airlines=4913&alliance=&classes=&dates="
    "&dates_type=&days_in_destination=&aircrafts=&dep_country=&des_country="
)

lookup = {}
for x in range(4):
    for y in range(4):
        tile = get_json(f"https://cdn.flightconnections.com/tiles/260601/en/2/{x}-{y}.json")
        if not isinstance(tile, dict):
            continue
        for geom in tile.get("geom", []):
            if isinstance(geom, dict) and geom.get("c") is not None:
                lookup.setdefault(geom["c"], geom.get("a"))

decoded = []
for route in routes.get("route", []):
    decoded.append({
        "id": route.get("id"),
        "points": route.get("pts", []),
        "airports": [lookup.get(point_id, f"#{point_id}") for point_id in route.get("pts", [])],
        "coords": route.get("crd", []),
        "classes": route.get("c", []),
    })

print(json.dumps(decoded[:10], indent=2, ensure_ascii=False))
```

### Parameter Notes

Observed route/filter parameters:

```text
v=1097
lang=en
type=ar
ids=4913
cl=
flight_direction=from
flight_type=round
airlines=4913
alliance=
classes=
dates=
dates_type=
days_in_destination=
aircrafts=
dep_country=
des_country=
```

The minified JS builds `airline_routes.php` in `mapbasics.min.js` and sends filter state as query parameters. `type=ar` appears to mean airline-route filter. `ids=4913` and `airlines=4913` are both sent for the Turkish Airlines page.

## MyIDTravel

Target page/session:

```text
https://www.myidtravel.com/myidtravel/rui/main
```

Observed after pressing `Find Flights` on the logged-in page:

```text
https://www.myidtravel.com/myidtravel/rui/main/find-flights/travel-history/flight-list
```

Observed resource/API paths from browser performance entries:

```text
/myidtravel/json/general/login
/myidtravel/json/hybrid-app/marketing
/myidtravel/json/general/loginpage
/myidtravel/json/metrics/screen-visit
/myidtravel/json/dynamictext/get
/myidtravel/json/general/triphistory
/myidtravel/json/flight-search/list
/myidtravel/json/followFlight/list
/myidtravel/json/booking/preparebooking
/myidtravel/json/booking/travellerselection
/myidtravel/json/booking/flightschedule
```

Direct in-page `GET` requests to these likely action endpoints returned only a small JSON envelope:

```json
{
  "success": "...",
  "messages": "...",
  "responseXactId": "...",
  "currentSessionId": "..."
}
```

The real flight-search call has now been confirmed:

```http
POST https://www.myidtravel.com/myidtravel/json/booking/flightschedule
Content-Type: application/json
Accept: application/json
Origin: https://www.myidtravel.com
Referer: https://www.myidtravel.com/myidtravel/rui/main/find-flights/travel-history/flight-list
Cookie: JSESSIONID=<www.myidtravel.com /myidtravel session cookie>
```

Request body shape:

```json
{
  "translations": [],
  "csrf": "<localStorage.csrf>",
  "tabId": "<sessionStorage.tabId>",
  "travelStatus": 1,
  "airline": "",
  "routings": [
    {
      "origin": "GRU",
      "destination": "GIG",
      "date": "2026-06-30",
      "compartment": "Y",
      "time": "00:00"
    }
  ],
  "nonStop": false,
  "filterCodesharedFlights": null,
  "travelType": "ONE_WAY",
  "sevenDaySearchRequested": false
}
```

Important automation details:

```text
csrf: localStorage["csrf"]
tabId: sessionStorage["tabId"]
session cookie: domain www.myidtravel.com, path /myidtravel, name JSESSIONID
travelStatus: 1 observed as R2 Standby
compartment: Y observed as Economy
airline: "" means all airlines; "TK" can be supplied as an airline filter
```

The response has one `routings[]` entry per requested segment. Each routing has `flights[]`; each itinerary has:

```json
{
  "selectable": true,
  "chance": "MID",
  "duration": "1h",
  "segments": [
    {
      "flightNumber": "LA3340",
      "marketingAirline": { "code": "LA" },
      "operatingAirline": { "code": "LA" },
      "from": { "code": "GRU" },
      "to": { "code": "GIG" },
      "departureTime": "07:55",
      "arrivalTime": "08:55",
      "travelStatus": "STANDBY",
      "kindOfTravel": "R2 Standby",
      "info": ""
    }
  ]
}
```

`Selectable flights only` can be automated by filtering `flights[]` where `flight.selectable === true`. No extra API request is needed for that filter; the endpoint returns selectable and unselectable itineraries together.

Current visible controls on the flight-list page after search:

```text
button: 1 Traveller
combobox
combobox
button: Back
button: Continue (disabled)
```

Reusable script:

```bash
python3 scripts/myidtravel_search.py GRU GIG 2026-06-30
python3 scripts/myidtravel_search.py DPS IST 2026-06-30
python3 scripts/myidtravel_search.py DPS IST 2026-06-30 --all
python3 scripts/myidtravel_search.py DPS IST 2026-06-30 --all --max-legs 2
python3 scripts/myidtravel_search.py GRU GIG 2026-06-30 --max-legs 1 --price-first
python3 scripts/myidtravel_search.py GRU GIG 2026-06-29 --max-legs 1 --price-all
```

The script reuses the active `agent-browser` session, reads the session cookie/CSRF/tab id, calls `flightschedule`, and returns only selectable flights by default. Use `--all` to include unselectable itineraries and their rejection reasons. Use `--max-legs N` to remove itineraries with more than `N` flight segments.

For fare automation, use `--price-all`, `--price-first`, or `--price-index N`. The index is applied after the selectable and leg-count filters.

Validated examples on 2026-06-29:

```text
GRU -> GIG on 2026-06-30:
  totalFlights: 6
  selectableFlights: 6
  selectable examples: LA3340, LA3698, LA3366, LA4548, LA3874, LA4672

GRU -> SDU on 2026-06-30:
  totalFlights: 4
  selectableFlights: 4
  selectable examples: AD4193, LA3550, LA3974, AD4311

GRU -> RIO on 2026-06-30:
  totalFlights: 10
  selectableFlights: 10
  includes GIG and SDU flights

DPS -> IST on 2026-06-30:
  totalFlights: 39
  selectableFlights: 0
  common rejection reasons include no ID agreement for selected travel mode or staff category not allowed
```

### Fare and Price API

Observed after selecting a flight and continuing to the fare page:

```text
https://www.myidtravel.com/myidtravel/rui/main/find-flights/travel-history/flight-list/fare-information
```

Confirmed API sequence:

```http
POST https://www.myidtravel.com/myidtravel/json/booking/flightschedule
POST https://www.myidtravel.com/myidtravel/json/booking/flightselection
POST https://www.myidtravel.com/myidtravel/json/booking/fares
```

The sequence matters. Calling `fares` without a fresh server-side flight selection can return `success: false`.

Minimal `flightselection` body after `flightschedule`:

```json
{
  "translations": [],
  "csrf": "<localStorage.csrf>",
  "tabId": "<sessionStorage.tabId>",
  "flights": [1]
}
```

`flights[]` contains the selected itinerary `id` from the schedule response, not the flight number.

Minimal `fares` body after successful `flightselection`:

```json
{
  "clientType": "DESKTOP",
  "responseType": "OPTIMIZED",
  "containerInformations": [
    {
      "identifier": "FaresPage"
    }
  ],
  "translations": [],
  "csrf": "<localStorage.csrf>",
  "tabId": "<sessionStorage.tabId>",
  "myDutyTripId": null
}
```

Useful response fields:

```text
employees[0].fares[0].total
employees[0].fares[0].prices[0].airline
employees[0].fares[0].prices[0].legs
employees[0].fares[0].prices[0].price.fare
employees[0].fares[0].prices[0].price.taxes
employees[0].fares[0].prices[0].price.fee
employees[0].fares[0].prices[0].price.sumOfAllTaxesAndFee
employees[0].fares[0].prices[0].price.total
employees[0].fares[0].prices[0].price.preferredCurrency
employees[0].fares[0].payments[0].paymentMethods
```

Do not persist or print the raw `paymentMethods[].iframeData` payload; it contains a payment iframe session token. The reusable script intentionally strips that field and returns only payment type, amount, and display flags.

Validated fare example on 2026-06-29:

```text
Command:
  python3 scripts/myidtravel_search.py GRU GIG 2026-06-30 --max-legs 1 --price-first

Selected:
  flightId: 1
  flightIndex: 0
  flight: LA3340
  route: GRU -> GIG

Price:
  preferredTotal: 1513.22 TRY
  fare: 22080 CLP
  taxes: 5964 CLP
  myIDTravel fee: 1886 CLP
  chargedTotal: 29930 CLP
  payment method: Credit Card with installment payment
```

## Turkish Airlines Official Schedule/Status API

Use this for TK-operated trunk flight timing/status. This is separate from MyIDTravel, which should be used for ZED availability/fare.

Public page:

```text
https://www.turkishairlines.com/en-int/flights/flight-status/
```

Frontend scripts showed these service names:

```text
/departurearrivals/byflight
/departurearrivals/bycity
/departurearrivals/bydeparture
/departurearrivals/byarrivals
```

Confirmed direct HTTP endpoint for route/day lookup:

```http
POST https://www.turkishairlines.com/com.thy.web.online.deparr/deparr/departurearrivals/bycity
Content-Type: application/json
Accept: application/json, text/plain, */*
Origin: https://www.turkishairlines.com
Referer: https://www.turkishairlines.com/en-int/flights/flight-status/
User-Agent: Mozilla/5.0

{
  "departureDate": "2026-06-29",
  "departures": ["IST"],
  "arrivals": ["GRU"],
  "lang": "en"
}
```

Confirmed direct HTTP endpoint for flight-number lookup:

```http
POST https://www.turkishairlines.com/com.thy.web.online.deparr/deparr/departurearrivals/byflight
Content-Type: application/json

{
  "flightNumber": "15",
  "departureDate": "2026-06-29"
}
```

Important: `flightNumber` must be numeric (`15`), not `TK15`.

Useful response fields:

```text
data.flights[].segments[].flightNumber
data.flights[].segments[].flightStatus
data.flights[].segments[].departureDateTimeISO.dateTimeLocal
data.flights[].segments[].arrivalDateTimeISO.dateTimeLocal
data.flights[].segments[].departureDateTimeISO.dateTimeUtc
data.flights[].segments[].arrivalDateTimeISO.dateTimeUtc
data.flights[].segments[].estimatedDepartureDateTime
data.flights[].segments[].estimatedArrivalDateTime
data.flights[].segments[].gate
data.flights[].segments[].departureTerminalInfo
data.flights[].segments[].arrivalTerminalInfo
data.flights[].segments[].aircraftType
data.flights[].segments[].journeyDuration
```

Reusable script:

```bash
python3 scripts/thy_schedule.py 2026-06-29 --origin IST --destination GRU
python3 scripts/thy_schedule.py 2026-06-29 --flight-number 15
```

Validated IST -> GRU on 2026-06-29:

```text
TK15:
  departs IST 2026-06-29 10:25 +03:00
  arrives GRU 2026-06-29 17:45 -03:00
  status observed: DEPARTED
  gate observed: A1J
  arrival terminal: 3

TK215:
  departs IST 2026-06-29 20:15 +03:00
  arrives GRU 2026-06-30 03:30 -03:00
  gate observed: D15
  arrival terminal: 3
```

## FlightConnections Route Schedule API

FlightConnections also exposes a reusable route timetable endpoint for public schedule data.

Route page:

```text
https://www.flightconnections.com/flights-from-ist-to-gru
```

Page variables observed:

```text
route_dep_id = 131
route_des_id = 3056
route_dep_iata = IST
route_des_iata = GRU
ym = 2026-06
```

Confirmed endpoint from `route_page.min.js`:

```http
POST https://www.flightconnections.com/route_schedule.php
Content-Type: application/x-www-form-urlencoded; charset=UTF-8
Accept: application/json, text/javascript, */*; q=0.01
X-Requested-With: XMLHttpRequest
Referer: https://www.flightconnections.com/flights-from-ist-to-gru

lang=en&dep=131&des=3056&ym=2026-06
```

The response is JSON with HTML fragments:

```text
schedule: month calendar HTML
timetable: schedule table rows
airlines[]: per-airline schedule HTML
```

The `timetable` HTML rows include `data-dates`, which indicates which days in the month the row applies to. For IST -> GRU in June 2026, both TK15 and TK215 had `29` in `data-dates`.

Validated rows for 2026-06-29:

```text
TK 15:  10:25 IST -> 17:45 GRU, Airbus A350-900
TK 215: 20:15 IST -> 03:30 GRU +1, Airbus A350-900
```
