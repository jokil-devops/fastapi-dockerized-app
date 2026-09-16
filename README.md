# 🚀 High-Performance FastAPI Cache System

A production-ready REST API built with **FastAPI**, **Redis**, and **PostgreSQL**, fully containerized using a **Multi-Stage Dockerfile** and orchestrated via **Docker Compose**.

This project demonstrates the **Cache-First Architecture Pattern** to significantly reduce database load and decrease response times for read-heavy operations.

---

## 🏗️ Architecture & How It Works

Instead of querying PostgreSQL on every request, the application introduces Redis as an in-memory caching layer:
