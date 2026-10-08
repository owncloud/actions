#!/usr/bin/env bash
set -euo pipefail

OCIS_URL="${OCIS_URL_OVERRIDE:-https://localhost:9200}"
CONFIG_DIR="${OCIS_CONFIG_DIR_INPUT:-${HOME}/.ocis/config}"
PID_FILE="${PID_FILE:-/tmp/ocis-wrapper.pid}"
LOG_FILE="${LOG_FILE:-/tmp/ocis-server.log}"

REPO_ROOT="${OCIS_REPO_ROOT:-${GITHUB_WORKSPACE}}"
FONT_PATH="${REPO_ROOT}/tests/config/ci/NotoSans.ttf"
FONTMAP=$(mktemp /tmp/fontsMap-XXXXXX.json)
echo "{\"defaultFont\": \"${FONT_PATH}\"}" > "$FONTMAP"

declare -A SERVER_ENV=(
  [OCIS_URL]="$OCIS_URL"
  [OCIS_CONFIG_DIR]="$CONFIG_DIR"
  [STORAGE_USERS_DRIVER]="ocis"
  [PROXY_ENABLE_BASIC_AUTH]="true"
  [OCIS_LOG_LEVEL]="${LOG_LEVEL:-error}"
  [IDM_CREATE_DEMO_USERS]="${DEMO_USERS:-false}"
  [IDM_ADMIN_PASSWORD]="${ADMIN_PASSWORD:-admin}"
  [FRONTEND_SEARCH_MIN_LENGTH]="2"
  [OCIS_ASYNC_UPLOADS]="true"
  [OCIS_EVENTS_ENABLE_TLS]="false"
  [NATS_NATS_HOST]="0.0.0.0"
  [NATS_NATS_PORT]="9233"
  [MICRO_REGISTRY_ADDRESS]="127.0.0.1:9233"
  [OCIS_JWT_SECRET]="some-ocis-jwt-secret"
  [EVENTHISTORY_STORE]="memory"
  [OCIS_TRANSLATION_PATH]="${REPO_ROOT}/tests/config/translations"
  [WEB_UI_CONFIG_FILE]="${WEB_UI_CONFIG_FILE:-${REPO_ROOT}/tests/config/ci/ocis-config.json}"
  [THUMBNAILS_TXT_FONTMAP_FILE]="$FONTMAP"
  [SEARCH_EXTRACTOR_TYPE]="basic"
  [FRONTEND_FULL_TEXT_SEARCH_ENABLED]="false"
  # service gRPC addresses
  [APP_PROVIDER_GRPC_ADDR]="0.0.0.0:9164"
  [APP_REGISTRY_GRPC_ADDR]="0.0.0.0:9242"
  [AUTH_BASIC_GRPC_ADDR]="0.0.0.0:9146"
  [AUTH_MACHINE_GRPC_ADDR]="0.0.0.0:9166"
  [AUTH_SERVICE_GRPC_ADDR]="0.0.0.0:9199"
  [EVENTHISTORY_GRPC_ADDR]="0.0.0.0:9274"
  [GATEWAY_GRPC_ADDR]="0.0.0.0:9142"
  [GROUPS_GRPC_ADDR]="0.0.0.0:9160"
  [OCM_GRPC_ADDR]="0.0.0.0:9282"
  [SEARCH_GRPC_ADDR]="0.0.0.0:9220"
  [SETTINGS_GRPC_ADDR]="0.0.0.0:9185"
  [SHARING_GRPC_ADDR]="0.0.0.0:9150"
  [STORAGE_PUBLICLINK_GRPC_ADDR]="0.0.0.0:9178"
  [STORAGE_SHARES_GRPC_ADDR]="0.0.0.0:9154"
  [STORAGE_SYSTEM_GRPC_ADDR]="0.0.0.0:9215"
  [STORAGE_USERS_GRPC_ADDR]="0.0.0.0:9157"
  [THUMBNAILS_GRPC_ADDR]="0.0.0.0:9191"
  [USERS_GRPC_ADDR]="0.0.0.0:9144"
  # service HTTP addresses
  [ACTIVITYLOG_HTTP_ADDR]="0.0.0.0:9195"
  [FRONTEND_HTTP_ADDR]="0.0.0.0:9140"
  [GRAPH_HTTP_ADDR]="0.0.0.0:9120"
  [IDM_LDAPS_ADDR]="0.0.0.0:9235"
  [IDP_HTTP_ADDR]="0.0.0.0:9130"
  [OCDAV_HTTP_ADDR]="0.0.0.0:9350"
  [OCM_HTTP_ADDR]="0.0.0.0:9280"
  [OCS_HTTP_ADDR]="0.0.0.0:9110"
  [PROXY_HTTP_ADDR]="0.0.0.0:9200"
  [SETTINGS_HTTP_ADDR]="0.0.0.0:9186"
  [SSE_HTTP_ADDR]="0.0.0.0:9132"
  [STORAGE_SYSTEM_HTTP_ADDR]="0.0.0.0:9216"
  [STORAGE_USERS_HTTP_ADDR]="0.0.0.0:9158"
  [THUMBNAILS_HTTP_ADDR]="0.0.0.0:9190"
  [THUMBNAILS_DATA_ENDPOINT]="http://127.0.0.1:9190/thumbnails/data"
  [USERLOG_HTTP_ADDR]="0.0.0.0:9211"
  [WEB_HTTP_ADDR]="0.0.0.0:9100"
  [WEBDAV_HTTP_ADDR]="0.0.0.0:9115"
  [WEBFINGER_HTTP_ADDR]="0.0.0.0:9275"
  # debug addresses
  [ACTIVITYLOG_DEBUG_ADDR]="0.0.0.0:9197"
  [APP_PROVIDER_DEBUG_ADDR]="0.0.0.0:9165"
  [APP_REGISTRY_DEBUG_ADDR]="0.0.0.0:9243"
  [AUTH_BASIC_DEBUG_ADDR]="0.0.0.0:9147"
  [AUTH_MACHINE_DEBUG_ADDR]="0.0.0.0:9167"
  [AUTH_SERVICE_DEBUG_ADDR]="0.0.0.0:9198"
  [CLIENTLOG_DEBUG_ADDR]="0.0.0.0:9260"
  [EVENTHISTORY_DEBUG_ADDR]="0.0.0.0:9270"
  [FRONTEND_DEBUG_ADDR]="0.0.0.0:9141"
  [GATEWAY_DEBUG_ADDR]="0.0.0.0:9143"
  [GRAPH_DEBUG_ADDR]="0.0.0.0:9124"
  [GROUPS_DEBUG_ADDR]="0.0.0.0:9161"
  [IDM_DEBUG_ADDR]="0.0.0.0:9239"
  [IDP_DEBUG_ADDR]="0.0.0.0:9134"
  [INVITATIONS_DEBUG_ADDR]="0.0.0.0:9269"
  [NATS_DEBUG_ADDR]="0.0.0.0:9234"
  [OCDAV_DEBUG_ADDR]="0.0.0.0:9163"
  [OCM_DEBUG_ADDR]="0.0.0.0:9281"
  [OCS_DEBUG_ADDR]="0.0.0.0:9114"
  [POSTPROCESSING_DEBUG_ADDR]="0.0.0.0:9255"
  [PROXY_DEBUG_ADDR]="0.0.0.0:9205"
  [SEARCH_DEBUG_ADDR]="0.0.0.0:9224"
  [SETTINGS_DEBUG_ADDR]="0.0.0.0:9194"
  [SHARING_DEBUG_ADDR]="0.0.0.0:9151"
  [SSE_DEBUG_ADDR]="0.0.0.0:9139"
  [STORAGE_PUBLICLINK_DEBUG_ADDR]="0.0.0.0:9179"
  [STORAGE_SHARES_DEBUG_ADDR]="0.0.0.0:9156"
  [STORAGE_SYSTEM_DEBUG_ADDR]="0.0.0.0:9217"
  [STORAGE_USERS_DEBUG_ADDR]="0.0.0.0:9159"
  [THUMBNAILS_DEBUG_ADDR]="0.0.0.0:9189"
  [USERLOG_DEBUG_ADDR]="0.0.0.0:9214"
  [USERS_DEBUG_ADDR]="0.0.0.0:9145"
  [WEB_DEBUG_ADDR]="0.0.0.0:9104"
  [WEBDAV_DEBUG_ADDR]="0.0.0.0:9119"
  [WEBFINGER_DEBUG_ADDR]="0.0.0.0:9279"
  # optional-service debug addresses (must be in main map so the offset loop can shift them)
  [ANTIVIRUS_DEBUG_ADDR]="0.0.0.0:9277"
  [NOTIFICATIONS_DEBUG_ADDR]="0.0.0.0:9174"
)

# Antivirus
if [[ "${ANTIVIRUS_ENABLED:-false}" == "true" ]]; then
  SERVER_ENV[ANTIVIRUS_SCANNER_TYPE]="clamav"
  SERVER_ENV[ANTIVIRUS_CLAMAV_SOCKET]="tcp://localhost:3310"
  # Not setting POSTPROCESSING_STEPS=virusscan: tests that need it set it via ociswrapper at runtime
  SERVER_ENV[OCIS_ADD_RUN_SERVICES]="antivirus"
fi

# Email (notifications service)
if [[ "${EMAIL_ENABLED:-false}" == "true" ]]; then
  if [[ -n "${SERVER_ENV[OCIS_ADD_RUN_SERVICES]:-}" ]]; then
    SERVER_ENV[OCIS_ADD_RUN_SERVICES]="${SERVER_ENV[OCIS_ADD_RUN_SERVICES]},notifications"
  else
    SERVER_ENV[OCIS_ADD_RUN_SERVICES]="notifications"
  fi
  SERVER_ENV[NOTIFICATIONS_SMTP_HOST]="localhost"
  SERVER_ENV[NOTIFICATIONS_SMTP_PORT]="1025"
  SERVER_ENV[NOTIFICATIONS_SMTP_INSECURE]="true"
  SERVER_ENV[NOTIFICATIONS_SMTP_SENDER]="ownCloud <noreply@example.com>"
fi

# Tika (full-text search)
if [[ "${TIKA_ENABLED:-false}" == "true" ]]; then
  SERVER_ENV[FRONTEND_FULL_TEXT_SEARCH_ENABLED]="true"
  SERVER_ENV[SEARCH_EXTRACTOR_TYPE]="tika"
  SERVER_ENV[SEARCH_EXTRACTOR_TIKA_TIKA_URL]="http://localhost:9998"
  SERVER_ENV[SEARCH_EXTRACTOR_CS3SOURCE_INSECURE]="true"
fi

# Shift all service ports by an offset (used when running a secondary oCIS instance alongside the primary)
if [[ -n "${DEBUG_PORT_OFFSET:-}" && "${DEBUG_PORT_OFFSET}" != "0" ]]; then
  for key in "${!SERVER_ENV[@]}"; do
    [[ "$key" != *_ADDR && "$key" != *_ADDRESS ]] && continue
    val="${SERVER_ENV[$key]}"
    # Only shift host:port values (must contain a colon with a numeric port after it)
    [[ "$val" != *:* ]] && continue
    port="${val##*:}"
    [[ "$port" =~ ^[0-9]+$ ]] || continue
    host="${val%:*}"
    SERVER_ENV[$key]="${host}:$((port + DEBUG_PORT_OFFSET))"
  done
fi

# Extra env vars from JSON input — jq outputs KEY\x01VALUE lines (SOH as delimiter: safe against spaces/newlines in values)
if [[ -n "${EXTRA_SERVER_ENV:-}" && "${EXTRA_SERVER_ENV}" != "{}" ]]; then
  while IFS=$'\x01' read -r key val; do
    [[ -n "$key" ]] && SERVER_ENV["$key"]="$val"
  done < <(echo "$EXTRA_SERVER_ENV" | jq -r 'to_entries[] | .key + "" + (.value | tostring)')
fi

DIRECT_MODE=false
if [[ "${KEYCLOAK_ENABLED:-false}" == "true" ]]; then
  # Only force direct mode when wrapper is not explicitly requested
  if [[ "${WRAPPER_ENABLED:-true}" != "true" ]]; then
    DIRECT_MODE=true
  fi
  SERVER_ENV[OCIS_EXCLUDE_RUN_SERVICES]="idp"
  SERVER_ENV[IDM_CREATE_DEMO_USERS]="false"
  SERVER_ENV[PROXY_AUTOPROVISION_ACCOUNTS]="true"
  SERVER_ENV[PROXY_AUTOPROVISION_CLAIM_GROUPS]="groups"
  SERVER_ENV[PROXY_AUTOPROVISION_GROUP_CREATE]="true"
  SERVER_ENV[PROXY_ROLE_ASSIGNMENT_DRIVER]="oidc"
  SERVER_ENV[OCIS_OIDC_ISSUER]="https://localhost:8443/realms/oCIS"
  SERVER_ENV[PROXY_OIDC_REWRITE_WELLKNOWN]="true"
  SERVER_ENV[WEB_OIDC_CLIENT_ID]="web"
  SERVER_ENV[PROXY_USER_OIDC_CLAIM]="preferred_username"
  SERVER_ENV[PROXY_USER_CS3_CLAIM]="username"
  SERVER_ENV[OCIS_ADMIN_USER_ID]=""
  SERVER_ENV[GRAPH_ASSIGN_DEFAULT_USER_ROLE]="false"
  SERVER_ENV[GRAPH_USERNAME_MATCH]="none"
  SERVER_ENV[PROXY_CSP_CONFIG_FILE_LOCATION]="${REPO_ROOT}/tests/config/ci/csp.yaml"
  SERVER_ENV[KEYCLOAK_DOMAIN]="localhost:8443"
elif [[ "${WRAPPER_ENABLED:-true}" == "false" ]]; then
  DIRECT_MODE=true
fi

# Build env for the subprocess (after all SERVER_ENV mutations are complete)
ENV_ARGS=()
for key in "${!SERVER_ENV[@]}"; do
  ENV_ARGS+=("${key}=${SERVER_ENV[$key]}")
done

if [[ "$DIRECT_MODE" == "true" ]]; then
  echo "Starting oCIS server (direct mode)..."
  env "${ENV_ARGS[@]}" ocis server > "$LOG_FILE" 2>&1 &
else
  echo "Starting ociswrapper + oCIS server..."
  env "${ENV_ARGS[@]}" ociswrapper serve \
    --bin /usr/local/bin/ocis \
    --url "$OCIS_URL" \
    --admin-username admin \
    --admin-password "${ADMIN_PASSWORD:-admin}" \
    > "$LOG_FILE" 2>&1 &
fi

echo $! > "$PID_FILE"
echo "oCIS started (PID $(cat "$PID_FILE")), log: $LOG_FILE"
