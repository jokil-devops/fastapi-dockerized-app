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


# ===================================================
# STAGE 2: Final (Minimal production image)
# ===================================================
FROM python:3.11-slim AS final

WORKDIR /app

# Set environment variables and append user binaries path to system PATH
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/root/.local/bin:${PATH}"

# Install only the lightweight runtime libraries needed for PostgreSQL
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copy pre-built Python dependencies from the builder stage
COPY --from=builder /root/.local /root/.local

# Copy application source code into the final container
COPY . .

# Expose port 8000 for the FastAPI server
EXPOSE 8000

# Entry point command: launch Uvicorn pointing to the main app module
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
