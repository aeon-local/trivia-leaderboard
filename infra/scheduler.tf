resource "google_bigquery_data_transfer_config" "leaderboard_job" {
  display_name           = "build-leaderboard"
  data_source_id         = "scheduled_query"
  destination_dataset_id = google_bigquery_dataset.trivia.dataset_id
  params = {
    destination_table_name_template = "leaderboard"
    write_disposition               = "WRITE_TRUNCATE"
    query = <<-SQL
      CREATE OR REPLACE TABLE `${var.project_id}.${var.dataset_id}.leaderboard` AS
      SELECT
        username,
        SUM(CASE WHEN is_correct THEN 10 ELSE 0 END) AS score,
        AVG(response_time_ms) AS avg_response_ms,
        CURRENT_TIMESTAMP() AS last_update
      FROM `${var.project_id}.${var.dataset_id}.responses`
      GROUP BY username
      ORDER BY score DESC, avg_response_ms ASC;
    SQL
  }
  schedule = "every 5 minutes"
}
