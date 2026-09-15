# ===================================================
# STAGE 1: Builder (Dependency compilation & build)
# ===================================================
FROM python:3.11-slim AS builder

# Set the working directory inside the build container
WORKDIR /app

# Prevent Python from writing .pyc files and force unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system build tools required for compiling C extensions (e.g., psycopg2)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install packages into the user local directory (/root/.local)
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt



