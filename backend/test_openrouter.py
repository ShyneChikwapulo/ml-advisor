import httpx
import os
from dotenv import load_dotenv

load_dotenv()

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")

async def test_openrouter():
    async with httpx.AsyncClient() as client:
        response = await client.post(
            'https://openrouter.ai/api/v1/chat/completions',
            headers={
                'Authorization': f'Bearer {OPENROUTER_API_KEY}',
                'Content-Type': 'application/json',
            },
            json={
                'model': 'meta-llama/llama-3.2-3b-instruct',
                'messages': [
                    {'role': 'system', 'content': 'You are a helpful assistant.'},
                    {'role': 'user', 'content': 'Say hello'}
                ]
            }
        )
        print("Status Code:", response.status_code)
        print("Response Text:", response.text)
        print("Full Response JSON:", response.json())

import asyncio
asyncio.run(test_openrouter())