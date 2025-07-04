# --------- Stage 1: Base image ---------
FROM python:3.9-slim AS builder

WORKDIR /app/backend

# Install system dependencies for mysqlclient
RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    build-essential \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# --------- Stage 2: Final image ---------
FROM python:3.9-slim

WORKDIR /app/backend

COPY --from=builder /usr/local /usr/local
COPY . .

EXPOSE 8000

CMD ["gunicorn", "notesapp.wsgi:application", "--bind", "0.0.0.0:8000"]
