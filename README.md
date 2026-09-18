# 🚀 High-Performance FastAPI Cache System

A production-ready REST API built with **FastAPI**, **Redis**, and **PostgreSQL**, fully containerized using a **Multi-Stage Dockerfile** and orchestrated via **Docker Compose**.

This project demonstrates the **Cache-First Architecture Pattern** to significantly reduce database load and decrease response times for read-heavy operations.

---

## 🏗️ Architecture & How It Works

Instead of querying PostgreSQL on every request, the application introduces Redis as an in-memory caching layer:





               ┌─────────────────────────┐
               │   1. Check Redis Cache  │
               └────────────┬────────────┘
                            │
                 ┌──────────┴──────────┐
                 │                     │
            [ Cache HIT ]        [ Cache MISS ]
                 │                     │
                 ▼                     ▼
          Return instantly       Query PostgreSQL DB
          (Latency: ~2ms)              │
                                       ▼
                                 Save result to Redis (TTL)
                                       │
                                       ▼
                                 Return response
                                 (Latency: ~50ms)



1. **Cache Read (HIT):** Requests for previously queried data are served directly from Redis RAM in milliseconds.
2. **Cache Read (MISS):** On a cache miss, data is fetched from PostgreSQL, saved to Redis with a TTL (Time-To-Live), and returned to the client.
3. **Cache Invalidation:** Updating or deleting data clears the corresponding Redis keys to prevent serving stale data.

---

## 🛠️ Tech Stack

* **Framework:** [FastAPI](https://fastapi.tiangolo.com/) (Python 3.11)
* **Primary Database:** [PostgreSQL 15](https://www.postgresql.org/)
* **In-Memory Cache:** [Redis 7](https://redis.io/)
* **ORM:** [SQLAlchemy](https://www.sqlalchemy.org/)
* **Containerization:** Docker (Multi-Stage Build with `python -m venv`)
* **Orchestration:** Docker Compose V2

---

## 🐳 Docker Multi-Stage Optimization

The `Dockerfile` utilizes a 2-stage build pipeline to ensure minimal image size and maximum security:

* **Stage 1 (Builder):** Installs build tools (`gcc`, `libpq-dev`), creates an isolated Python virtual environment (`/opt/venv`), and installs dependencies.
* **Stage 2 (Final):** Copies only the compiled `/opt/venv` binaries into a clean, lightweight `python:3.11-slim` runtime environment, running under a non-root system user (`appuser`).

---

## 🚀 Quick Start

### Prerequisites
* Docker Engine 20.10+
* Docker Compose V2

### 1. Clone the repository
```bash
git clone https://github.com/jokil-devops/fastapi-jokil-devops
cd fastapi-dockerized-app

### 2. Environment Setup
Copy the example environment file:
cp .env.example .env

### 3. Build & Run Containers
Start all services in detached mode:
docker compose up -d --build

### 4. Verify Running Services
Check that all containers are healthy:
docker compose ps


