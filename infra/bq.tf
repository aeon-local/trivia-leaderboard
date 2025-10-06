resource "google_bigquery_dataset" "trivia" {
  dataset_id = var.dataset_id
  location   = var.location
}

resource "google_bigquery_table" "responses" {
  dataset_id = google_bigquery_dataset.trivia.dataset_id
  table_id   = "responses"
  schema     = jsonencode([
    {name="username", type="STRING", mode="REQUIRED"},
    {name="question_id", type="STRING", mode="REQUIRED"},
    {name="is_correct", type="BOOL", mode="REQUIRED"},
    {name="response_time_ms", type="INT64", mode="REQUIRED"},
    {name="ts", type="TIMESTAMP", mode="REQUIRED"}
  ])
  time_partitioning { type = "DAY"; field = "ts" }
}

# Tabla destino del leaderboard (sobrescrita por scheduled query)
resource "google_bigquery_table" "leaderboard" {
  dataset_id = google_bigquery_dataset.trivia.dataset_id
  table_id   = "leaderboard"
  schema     = jsonencode([
    {name="username", type="STRING", mode="REQUIRED"},
    {name="score", type="INT64", mode="REQUIRED"},
    {name="avg_response_ms", type="FLOAT", mode="REQUIRED"},
    {name="last_update", type="TIMESTAMP", mode="REQUIRED"}
  ])
}
