#!/bin/bash

PROJECT=sndp-next
BUCKET="gs://${PROJECT}-ml"
GCS_PATH="${BUCKET}/movielens"
GCS_TRAINING_INPUT_DIR="gs://sndp-next-bucket/movielens"
PREPROCESS_OUTPUT="${GCS_PATH}/movielens_$(date +%Y%m%d_%H%M%S)"

echo "=== Starting Preprocessing ==="

python preprocess.py \
  --input_dir "${GCS_TRAINING_INPUT_DIR}" \
  --output_dir "${PREPROCESS_OUTPUT}" \
  --percent_eval 20 \
  --project_id ${PROJECT} \
  --negative_sample_ratio 1 \
  --negative_sample_label 0.0 \
  --eval_type ranking \
  --eval_score_threshold 4.5 \
  --num_ranking_candidate_movie_ids 1000 \
  --partition_random_seed 0 \
  --cloud \
  --max_num_workers 10

echo "=== Preprocessing Complete ==="

