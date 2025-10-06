import os, time
from datetime import datetime, timezone
from google.cloud import bigquery

PROJECT_ID = os.getenv("PROJECT_ID")
DATASET_ID = os.getenv("BQ_DATASET", "devops_trivia")
client = bigquery.Client(project=PROJECT_ID)

def insert_answer(username: str, question_id: str, is_correct: bool, response_time_ms: int):
    table = f"{PROJECT_ID}.{DATASET_ID}.responses"
    rows = [{
        "username": username,
        "question_id": question_id,
        "is_correct": is_correct,
        "response_time_ms": response_time_ms,
        "ts": datetime.now(timezone.utc).isoformat()
    }]
    errors = client.insert_rows_json(table, rows)
    if errors:
        raise RuntimeError(errors)

def fetch_leaderboard(limit: int = 10):
    q = f"""
      SELECT username, score, avg_response_ms, last_update
      FROM `{PROJECT_ID}.{DATASET_ID}.leaderboard`
      ORDER BY score DESC, avg_response_ms ASC
      LIMIT {limit}
    """
    return [dict(r) for r in client.query(q)]
