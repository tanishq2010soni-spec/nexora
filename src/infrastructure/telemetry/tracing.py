import os
from typing import Optional

from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.sdk.resources import Resource, SERVICE_NAME, DEPLOYMENT_ENVIRONMENT

from src.config import settings
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)


def setup_telemetry() -> None:
    """Initialize OpenTelemetry SDK with OTLP exporter."""
    resource = Resource.create({
        SERVICE_NAME: settings.APP_NAME,
        DEPLOYMENT_ENVIRONMENT: settings.ENVIRONMENT,
        "service.version": "1.0.0",
        "service.namespace": "nexora",
    })

    # ─── Tracing ────────────────────────────────────────────────────────
    tracer_provider = TracerProvider(resource=resource)

    # Always add console exporter for debugging
    tracer_provider.add_span_processor(
        BatchSpanProcessor(ConsoleSpanExporter())
    )

    # Add OTLP exporter if endpoint configured
    otlp_endpoint = os.environ.get("OTEL_EXPORTER_OTLP_ENDPOINT")
    if otlp_endpoint:
        try:
            from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
            otlp_exporter = OTLPSpanExporter(
                endpoint=otlp_endpoint,
                insecure=True,
            )
            tracer_provider.add_span_processor(
                BatchSpanProcessor(otlp_exporter, max_export_batch_size=512)
            )
            logger.info("OTLP tracing exporter configured", endpoint=otlp_endpoint)
        except Exception as e:
            logger.warning("Failed to configure OTLP tracing exporter", error=str(e))

    trace.set_tracer_provider(tracer_provider)
    logger.info("OpenTelemetry tracing initialized")


    # ─── Metrics ────────────────────────────────────────────────────────
    metric_readers = []
    if otlp_endpoint:
        try:
            from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
            metric_exporter = OTLPMetricExporter(
                endpoint=otlp_endpoint,
                insecure=True,
            )
            metric_readers.append(PeriodicExportingMetricReader(metric_exporter))
        except Exception as e:
            logger.warning("Failed to configure OTLP metrics exporter", error=str(e))

    if metric_readers:
        meter_provider = MeterProvider(resource=resource, metric_readers=metric_readers)
        metrics.set_meter_provider(meter_provider)
        logger.info("OpenTelemetry metrics initialized")


def get_tracer(name: str = "nexora") -> trace.Tracer:
    """Get a named tracer instance."""
    return trace.get_tracer(name)
