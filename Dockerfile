# ----------- STAGE 1: Build dependencies ----------- #
FROM python:3.9-slim as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && \
    apt-get install -y gcc default-libmysqlclient-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# ----------- STAGE 2: Runtime container ----------- #
FROM python:3.9-slim

WORKDIR /app/backend

# Copy installed python packages from builder stage
COPY --from=builder /usr/local /usr/local

# Copy actual app code
COPY . .

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

EXPOSE 8000

# Run migrations at runtime and start the server
CMD ["sh", "-c", "python manage.py migrate && gunicorn notesapp.wsgi:application --bind 0.0.0.0:8000"]
