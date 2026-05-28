from fastapi import FastAPI
from pydantic import BaseModel
import ollama
import sys
import os

# safer path handling
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../knowledge_base')))

app = FastAPI()

# Import knowledge base safely
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
        # System prompt selection
        if KB_AVAILABLE:
            system_prompt = build_grounded_system_prompt(request.message)
        else:
            system_prompt = (
                "You are ML Advisor, a specialist assistant for recommending "
                "machine learning models for software bug prediction. "
                "Base your answers on Albattah & Alzahrani (2024)."
            )

        # Ollama call
        response = ollama.chat(
            model="llama3.2",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": request.message},
            ],
            options={"temperature": 0.3},
        )

        return {"response": response["message"]["content"]}

    except Exception as e:
        return {
            "response": f"Error: {str(e)}. Make sure Ollama is running."
        }


