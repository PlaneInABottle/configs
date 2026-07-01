#!/usr/bin/env python3
"""Query MyIDTravel flight schedules from an active agent-browser session.

This reuses the logged-in browser session for JSESSIONID, csrf, and tabId.
It does not print session credentials.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess
import sys
import urllib.error
import urllib.request


SCHEDULE_URL = "https://www.myidtravel.com/myidtravel/json/booking/flightschedule"
FLIGHT_SELECTION_URL = "https://www.myidtravel.com/myidtravel/json/booking/flightselection"
FARES_URL = "https://www.myidtravel.com/myidtravel/json/booking/fares"
REFERER = "https://www.myidtravel.com/myidtravel/rui/main/find-flights/travel-history/flight-list"
FARE_REFERER = "https://www.myidtravel.com/myidtravel/rui/main/find-flights/travel-history/flight-list/fare-information"


def agent_browser(session: str, *args: str) -> str:
    cmd = ["agent-browser", "--session", session, *args]
    return subprocess.check_output(cmd, text=True).strip()


def browser_eval(session: str, expression: str) -> str:
    raw = agent_browser(session, "eval", expression)
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return raw.strip('"')


def myid_cookie_header(session: str) -> str:
    raw = agent_browser(session, "cookies", "get", "--json")
    cookies = json.loads(raw)["data"]["cookies"]
    pairs = []
    for cookie in cookies:
        if cookie.get("domain") == "www.myidtravel.com" and cookie.get("path", "").startswith("/myidtravel"):
            pairs.append(f"{cookie['name']}={cookie['value']}")
    if not pairs:
        raise RuntimeError("No www.myidtravel.com /myidtravel cookies found. Is the browser session logged in?")
    return "; ".join(pairs)


def session_context(args: argparse.Namespace) -> dict:
    if args.session_file:
        data = json.loads(Path(args.session_file).read_text())
        for key in ("csrf", "tabId", "cookie"):
            if not data.get(key):
                raise RuntimeError(f"Missing {key} in session file {args.session_file}")
        return {
            "csrf": data["csrf"],
            "tabId": data["tabId"],
            "cookie": data["cookie"],
        }

    csrf = browser_eval(args.session, 'localStorage.getItem("csrf")')
    tab_id = browser_eval(args.session, 'sessionStorage.getItem("tabId")')
    if not csrf or not tab_id:
        raise RuntimeError("Missing csrf or tabId in browser storage. Open MyIDTravel in the session first.")
    return {
        "csrf": csrf,
        "tabId": tab_id,
        "cookie": myid_cookie_header(args.session),
    }


def post_json(url: str, body: dict, context: dict, timeout: int, referer: str = REFERER) -> dict:
    body = {
        **body,
        "csrf": context["csrf"],
        "tabId": context["tabId"],
    }
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Origin": "https://www.myidtravel.com",
        "Referer": referer,
        "Cookie": context["cookie"],
        "User-Agent": "Mozilla/5.0",
    }
    req = urllib.request.Request(
        url,
        data=json.dumps(body).encode("utf-8"),
        headers=headers,
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=timeout) as response:
        return json.load(response)


def request_schedule(args: argparse.Namespace, context: dict) -> dict:
    body = {
        "translations": [],
        "travelStatus": args.travel_status,
        "airline": args.airline or "",
        "routings": [
            {
                "origin": args.origin.upper(),
                "destination": args.destination.upper(),
                "date": args.date,
                "compartment": args.compartment.upper(),
                "time": args.time,
            }
        ],
        "nonStop": args.nonstop,
        "filterCodesharedFlights": None,
        "travelType": "ONE_WAY",
        "sevenDaySearchRequested": args.seven_day,
    }
    return post_json(SCHEDULE_URL, body, context, args.timeout)


def summarize_segment(segment: dict) -> dict:
    marketing = segment.get("marketingAirline") or {}
    operating = segment.get("operatingAirline") or {}
    origin = segment.get("from") or {}
    destination = segment.get("to") or {}
    relevant_seats = [
        {
            "bookingClass": seat.get("bookingClass"),
            "quantity": seat.get("quantity"),
            "chance": seat.get("chance"),
        }
        for seat in segment.get("jseats", [])
        if seat.get("relevant4Request")
    ]
    return {
        "flight": segment.get("flightNumber"),
        "marketingAirline": marketing.get("code"),
        "operatingAirline": operating.get("code"),
        "from": origin.get("code"),
        "to": destination.get("code"),
        "departure": segment.get("departureTime"),
        "arrival": segment.get("arrivalTime"),
        "date": segment.get("date"),
        "duration": segment.get("segmentDuration"),
        "chance": segment.get("chance"),
        "travelStatus": segment.get("travelStatus"),
        "kindOfTravel": segment.get("kindOfTravel"),
        "info": segment.get("info") or None,
        "requestSeats": relevant_seats,
    }


def filtered_flights(data: dict, selectable_only: bool, max_legs: int | None) -> list[dict]:
    routings = data.get("routings") or []
    routing = routings[0] if routings else {}
    flights = routing.get("flights") or []
    filtered = [flight for flight in flights if flight.get("selectable")] if selectable_only else list(flights)
    if max_legs is not None:
        filtered = [flight for flight in filtered if len(flight.get("segments", [])) <= max_legs]
    return filtered


def summarize(data: dict, selectable_only: bool, max_legs: int | None, fare: dict | list[dict] | None = None) -> dict:
    routings = data.get("routings") or []
    routing = routings[0] if routings else {}
    flights = routing.get("flights") or []
    filtered = filtered_flights(data, selectable_only, max_legs)
    output = {
        "success": data.get("success"),
        "messages": [
            {key: msg.get(key) for key in ("type", "errorNo", "text") if key in msg}
            for msg in (data.get("messages") or [])
        ],
        "routingInfo": routing.get("routingInfo"),
        "totalFlights": len(flights),
        "selectableFlights": sum(1 for flight in flights if flight.get("selectable")),
        "maxLegs": max_legs,
        "returnedFlights": len(filtered),
        "filterConfigurations": data.get("filterConfigurations"),
        "flights": [
            {
                "id": flight.get("id"),
                "selectable": flight.get("selectable"),
                "legCount": len(flight.get("segments", [])),
                "chance": flight.get("chance"),
                "duration": flight.get("duration"),
                "info": flight.get("info") or None,
                "segments": [summarize_segment(segment) for segment in flight.get("segments", [])],
            }
            for flight in filtered
        ],
    }
    if isinstance(fare, list):
        output["fares"] = fare
    elif fare is not None:
        output["fare"] = fare
    return output


def request_fare(args: argparse.Namespace, context: dict, flight_id: int) -> dict:
    selection_body = {
        "translations": [],
        "flights": [flight_id],
    }
    selection = post_json(FLIGHT_SELECTION_URL, selection_body, context, args.timeout, REFERER)
    if not selection.get("success"):
        return {"success": False, "stage": "flightselection", "response": selection}

    fare_body = {
        "clientType": "DESKTOP",
        "responseType": "OPTIMIZED",
        "containerInformations": [{"identifier": "FaresPage"}],
        "translations": [],
        "myDutyTripId": None,
    }
    fare = post_json(FARES_URL, fare_body, context, args.timeout, FARE_REFERER)
    return {"success": fare.get("success"), "stage": "fares", "response": fare}


def summarize_payment_methods(fare: dict) -> list[dict]:
    methods = []
    for payment in fare.get("payments") or []:
        for method in payment.get("paymentMethods") or []:
            methods.append(
                {
                    "id": method.get("id"),
                    "type": method.get("type"),
                    "typeText": method.get("typeText"),
                    "amount": method.get("amount"),
                    "displayPayment": method.get("displayPayment"),
                    "defaultSelected": method.get("defaultSelected"),
                    "requiresBillingAddress": method.get("requiresBillingAddress"),
                }
            )
    return methods


def summarize_fare(fare_result: dict, flight_id: int, flight_index: int) -> dict:
    fare = fare_result.get("response") or {}
    if not fare_result.get("success"):
        return {
            "success": False,
            "stage": fare_result.get("stage"),
            "flightId": flight_id,
            "flightIndex": flight_index,
            "messages": [
                {key: msg.get(key) for key in ("type", "errorNo", "text") if key in msg}
                for msg in (fare.get("messages") or [])
            ],
        }

    employees = fare.get("employees") or []
    first_fare = (employees[0].get("fares") or [{}])[0] if employees else {}
    first_price = (first_fare.get("prices") or [{}])[0]
    price = first_price.get("price") or {}
    return {
        "success": True,
        "flightId": flight_id,
        "flightIndex": flight_index,
        "preferredTotal": first_fare.get("total"),
        "airline": first_price.get("airline"),
        "legs": first_price.get("legs"),
        "fare": price.get("fare"),
        "taxes": price.get("taxes"),
        "fee": price.get("fee"),
        "sumOfTaxesAndFee": price.get("sumOfAllTaxesAndFee"),
        "chargedTotal": price.get("total"),
        "preferredCurrency": price.get("preferredCurrency"),
        "paymentMethods": summarize_payment_methods(first_fare),
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Search MyIDTravel schedules via an active agent-browser session.")
    parser.add_argument("origin", help="Origin airport/city code, e.g. DPS or GRU")
    parser.add_argument("destination", help="Destination airport/city code, e.g. IST or RIO")
    parser.add_argument("date", help="Departure date in YYYY-MM-DD")
    parser.add_argument("--session", default="tk-stealth", help="agent-browser session name")
    parser.add_argument("--session-file", help="JSON file containing saved MyIDTravel csrf, tabId, and Cookie header")
    parser.add_argument("--airline", default="", help="Optional airline filter, e.g. TK")
    parser.add_argument("--compartment", default="Y", help="Compartment code, default Y")
    parser.add_argument("--time", default="00:00", help="Departure time, default 00:00")
    parser.add_argument("--travel-status", type=int, default=1, help="Travel status id, default 1 / R2 Standby")
    parser.add_argument("--nonstop", action="store_true", help="Request nonstop flights only")
    parser.add_argument("--seven-day", action="store_true", help="Request seven-day search if allowed")
    parser.add_argument("--all", action="store_true", help="Return all flights, including unselectable")
    parser.add_argument("--max-legs", type=int, help="Return only itineraries with this many legs or fewer")
    parser.add_argument("--price-all", action="store_true", help="Select and price every returned itinerary")
    parser.add_argument("--price-first", action="store_true", help="Select and price the first returned itinerary")
    parser.add_argument("--price-index", type=int, help="Select and price this zero-based returned itinerary index")
    parser.add_argument("--raw", action="store_true", help="Print raw API JSON")
    parser.add_argument("--timeout", type=int, default=30)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    price_modes = sum(1 for enabled in (args.price_all, args.price_first, args.price_index is not None) if enabled)
    if price_modes > 1:
        print("error: use only one of --price-all, --price-first, or --price-index", file=sys.stderr)
        return 2

    try:
        context = session_context(args)
        data = request_schedule(args, context)
    except (RuntimeError, urllib.error.URLError, subprocess.CalledProcessError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    fares = None
    price_index = 0 if args.price_first else args.price_index
    if args.price_all or price_index is not None:
        flights = filtered_flights(data, selectable_only=not args.all, max_legs=args.max_legs)
    if args.price_all:
        fares = []
        for index, flight in enumerate(flights):
            flight_id = flight.get("id")
            if flight_id is None:
                fares.append({"success": False, "flightIndex": index, "messages": [{"text": "selected flight has no id"}]})
                continue
            try:
                fares.append(summarize_fare(request_fare(args, context, flight_id), flight_id, index))
            except (urllib.error.URLError, subprocess.CalledProcessError) as exc:
                fares.append({"success": False, "flightId": flight_id, "flightIndex": index, "messages": [{"text": str(exc)}]})
    elif price_index is not None:
        if price_index < 0 or price_index >= len(flights):
            print(f"error: price index {price_index} is outside returned flight range 0..{len(flights) - 1}", file=sys.stderr)
            return 1
        flight_id = flights[price_index].get("id")
        if flight_id is None:
            print(f"error: selected flight at index {price_index} has no id", file=sys.stderr)
            return 1
        try:
            fares = summarize_fare(request_fare(args, context, flight_id), flight_id, price_index)
        except (urllib.error.URLError, subprocess.CalledProcessError) as exc:
            print(f"error: {exc}", file=sys.stderr)
            return 1

    output = data if args.raw else summarize(data, selectable_only=not args.all, max_legs=args.max_legs, fare=fares)
    print(json.dumps(output, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
