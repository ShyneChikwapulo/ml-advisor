from fastapi import FastAPI
from pydantic import BaseModel
import ollama
import sys
sys.path.append('../knowledge_base')

app = FastAPI()

# Import your existing knowledge base
try:
    from knowledge_base.retriever import build_grounded_system_prompt
    KB_AVAILABLE = True
except Exception:
    KB_AVAILABLE = False

class ChatRequest(BaseModel):
    message: str

@app.post("/chat")
async def chat(request: ChatRequest):
    try:
        if KB_AVAILABLE:
            system_prompt = build_grounded_system_prompt(request.message)
        else:
            system_prompt = """You are ML Advisor, a specialist assistant for 
            recommending machine learning models for software bug prediction. 
            Answer based on research from Albattah & Alzahrani (2024)."""
        
        response = ollama.chat(
            model='llama3.2',
            messages=[
                {'role': 'system', 'content': system_prompt},
                {'role': 'user', 'content': request.message}
            ],
            options={'temperature': 0.3}
        )
        return {"response": response['message']['content']}
    except Exception as e:
        return {"response": f"Error: {str(e)}. Make sure Ollama is running."}