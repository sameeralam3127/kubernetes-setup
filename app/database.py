from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import time

DATABASE_URL = "postgresql://postgres:postgres@postgres:5432/appdb"

engine = None

for i in range(15):
    try:
        print(f"Attempt {i+1}: Connecting to DB...")
        engine = create_engine(DATABASE_URL)
        conn = engine.connect()
        conn.close()
        print("✅ DB Connected")
        break
    except Exception as e:
        print("❌ DB not ready, retrying...", e)
        time.sleep(2)

if engine is None:
    raise Exception("❌ Could not connect to DB")

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)