from fastapi import FastAPI, HTTPException, Body
from app.bq import insert_answer, fetch_leaderboard

app = FastAPI(title="DevOps Trivia", version="1.0.0")

@app.post("/answer")
def answer(payload: dict = Body(...)):
    try:
        insert_answer(
            username=payload["username"],
            question_id=payload["question_id"],
            is_correct=bool(payload["is_correct"]),
            response_time_ms=int(payload["response_time_ms"])
        )
        return {"status":"ok"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/leaderboard")
def leaderboard(limit: int = 10):
    return fetch_leaderboard(limit)

@app.get("/healthz")
def healthz():
    return {"status":"ok"}
