output "dataset"    { value = google_bigquery_dataset.trivia.dataset_id }
output "responses"  { value = google_bigquery_table.responses.table_id }
output "leaderboard"{ value = google_bigquery_table.leaderboard.table_id }
