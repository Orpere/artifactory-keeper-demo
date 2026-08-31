# ---------------------------------------------------------------------------
# greet-service — minimal container image for the Artifact Keeper demo
# ---------------------------------------------------------------------------
# Build:
#   docker build -t greet-service:1.0.0 .
#
# Run (locally, without pushing):
#   docker run --rm -p 8080:8080 greet-service:1.0.0
#   curl http://localhost:8080/
#
# Push to Artifact Keeper (see docs/05-scenario-docker.md):
#   docker tag greet-service:1.0.0 \
#     artifact-keeper.devopsexpress.site/docker-local/greet-service:1.0.0
#   docker push artifact-keeper.devopsexpress.site/docker-local/greet-service:1.0.0
# ---------------------------------------------------------------------------

FROM python:3.13-alpine

# Metadata — visible in the registry UI and via `docker inspect`
LABEL org.opencontainers.image.title="greet-service" \
      org.opencontainers.image.description="Demo service pushed to Artifact Keeper" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://artifact-keeper.devopsexpress.site"

# Non-root user — good container hygiene (the registry's security scanner
# checks for this kind of thing)
RUN adduser -D -u 10001 appuser

WORKDIR /app

# Copy only what we need (see .dockerignore)
COPY app.py .

# Drop privileges before running
USER appuser

EXPOSE 8080

ENV SERVICE_NAME=greet-service \
    SERVICE_VERSION=1.0.0 \
    PORT=8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1

ENTRYPOINT ["python3", "app.py"]
