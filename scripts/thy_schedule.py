#!/usr/bin/env python3
"""Query Turkish Airlines flight status/schedule endpoints.

This is for trunk/operating flight timing, separate from MyIDTravel ZED
availability and fare automation.
"""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.request


BASE_URL = "https://www.turkishairlines.com"
BY_CITY_URL = f"{BASE_URL}/com.thy.web.online.deparr/deparr/departurearrivals/bycity"
BY_FLIGHT_URL = f"{BASE_URL}/com.thy.web.online.deparr/deparr/departurearrivals/byflight"
REFERER = f"{BASE_URL}/en-int/flights/flight-status/"


def post_json(url: str, body: dict, timeout: int) -> dict:
    req = urllib.request.Request(
        url,
        data=json.dumps(body).encode("utf-8"),
        headers={
            "User-Agent": "Mozilla/5.0",
            "Referer": REFERER,
            "Origin": BASE_URL,
            "Content-Type": "application/json",
            "Accept": "application/json, text/plain, */*",
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=timeout) as response:
        return json.load(response)


def moneyless_segment_summary(segment: dict) -> dict:
    airline = segment.get("airline") or {}
    operating_airline = segment.get("operatingAirline") or {}
    origin = segment.get("originAirport") or {}
    destination = segment.get("destinationAirport") or {}
    departure = segment.get("departureDateTimeISO") or {}
    arrival = segment.get("arrivalDateTimeISO") or {}
    estimated_departure = segment.get("estimatedDepartureDateTime")
    estimated_arrival = segment.get("estimatedArrivalDateTime")
    return {
        "flight": f"{airline.get('shortName') or 'TK'}{segment.get('flightNumber')}",
        "operatingFlight": f"{operating_airline.get('shortName') or 'TK'}{segment.get('operatingFlightNumber') or segment.get('flightNumber')}",
        "status": segment.get("flightStatus"),
        "from": origin.get("code"),
        "to": destination.get("code"),
        "departureLocal": departure.get("dateTimeLocal"),
        "arrivalLocal": arrival.get("dateTimeLocal"),
        "departureUtc": departure.get("dateTimeUtc"),
        "arrivalUtc": arrival.get("dateTimeUtc"),
        "estimatedDepartureEpochMs": estimated_departure,
        "estimatedArrivalEpochMs": estimated_arrival,
        "gate": segment.get("gate"),
        "departureTerminal": segment.get("departureTerminalInfo"),
        "arrivalTerminal": segment.get("arrivalTerminalInfo"),
        "aircraftType": segment.get("aircraftType"),
        "durationMs": segment.get("journeyDuration"),
    }


def summarize(data: dict) -> dict:
    flights = data.get("data", {}).get("flights") or []
    return {
        "type": data.get("type"),
        "hasNoFlight": data.get("data", {}).get("hasNoFlight"),
        "flightCount": len(flights),
        "flights": [
            {
                "segments": [moneyless_segment_summary(segment) for segment in flight.get("segments", [])],
            }
            for flight in flights
        ],
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Search Turkish Airlines official schedule/status API.")
    parser.add_argument("date", help="Departure date in YYYY-MM-DD")
    parser.add_argument("--origin", help="Origin airport, e.g. IST")
    parser.add_argument("--destination", help="Destination airport, e.g. GRU")
    parser.add_argument("--flight-number", help="Numeric TK flight number, e.g. 15 or 215")
    parser.add_argument("--raw", action="store_true", help="Print raw API JSON")
    parser.add_argument("--timeout", type=int, default=30)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.flight_number:
        body = {
            "flightNumber": args.flight_number.removeprefix("TK"),
            "departureDate": args.date,
        }
        url = BY_FLIGHT_URL
    else:
        if not args.origin or not args.destination:
            print("error: --origin and --destination are required unless --flight-number is used", file=sys.stderr)
            return 2
        body = {
            "departureDate": args.date,
            "departures": [args.origin.upper()],
            "arrivals": [args.destination.upper()],
            "lang": "en",
        }
        url = BY_CITY_URL

    try:
        data = post_json(url, body, args.timeout)
    except (urllib.error.URLError, TimeoutError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    output = data if args.raw else summarize(data)
    print(json.dumps(output, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
