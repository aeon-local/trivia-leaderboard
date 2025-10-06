# 🧠 DevOps Trivia Leaderboard
**Challenge de BigQuery + Terraform + Docker + Jenkins + Cloud Run**

## 🎯 Descripción
En este desafío crearás una API en **FastAPI**, desplegada automáticamente en **Cloud Run** mediante un pipeline en **Jenkins**, que almacena los resultados de un **Trivia DevOps** en **BigQuery**.

Toda la infraestructura de BigQuery (dataset, tablas, y consultas programadas) será creada con **Terraform**.

Al final tendrás:
- Una API funcional (Dockerizada).
- Pipeline CI/CD (Jenkins en VM GCP).
- Infraestructura reproducible (Terraform).
- Dashboard de puntajes en BigQuery.

## ⚙️ Arquitectura general
```mermaid
graph TD
    A[Usuario - Frontend o CURL] -->|POST /answer| B[Cloud Run (FastAPI)]
    B -->|Insert Rows JSON| C[BigQuery: Table responses]
    D[Terraform] -->|Crea dataset, tablas y jobs| C
    E[Scheduled Query] -->|Actualiza leaderboard cada 5 min| F[Table leaderboard]
    B -->|GET /leaderboard| F
    G[Jenkins VM] -->|CI/CD| B
```

## 🧩 Componentes principales
| Componente | Descripción |
|-------------|--------------|
| **BigQuery** | Almacena las respuestas del trivia y calcula el leaderboard. |
| **Terraform** | Crea el dataset, tablas y consulta programada. |
| **FastAPI** | API REST que recibe respuestas y expone el ranking. |
| **Docker** | Empaqueta la aplicación para su despliegue. |
| **Jenkins** | Ejecuta el pipeline CI/CD desde una VM en GCP. |
| **Cloud Run** | Servicio serverless donde corre la API. |

## 🏗️ Infraestructura con Terraform
Archivos clave (`infra/`):
- `main.tf`: Configura el provider de Google Cloud.
- `bq.tf`: Crea dataset y tablas (`responses`, `leaderboard`).
- `scheduler.tf`: Crea la consulta programada (actualiza ranking).

### Comandos básicos
```bash
cd infra/
terraform init
terraform apply -var="project_id=tu-proyecto-gcp"
```

## 💡 Lógica del leaderboard (SQL generado por Terraform)
```sql
CREATE OR REPLACE TABLE `devops_trivia.leaderboard` AS
SELECT
  username,
  SUM(CASE WHEN is_correct THEN 10 ELSE 0 END) AS score,
  AVG(response_time_ms) AS avg_response_ms,
  CURRENT_TIMESTAMP() AS last_update
FROM `devops_trivia.responses`
GROUP BY username
ORDER BY score DESC, avg_response_ms ASC;
```

## 🐍 API (FastAPI)
Endpoints principales:
- `POST /answer` → Envía una respuesta del trivia
- `GET /leaderboard` → Muestra el ranking
- `GET /healthz` → Verificación de salud

## 🧰 Jenkins (CI/CD)
Etapas principales:
1. Checkout
2. GCloud Auth
3. Build & Push
4. Deploy Cloud Run
5. Smoke Test

## 🧱 Dockerfile
```dockerfile
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/*
RUN useradd -m appuser
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app ./app
USER appuser
CMD exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT}
```

## 🚀 Flujo completo
1. Terraform crea toda la infraestructura.
2. Jenkins ejecuta el pipeline (build + deploy).
3. API recibe respuestas → BigQuery.
4. Scheduled Query actualiza leaderboard.
5. Se consulta con `/leaderboard`.

## 🏁 Resultado esperado
API en Cloud Run y dashboard de puntajes en BigQuery.
