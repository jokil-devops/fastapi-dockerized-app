from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
import json

from .database import SessionLocal
from .models import Product
from .cache import redis_client

router = APIRouter()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get("/products/{product_id}")
def get_product(product_id: int, db: Session = Depends(get_db)):

    cache_key = f"product:{product_id}"

    cached = redis_client.get(cache_key)

    if cached:
        return {
            "source": "cache",
            "data": json.loads(cached)
        }

    product = db.query(Product).filter(Product.id == product_id).first()

    if not product:
        return {"error": "Product not found"}

    data = {
        "id": product.id,
        "name": product.name,
        "description": product.description
    }

    redis_client.setex(cache_key, 60, json.dumps(data))

    return {
        "source": "database",
        "data": data
    }
