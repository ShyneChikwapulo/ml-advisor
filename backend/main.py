from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware  #causes browser to allow our fultter app to access our API
from firebase_config import get_db
app = FastAPI()

app.add_middleware(
    CORSMiddleware,      #this is the middlewaer taht runs between the clien request (Flutter) and API endpoint
    allow_origins = ["*"],
    allow_methods = ["*"],
    allow_headers = ["*"],
)

db = get_db()

@app.get("/ping")
def ping():
    return {"status": "ok", "message": "ML Advisor API is running"}

@app.get("/models")
def get_models():
    try:
        docs= db.collection("models").stream()
        models = []
        for doc in docs:
            model_data = doc.to_dict()
            model_data["id"] = doc.id
            models.append(model_data)
        return {"models": models}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))