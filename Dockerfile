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
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# ===================================================
# STAGE 2: Final (Corrected)
# ===================================================
FROM python:3.11-slim AS final

WORKDIR /app

# 1. Create non-root user FIRST
RUN useradd --create-home appuser

# 2. Point PATH to appuser's directory, NOT /root/
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/appuser/.local/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# 3. Copy files to /home/appuser/.local and set ownership
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local
COPY --chown=appuser:appuser . .

USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

