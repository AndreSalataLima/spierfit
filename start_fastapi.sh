#!/bin/bash
cd /home/andresalatalima/code/AndreSalataLima/spierfit/fastapi_app
source .venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000
