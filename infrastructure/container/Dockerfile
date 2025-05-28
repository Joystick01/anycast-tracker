FROM python:3.12-slim AS base

WORKDIR /app

ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

RUN apt-get update && \
    apt-get install -y mtr \
    && rm -rf /var/lib/apt/lists/*



FROM base AS builder

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

RUN pip install poetry==2.1.3

COPY pyproject.toml poetry.lock ./

RUN poetry install --no-root && rm -rf $POETRY_CACHE_DIR;



FROM base AS runtime

ENV AWS_ACCESS_KEY_ID=fill_me_in \
    AWS_SECRET_ACCESS_KEY=fill_me_in \
    AWS_DEFAULT_REGION=fill_me_in \
    DYNAMO_DYNAMODB_TABLE_V4=fill_me_in \
    DYNAMO_DYNAMODB_TABLE_V6=fill_me_in \
    CONTAINER_REGION=fill_me_in \
    COUNT=5

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY src ./src

WORKDIR /app/src

ENTRYPOINT ["python", "-m", "anycast_tracker"]