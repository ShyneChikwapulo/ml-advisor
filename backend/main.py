from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware  #causes browser to allow our fultter app to access our API

app = FastAPI()

app.add_middleware(
    CORSMiddleware,      #this is the middlewaer taht runs between the clien request (Flutter) and API endpoint
    allow_origins = ["*"],
    allow_methods = ["*"],
    allow_headers = ["*"],
)

@app.get("/ping")
def ping():                            #this function runs when someone visits /ping
    return {"status": "ok", "message": "ML Advisor API is running"}

@app.get("/models")
def get_models():
    return {"models":[]}


