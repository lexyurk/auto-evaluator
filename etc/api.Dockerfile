FROM python:3.10-slim

ENV PYTHONPATH=/app:$PYTHONPATH

RUN apt-get update && apt-get install -y \
    cmake \
    build-essential

WORKDIR /app

COPY api/requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY api /app/

CMD ["uvicorn", "evaluator_app:app"]
