#!/usr/bin/env python3
from os import environ
from dsmr_parser import telegram_specifications
from dsmr_parser.clients import SerialReader, SERIAL_SETTINGS_V4
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway

METRICS = [
    "CURRENT_ELECTRICITY_USAGE",
    "INSTANTANEOUS_CURRENT_L1",
    "INSTANTANEOUS_CURRENT_L2",
    "INSTANTANEOUS_CURRENT_L3",
]

gateway = environ.get("PROMETHEUS_PUSH_GATEWAY")

def main():
    serial_reader = SerialReader(
        device='/dev/ttyUSB0',
        serial_settings=SERIAL_SETTINGS_V4,
        telegram_specification=telegram_specifications.V4
    )
    registry = CollectorRegistry()
    gauges = {
    for metric in METRICS:
        g[metric] = Gauge(metric.lower(), metric.lower(), registry=registry)

    for telegram in serial_reader.read():
        for metric in METRICS:
            g[metric].set(getattr(telegram, metric).value)
        push_to_gateway(gateway, job="energy_meter", registry=registry)

if __name__ == '__main__':
        main()
