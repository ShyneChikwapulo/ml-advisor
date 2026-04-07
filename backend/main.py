from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from firebase_config import get_db

app = FastAPI(title="ML Advisor API")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database
db = get_db()

@app.get("/")
def root():
    return {"message": "ML Advisor API is running"}

@app.get("/ping")
def ping():
    return {"status": "ok", "message": "API is alive"}

@app.get("/test-db")
def test_database():
    try:
        docs = db.collection("models").limit(1).get()
        return {"status": "connected", "message": "Firebase is working"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.get("/models")
def get_all_models():
    try:
        docs = db.collection("models").stream()
        models = []
        for doc in docs:
            model_data = doc.to_dict()
            model_data["id"] = doc.id
            models.append(model_data)
        return {"models": models, "count": len(models)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/models/{model_id}")
def get_one_model(model_id: str):
    try:
        doc = db.collection("models").document(model_id).get()
        if not doc.exists:
            raise HTTPException(status_code=404, detail="Model not found")
        model_data = doc.to_dict()
        model_data["id"] = doc.id
        return model_data
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))