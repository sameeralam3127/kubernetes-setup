from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from database import SessionLocal, engine
import models, crud

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/items")
def create(name: str, description: str, db: Session = Depends(get_db)):
    return crud.create_item(db, name, description)

@app.get("/items")
def read(db: Session = Depends(get_db)):
    return crud.get_items(db)

@app.get("/items/{item_id}")
def read_one(item_id: int, db: Session = Depends(get_db)):
    return crud.get_item(db, item_id)

@app.delete("/items/{item_id}")
def delete(item_id: int, db: Session = Depends(get_db)):
    return crud.delete_item(db, item_id)

@app.on_event("startup")
def startup():
    models.Base.metadata.create_all(bind=engine)