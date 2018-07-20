#!/bin/bash

PROJECT=sndp-next
BUCKET="gs://${PROJECT}-cmle"
GCS_PATH="${BUCKET}/movielens"
GCS_TRAINING_INPUT_DIR="gs://sndp-next-bucket/movielens"
# PREPROCESS_OUTPUT="${GCS_PATH}/movielens_$(date +%Y%m%d_%H%M%S)"
PREPROCESS_OUTPUT="${GCS_PATH}/movielens_20180719_231341"

echo "=== Submitting Training Jobs ==="

JOB_ID="movielens_deep_$(date +%Y%m%d_%H%M%S)"

gcloud ml-engine jobs submit training "$JOB_ID" \
  --module-name trainer.task \
  --package-path trainer \
  --staging-bucket "$BUCKET" \
  --region us-central1 \
  --config config.yaml \
  -- \
  --raw_metadata_path "${PREPROCESS_OUTPUT}/raw_metadata" \
  --transform_savedmodel "${PREPROCESS_OUTPUT}/transform_fn" \
  --eval_data_paths "${PREPROCESS_OUTPUT}/features_eval*.tfrecord.gz" \
  --train_data_paths "${PREPROCESS_OUTPUT}/features_train*.tfrecord.gz" \
  --output_path "${GCS_PATH}/model/${JOB_ID}" \
  --model_type dnn_softmax \
  --eval_type ranking \
  --l2_weight_decay 0.01 \
  --learning_rate 0.05 \
  --train_steps 500000 \
  --eval_steps 500 \
  --top_k_infer 100

echo "JOB_ID: ${JOB_ID} Submitted"

JOB_ID="movielens_factorization_$(date +%Y%m%d_%H%M%S)"
gcloud ml-engine jobs submit training "$JOB_ID" \
  --module-name trainer.task \
  --package-path trainer \
  --staging-bucket "$BUCKET" \
  --region us-central1 \
  --config config_hypertune.yaml \
  -- \
  --raw_metadata_path "${PREPROCESS_OUTPUT}/raw_metadata" \
  --transform_savedmodel "${PREPROCESS_OUTPUT}/transform_fn" \
  --eval_data_paths "${PREPROCESS_OUTPUT}/features_eval*.tfrecord.gz" \
  --train_data_paths "${PREPROCESS_OUTPUT}/features_train*.tfrecord.gz" \
  --output_path "${GCS_PATH}/model/${JOB_ID}" \
  --model_type matrix_factorization \
  --eval_type ranking \
  --l2_weight_decay 0.01 \
  --learning_rate 0.05 \
  --train_steps 500000 \
  --eval_steps 500 \
  --movie_embedding_dim 64 \
  --top_k_infer 100

echo "JOB_ID: ${JOB_ID} Submitted"

echo "=== Training Jobs Submitted ==="