from fastapi import FastAPI
from pydantic import BaseModel
import httpx
import os
from dotenv import load_dotenv
import sys
sys.path.append('../knowledge_base')

# Load environment variables
load_dotenv()

app = FastAPI()

# Get OpenRouter API key from environment
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")

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
        # 1. Build the system prompt using your RAG knowledge base
        if KB_AVAILABLE:
            system_prompt = build_grounded_system_prompt(request.message)
        else:
            system_prompt = """You are ML Advisor, a specialist assistant for 
            recommending machine learning models for software bug prediction. 
            Answer based on research from Albattah & Alzahrani (2024)."""
        
        # 2. Check if API key is configured
        if not OPENROUTER_API_KEY:
            return {"response": "Error: OpenRouter API key not configured. Please check your environment variables."}
        
        # 3. Call OpenRouter API (instead of local Ollama)
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                'https://openrouter.ai/api/v1/chat/completions',
                headers={
                    'Authorization': f'Bearer {OPENROUTER_API_KEY}',
                    'Content-Type': 'application/json',
                },
                json={
                    'model': 'meta-llama/llama-3.2-3b-instruct',
                    'messages': [
                        {'role': 'system', 'content': system_prompt},
                        {'role': 'user', 'content': request.message}
                    ],
                    'max_tokens': 500,
                    'temperature': 0.3,
                }
            )
            
            # 4. Parse and return the response
            result = response.json()
            return {"response": result['choices'][0]['message']['content']}
            
    except httpx.TimeoutException:
        return {"response": "Error: The request timed out. Please try again."}
    except Exception as e:
        return {"response": f"Error: {str(e)}"}