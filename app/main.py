from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy import text
from sqlalchemy.orm import Session
from database import SessionLocal, engine
import crud
import models
from schemas import ItemCreate, ItemRead

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Kubernetes Local Lab API", version="1.0.0")


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.get("/readyz")
def readyz(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"status": "ready"}


@app.post("/items", response_model=ItemRead)
def create(item: ItemCreate, db: Session = Depends(get_db)):
    return crud.create_item(db, item.name, item.description)


@app.get("/items", response_model=list[ItemRead])
def read(db: Session = Depends(get_db)):
    return crud.get_items(db)


@app.get("/items/{item_id}", response_model=ItemRead)
def read_one(item_id: int, db: Session = Depends(get_db)):
    item = crud.get_item(db, item_id)
    if item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


@app.delete("/items/{item_id}")
def delete(item_id: int, db: Session = Depends(get_db)):
    item = crud.delete_item(db, item_id)
    if item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    return {"deleted": item_id}


@app.on_event("startup")
def startup():
    models.Base.metadata.create_all(bind=engine)
