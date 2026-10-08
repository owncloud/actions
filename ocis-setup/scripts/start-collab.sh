#!/usr/bin/env bash
# Usage: start_collab <name> <app_name> <product> <addr> <grpc_port> <http_port> <debug_port> [wopi_src]
start_collab() {
  local name=$1
  local app_name=$2
  local product=$3
  local addr=$4
  local grpc=$5
  local http=$6
  local debug=$7
  local wopi_src=${8:-}
  env \
    OCIS_URL="$OCIS_URL" \
    OCIS_CONFIG_DIR="$CONFIG_DIR" \
    MICRO_REGISTRY="nats-js-kv" \
    MICRO_REGISTRY_ADDRESS="localhost:$((9233 + ${DEBUG_PORT_OFFSET:-0}))" \
    COLLABORATION_LOG_LEVEL=debug \
    COLLABORATION_GRPC_ADDR="0.0.0.0:${grpc}" \
    COLLABORATION_HTTP_ADDR="0.0.0.0:${http}" \
    COLLABORATION_DEBUG_ADDR="0.0.0.0:${debug}" \
    COLLABORATION_APP_PROOF_DISABLE=true \
    COLLABORATION_APP_INSECURE=true \
    COLLABORATION_CS3API_DATAGATEWAY_INSECURE=true \
    OCIS_JWT_SECRET=some-ocis-jwt-secret \
    COLLABORATION_WOPI_SECRET=some-wopi-secret \
    COLLABORATION_APP_NAME="$app_name" \
    COLLABORATION_APP_PRODUCT="$product" \
    COLLABORATION_APP_ADDR="$addr" \
    COLLABORATION_WOPI_SRC="${wopi_src:-http://localhost:${http}}" \
    ocis collaboration server > "/tmp/collab-${name}.log" 2>&1 &
  echo $! > "/tmp/collab-${name}.pid"
  echo "collaboration-${name} started (PID $!)"
}
