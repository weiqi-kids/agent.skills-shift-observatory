#!/usr/bin/env bash
# qdrant.sh - Qdrant vector database helper functions
# 注意：預期被其他 script 用 `.` source 進來
# 不在這裡 set -euo pipefail，交給呼叫端決定。

if [[ -n "${QDRANT_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
QDRANT_SH_LOADED=1

_qdrant_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${_qdrant_lib_dir}/core.sh"

########################################
# ID 轉換：字串 → UUID v5
########################################

# _qdrant_id_to_uuid STRING
#
# 功能：
#   - 將任意字串轉為確定性 UUID v5（NAMESPACE_URL）
#   - 若輸入已是 UUID 格式或純數字，原樣回傳
#
# 用途：
#   Qdrant 要求 point ID 為 UUID 或 unsigned int，
#   本函數將 update.sh 產生的字串 ID 自動轉為 UUID。
_qdrant_id_to_uuid() {
  local input="$1"

  # 如果已是 UUID 格式，直接回傳
  if [[ "$input" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
    echo "$input"
    return 0
  fi

  # 如果是純數字，直接回傳
  if [[ "$input" =~ ^[0-9]+$ ]]; then
    echo "$input"
    return 0
  fi

  # 使用 Python uuid5 產生確定性 UUID（透過 stdin 傳入避免命令注入）
  printf '%s' "$input" | python3 -c "import sys, uuid; print(uuid.uuid5(uuid.NAMESPACE_URL, sys.stdin.read()))" 2>/dev/null && return 0

  # Fallback：用 md5 手動格式化為 UUID
  local hash
  if command -v md5 >/dev/null 2>&1; then
    hash="$(printf '%s' "$input" | md5)"
  elif command -v md5sum >/dev/null 2>&1; then
    hash="$(printf '%s' "$input" | md5sum | cut -d' ' -f1)"
  else
    echo "❌ [_qdrant_id_to_uuid] 無法產生 UUID（缺少 python3/md5/md5sum）" >&2
    return 1
  fi
  echo "${hash:0:8}-${hash:8:4}-${hash:12:4}-${hash:16:4}-${hash:20:12}"
}

# _qdrant_ids_to_uuids_batch INPUT_FILE OUTPUT_FILE
#
# 功能：
#   - 批次將字串轉為確定性 UUID v5（NAMESPACE_URL）
#   - 單一 Python 呼叫處理所有行，避免 N 次 process spawn
#
# 參數：
#   INPUT_FILE: 每行一個輸入字串
#   OUTPUT_FILE: 每行一個 UUID（與輸入同序）
_qdrant_ids_to_uuids_batch() {
  local input_file="$1"
  local output_file="$2"

  python3 -c "
import sys, uuid
for line in open(sys.argv[1], 'r'):
    s = line.rstrip('\n')
    print(uuid.uuid5(uuid.NAMESPACE_URL, s))
" "$input_file" > "$output_file" 2>/dev/null && return 0

  # Fallback：逐行用 md5 產生偽 UUID
  > "$output_file"
  while IFS= read -r line; do
    local hash
    if command -v md5 >/dev/null 2>&1; then
      hash="$(printf '%s' "$line" | md5)"
    elif command -v md5sum >/dev/null 2>&1; then
      hash="$(printf '%s' "$line" | md5sum | cut -d' ' -f1)"
    else
      echo "❌ [_qdrant_ids_to_uuids_batch] 無法產生 UUID" >&2
      return 1
    fi
    echo "${hash:0:8}-${hash:8:4}-${hash:12:4}-${hash:16:4}-${hash:20:12}" >> "$output_file"
  done < "$input_file"
}

########################################
# 初始化：Qdrant 連接資訊
########################################
qdrant_init_env() {
  # 環境變數：
  # QDRANT_URL 或 QDRANT_ENDPOINT: Qdrant 伺服器 URL (例如 https://xxx.gcp.cloud.qdrant.io:6333)
  # QDRANT_API_KEY: API key (Qdrant Cloud 需要)
  : "${QDRANT_URL:=${QDRANT_ENDPOINT:-http://localhost:6333}}"
  : "${QDRANT_API_KEY:=}"

  local err=0

  if [[ -z "${QDRANT_URL:-}" ]]; then
    echo "❌ [qdrant_init_env] 未設定 QDRANT_URL" >&2
    err=1
  fi

  # 指令檢查
  if declare -f require_cmd >/dev/null 2>&1; then
    require_cmd curl
    require_cmd jq
  else
    for cmd in curl jq; do
      if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ [qdrant_init_env] 需要指令：$cmd" >&2
        err=1
      fi
    done
  fi

  return "$err"
}

########################################
# Collection 管理
########################################

# qdrant_create_collection COLLECTION_NAME VECTOR_SIZE [DISTANCE]
#
# 功能：
#   - 建立新的 collection
#
# 參數：
#   COLLECTION_NAME: collection 名稱
#   VECTOR_SIZE: 向量維度 (例如 1536 for text-embedding-3-small)
#   DISTANCE: 距離計算方式 (Cosine, Euclid, Dot) 預設 Cosine
#
# 回傳值：
#   0  = 成功或已存在
#   >0 = 失敗
qdrant_create_collection() {
  local collection_name="$1"
  local vector_size="$2"
  local distance="${3:-Cosine}"

  require_cmd curl jq || return 1

  local payload
  payload="$(
    jq -n \
      --argjson size "$vector_size" \
      --arg dist "$distance" \
      '{
        vectors: {
          size: $size,
          distance: $dist
        }
      }'
  )"

  local tmp_body http_code
  tmp_body="$(mktemp)"

  local curl_args=(
    -sS -X PUT "${QDRANT_URL%/}/collections/${collection_name}"
    -H "Content-Type: application/json"
    --data-raw "$payload"
    -w '%{http_code}' -o "$tmp_body"
    --connect-timeout 15
    --max-time 30
    --tlsv1.2
  )

  if [[ -n "${QDRANT_API_KEY:-}" ]]; then
    curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    local rc=$?
    echo "❌ [qdrant_create_collection] curl 失敗 exit=${rc}" >&2
    rm -f "$tmp_body"
    return 1
  }

  local resp
  resp="$(cat "$tmp_body")"
  rm -f "$tmp_body"

  # HTTP 200 = 成功創建
  # HTTP 409 = Collection 已存在（也視為成功）
  if [[ "$http_code" == "200" ]] || [[ "$http_code" == "409" ]]; then
    return 0
  fi

  echo "❌ [qdrant_create_collection] HTTP=${http_code}" >&2
  if jq -e . >/dev/null 2>&1 <<<"$resp"; then
    echo "$resp" | jq -C '.' >&2
  else
    echo "$resp" >&2
  fi
  return 1
}

# qdrant_collection_exists COLLECTION_NAME
#
# 功能：
#   - 檢查 collection 是否存在
#
# 回傳值：
#   0  = 存在
#   1  = 不存在
qdrant_collection_exists() {
  local collection_name="$1"

  require_cmd curl jq || return 1

  local tmp_body http_code
  tmp_body="$(mktemp)"

  local curl_args=(
    -sS -X GET "${QDRANT_URL%/}/collections/${collection_name}"
    -w '%{http_code}' -o "$tmp_body"
    --connect-timeout 15
    --max-time 30
    --tlsv1.2
  )

  if [[ -n "${QDRANT_API_KEY:-}" ]]; then
    curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    rm -f "$tmp_body"
    return 1
  }

  rm -f "$tmp_body"

  if [[ "$http_code" == "200" ]]; then
    return 0
  else
    return 1
  fi
}

########################################
# Points (向量點) 操作
########################################

# qdrant_upsert_point COLLECTION_NAME POINT_ID VECTOR_JSON PAYLOAD_JSON
#
# 功能：
#   - 插入或更新單一 point
#
# 參數：
#   COLLECTION_NAME: collection 名稱
#   POINT_ID: point 的唯一 ID (字串或數字)
#   VECTOR_JSON: embedding vector (JSON array of floats)
#   PAYLOAD_JSON: metadata (JSON object)
#
# 回傳值：
#   0  = 成功
#   >0 = 失敗
qdrant_upsert_point() {
  local collection_name="$1"
  local point_id="$2"
  local vector_json="$3"
  local payload_json="$4"

  require_cmd curl jq || return 1

  local max_retries=3
  local retry_delay=1  # 初始延遲（指數退避：1s → 2s → 4s）

  local payload
  payload="$(
    printf '%s\n%s' "$vector_json" "$payload_json" | jq -sc \
      --arg id "$point_id" \
      '{
        points: [
          {
            id: $id,
            vector: .[0],
            payload: .[1]
          }
        ]
      }'
  )"

  for ((attempt=1; attempt<=max_retries; attempt++)); do
    local tmp_body http_code
    tmp_body="$(mktemp)"

    local curl_args=(
      -sS -X PUT "${QDRANT_URL%/}/collections/${collection_name}/points"
      -H "Content-Type: application/json"
      --data-raw "$payload"
      -w '%{http_code}' -o "$tmp_body"
      --connect-timeout 15
      --max-time 60
      --tlsv1.2
    )

    if [[ -n "${QDRANT_API_KEY:-}" ]]; then
      curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
    fi

    http_code="$(curl "${curl_args[@]}" 2>/dev/null)"
    local curl_exit=$?

    # 如果 curl 成功
    if [[ $curl_exit -eq 0 ]]; then
      local resp
      resp="$(cat "$tmp_body")"
      rm -f "$tmp_body"

      if [[ "$http_code" == "200" ]]; then
        return 0
      fi

      # HTTP 502/503/504 可重試
      if [[ "$http_code" =~ ^50[234]$ ]] && [[ $attempt -lt $max_retries ]]; then
        echo "⚠️  [qdrant_upsert_point] HTTP=${http_code}，重試 $attempt/$max_retries..." >&2
        sleep $retry_delay
        retry_delay=$((retry_delay * 2))
        continue
      fi

      echo "❌ [qdrant_upsert_point] HTTP=${http_code}" >&2
      if jq -e . >/dev/null 2>&1 <<<"$resp"; then
        echo "$resp" | jq -C '.' >&2
      else
        echo "$resp" >&2
      fi
      return 1
    fi

    # curl 失敗，判斷是否需要重試
    rm -f "$tmp_body"
    if [[ $attempt -lt $max_retries ]]; then
      echo "⚠️  [qdrant_upsert_point] curl 失敗 (exit=${curl_exit})，重試 ${attempt}/${max_retries}（${retry_delay}s 後）..." >&2
      sleep $retry_delay
      retry_delay=$((retry_delay * 2))
    else
      echo "❌ [qdrant_upsert_point] curl 失敗 (exit=$curl_exit)，已重試 $max_retries 次" >&2
      return 1
    fi
  done

  return 1
}

# qdrant_upsert_points_batch COLLECTION_NAME POINTS_JSON
#
# 功能：
#   - 批次插入或更新 points
#
# 參數：
#   COLLECTION_NAME: collection 名稱
#   POINTS_JSON: JSON array of points，格式：
#     [
#       {"id": "id1", "vector": [...], "payload": {...}},
#       {"id": "id2", "vector": [...], "payload": {...}}
#     ]
#
# 回傳值：
#   0  = 成功
#   >0 = 失敗
qdrant_upsert_points_batch() {
  local collection_name="$1"
  local points_json="$2"

  require_cmd curl jq || return 1

  # 使用臨時檔案避免命令行參數過長
  local tmp_payload tmp_body http_code
  tmp_payload="$(mktemp)"
  tmp_body="$(mktemp)"

  # 將 payload 寫入臨時檔案
  printf '%s' "$points_json" | jq -c '{points: .}' > "$tmp_payload"

  local curl_args=(
    -sS -X PUT "${QDRANT_URL%/}/collections/${collection_name}/points"
    -H "Content-Type: application/json"
    -d "@${tmp_payload}"
    -w '%{http_code}' -o "$tmp_body"
    --connect-timeout 15
    --max-time 120
    --tlsv1.2
  )

  if [[ -n "${QDRANT_API_KEY:-}" ]]; then
    curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    local rc=$?
    echo "❌ [qdrant_upsert_points_batch] curl 失敗 exit=${rc}" >&2
    rm -f "$tmp_payload" "$tmp_body"
    return 1
  }

  local resp
  resp="$(cat "$tmp_body")"
  rm -f "$tmp_payload" "$tmp_body"

  if [[ "$http_code" == "200" ]]; then
    return 0
  fi

  echo "❌ [qdrant_upsert_points_batch] HTTP=${http_code}" >&2
  if jq -e . >/dev/null 2>&1 <<<"$resp"; then
    echo "$resp" | jq -C '.' >&2
  else
    echo "$resp" >&2
  fi
  return 1
}

# qdrant_point_exists COLLECTION_NAME POINT_ID
#
# 功能：
#   - 檢查 point 是否存在
#
# 回傳值：
#   0  = 存在
#   1  = 不存在
qdrant_point_exists() {
  local collection_name="$1"
  local point_id="$2"

  require_cmd curl jq || return 1

  local max_retries=3
  local retry_delay=1

  for ((attempt=1; attempt<=max_retries; attempt++)); do
    local tmp_body http_code
    tmp_body="$(mktemp)"

    local curl_args=(
      -sS -X GET "${QDRANT_URL%/}/collections/${collection_name}/points/${point_id}"
      -w '%{http_code}' -o "$tmp_body"
      --connect-timeout 15
      --max-time 30
      --tlsv1.2
    )

    if [[ -n "${QDRANT_API_KEY:-}" ]]; then
      curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
    fi

    http_code="$(curl "${curl_args[@]}" 2>/dev/null)"
    local curl_exit=$?

    # 如果 curl 成功
    if [[ $curl_exit -eq 0 ]]; then
      local resp
      resp="$(cat "$tmp_body")"
      rm -f "$tmp_body"

      if [[ "$http_code" == "200" ]]; then
        # 檢查 result 是否為 null (point 不存在時 API 會回傳 200 但 result 為 null)
        local result
        result="$(printf '%s' "$resp" | jq -r '.result // "null"')"
        if [[ "$result" != "null" ]]; then
          return 0  # Point 存在
        fi
      fi
      return 1  # Point 不存在（HTTP 404 或 result 為 null）
    fi

    # curl 失敗，判斷是否需要重試
    rm -f "$tmp_body"
    if [[ $attempt -lt $max_retries ]]; then
      echo "⚠️  [qdrant_point_exists] curl 失敗 (exit=${curl_exit})，重試 ${attempt}/${max_retries}（${retry_delay}s 後）..." >&2
      sleep $retry_delay
      retry_delay=$((retry_delay * 2))
    else
      echo "❌ [qdrant_point_exists] curl 失敗 (exit=$curl_exit)，已重試 $max_retries 次" >&2
      return 1
    fi
  done

  return 1
}

########################################
# Batch Get (檢查多個 points 是否存在)
########################################

# qdrant_get_existing_ids COLLECTION_NAME IDS_JSON
#
# 功能：
#   - 批次查詢哪些 point IDs 已存在
#
# 參數：
#   COLLECTION_NAME: collection 名稱
#   IDS_JSON: JSON array of point IDs，例如 ["id1", "id2", "id3"]
#
# stdout:
#   已存在的 IDs (JSON array)，例如 ["id1", "id3"]
#
# 回傳值：
#   0  = 成功
#   >0 = 失敗
qdrant_get_existing_ids() {
  local collection_name="$1"
  local ids_json="$2"

  require_cmd curl jq || return 1

  # 使用臨時檔案避免命令行參數過長
  local tmp_payload tmp_body http_code
  tmp_payload="$(mktemp)"
  tmp_body="$(mktemp)"

  # 將 payload 寫入臨時檔案
  printf '%s' "$ids_json" | jq -c '{
    ids: .,
    with_payload: false,
    with_vector: false
  }' > "$tmp_payload"

  local curl_args=(
    -sS -X POST "${QDRANT_URL%/}/collections/${collection_name}/points"
    -H "Content-Type: application/json"
    -d "@${tmp_payload}"
    -w '%{http_code}' -o "$tmp_body"
    --connect-timeout 15
    --max-time 60
    --tlsv1.2
  )

  if [[ -n "${QDRANT_API_KEY:-}" ]]; then
    curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    local rc=$?
    echo "❌ [qdrant_get_existing_ids] curl 失敗 exit=${rc}" >&2
    rm -f "$tmp_payload" "$tmp_body"
    return 1
  }

  local resp
  resp="$(cat "$tmp_body")"
  rm -f "$tmp_payload" "$tmp_body"

  if [[ "$http_code" != "200" ]]; then
    echo "❌ [qdrant_get_existing_ids] HTTP=${http_code}" >&2
    if jq -e . >/dev/null 2>&1 <<<"$resp"; then
      echo "$resp" | jq -C '.' >&2
    else
      echo "$resp" >&2
    fi
    return 1
  fi

  # 提取已存在的 IDs
  printf '%s' "$resp" | jq -c '[.result[].id]'
}

########################################
# Payload 更新（部分更新，不覆蓋整個 payload）
########################################

# qdrant_set_payload COLLECTION_NAME POINT_IDS_JSON PAYLOAD_JSON
#
# 功能：
#   - 只更新指定 points 的部分 payload 欄位（不覆蓋其他欄位）
#
# 參數：
#   COLLECTION_NAME: collection 名稱
#   POINT_IDS_JSON: JSON array of point IDs，例如 ["id1", "id2"]
#   PAYLOAD_JSON: 要更新的欄位 JSON，例如 {"expires_at":"2025-01-01","expired_reason":"patched"}
#
# 回傳值：
#   0  = 成功
#   >0 = 失敗
qdrant_set_payload() {
  local collection_name="$1"
  local point_ids_json="$2"
  local payload_json="$3"

  require_cmd curl jq || return 1

  local tmp_payload tmp_body http_code
  tmp_payload="$(mktemp)"
  tmp_body="$(mktemp)"

  jq -nc \
    --argjson ids "$point_ids_json" \
    --argjson payload "$payload_json" \
    '{
      points: $ids,
      payload: $payload
    }' > "$tmp_payload"

  local max_retries=3 retry_delay=1

  for ((attempt=1; attempt<=max_retries; attempt++)); do
    local curl_args=(
      -sS -X POST "${QDRANT_URL%/}/collections/${collection_name}/points/payload"
      -H "Content-Type: application/json"
      -d "@${tmp_payload}"
      -w '%{http_code}' -o "$tmp_body"
      --connect-timeout 15
      --max-time 60
      --tlsv1.2
    )

    if [[ -n "${QDRANT_API_KEY:-}" ]]; then
      curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
    fi

    http_code="$(curl "${curl_args[@]}" 2>/dev/null)"
    local curl_exit=$?

    if [[ $curl_exit -eq 0 ]]; then
      if [[ "$http_code" == "200" ]]; then
        rm -f "$tmp_payload" "$tmp_body"
        return 0
      fi

      if [[ "$http_code" =~ ^50[234]$ ]] && [[ $attempt -lt $max_retries ]]; then
        echo "⚠️  [qdrant_set_payload] HTTP=${http_code}，重試 $attempt/$max_retries..." >&2
        sleep $retry_delay
        retry_delay=$((retry_delay * 2))
        continue
      fi

      local resp
      resp="$(cat "$tmp_body")"
      echo "❌ [qdrant_set_payload] HTTP=${http_code}" >&2
      if jq -e . >/dev/null 2>&1 <<<"$resp"; then
        echo "$resp" | jq -C '.' >&2
      else
        echo "$resp" >&2
      fi
      rm -f "$tmp_payload" "$tmp_body"
      return 1
    fi

    rm -f "$tmp_body"
    if [[ $attempt -lt $max_retries ]]; then
      echo "⚠️  [qdrant_set_payload] curl 失敗 (exit=$curl_exit)，重試 $attempt/$max_retries..." >&2
      sleep $retry_delay
      retry_delay=$((retry_delay * 2))
    else
      echo "❌ [qdrant_set_payload] curl 失敗 (exit=$curl_exit)，已重試 $max_retries 次" >&2
      rm -f "$tmp_payload"
      return 1
    fi
  done

  rm -f "$tmp_payload" "$tmp_body"
  return 1
}

########################################
# Scroll（帶 filter 的批次查詢）
########################################

# qdrant_scroll_without_field COLLECTION FIELD_NAME LAYER_NAME [LIMIT]
#
# 功能：
#   - 搜尋指定 Layer 中「不含某欄位」的 points（使用 scroll API + filter）
#   - 用於找出尚未標記 expires_at 的活躍資料
#
# 參數：
#   COLLECTION: collection 名稱
#   FIELD_NAME: 要排除的欄位名（例如 "expires_at"）
#   LAYER_NAME: 來源 Layer 名稱（用於 source_layer filter）
#   LIMIT: 每次回傳筆數（預設 100）
#
# stdout:
#   JSON array of points（包含 id 和 payload）
qdrant_scroll_without_field() {
  local collection_name="$1"
  local field_name="$2"
  local layer_name="$3"
  local limit="${4:-100}"

  require_cmd curl jq || return 1

  local tmp_payload tmp_body http_code
  tmp_payload="$(mktemp)"
  tmp_body="$(mktemp)"

  # Qdrant scroll filter: 找出 source_layer=X 且指定欄位不存在的 points
  # 使用 IsNull condition 表示「欄位為 null 或不存在」
  jq -nc \
    --arg layer "$layer_name" \
    --arg field "$field_name" \
    --argjson limit "$limit" \
    '{
      filter: {
        must: [
          { key: "source_layer", match: { value: $layer } },
          { is_null: { key: $field } }
        ]
      },
      limit: $limit,
      with_payload: true
    }' > "$tmp_payload"

  local curl_args=(
    -sS -X POST "${QDRANT_URL%/}/collections/${collection_name}/points/scroll"
    -H "Content-Type: application/json"
    -d "@${tmp_payload}"
    -w '%{http_code}' -o "$tmp_body"
    --connect-timeout 15
    --max-time 60
    --tlsv1.2
  )

  if [[ -n "${QDRANT_API_KEY:-}" ]]; then
    curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    local rc=$?
    echo "❌ [qdrant_scroll_without_field] curl 失敗 exit=${rc}" >&2
    rm -f "$tmp_payload" "$tmp_body"
    return 1
  }

  local resp
  resp="$(cat "$tmp_body")"
  rm -f "$tmp_payload" "$tmp_body"

  if [[ "$http_code" != "200" ]]; then
    echo "❌ [qdrant_scroll_without_field] HTTP=${http_code}" >&2
    if jq -e . >/dev/null 2>&1 <<<"$resp"; then
      echo "$resp" | jq -C '.' >&2
    else
      echo "$resp" >&2
    fi
    return 1
  fi

  # 回傳 points array
  printf '%s' "$resp" | jq -c '.result.points // []'
}

########################################
# Scroll (Filter-based query, no vector needed)
########################################

# qdrant_scroll COLLECTION_NAME FILTER_JSON [LIMIT]
#
# 功能：
#   - 按 filter 條件捲動查詢（不需要向量）
#   - 用於跨平台資料查詢（如：查詢同一 product_id 的所有平台資料）
#
# 參數：
#   COLLECTION_NAME: collection 名稱
#   FILTER_JSON: Qdrant filter 條件 (JSON object)
#     例如：'{"must":[{"key":"product_id","match":{"value":"B09V3KXJPB"}}]}'
#   LIMIT: 回傳結果數量（預設 100）
#
# stdout:
#   查詢結果 JSON（包含 points 陣列，每個 point 含 id 和 payload）
#
# 回傳值：
#   0  = 成功
#   >0 = 失敗
qdrant_scroll() {
  local collection_name="$1"
  local filter_json="$2"
  local limit="${3:-100}"

  require_cmd curl jq || return 1

  local max_retries=3
  local retry_delay=1

  # 使用臨時檔案避免命令行參數過長
  local tmp_payload tmp_body http_code
  tmp_payload="$(mktemp)"
  tmp_body="$(mktemp)"

  # 組合 scroll 請求 payload
  printf '%s' "$filter_json" | jq -c \
    --argjson limit "$limit" \
    '{
      filter: .,
      limit: $limit,
      with_payload: true,
      with_vector: false
    }' > "$tmp_payload"

  for ((attempt=1; attempt<=max_retries; attempt++)); do
    local curl_args=(
      -sS -X POST "${QDRANT_URL%/}/collections/${collection_name}/points/scroll"
      -H "Content-Type: application/json"
      -d "@${tmp_payload}"
      -w '%{http_code}' -o "$tmp_body"
      --connect-timeout 15
      --max-time 60
      --tlsv1.2
    )

    if [[ -n "${QDRANT_API_KEY:-}" ]]; then
      curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
    fi

    http_code="$(curl "${curl_args[@]}" 2>/dev/null)"
    local curl_exit=$?

    if [[ $curl_exit -eq 0 ]]; then
      local resp
      resp="$(cat "$tmp_body")"
      rm -f "$tmp_payload" "$tmp_body"

      if [[ "$http_code" == "200" ]]; then
        printf '%s\n' "$resp"
        return 0
      fi

      echo "❌ [qdrant_scroll] HTTP=${http_code}" >&2
      if jq -e . >/dev/null 2>&1 <<<"$resp"; then
        echo "$resp" | jq -C '.' >&2
      else
        echo "$resp" >&2
      fi
      return 1
    fi

    rm -f "$tmp_body"
    if [[ $attempt -lt $max_retries ]]; then
      echo "⚠️  [qdrant_scroll] curl 失敗 (exit=$curl_exit)，重試 $attempt/$max_retries..." >&2
      sleep $retry_delay
    else
      rm -f "$tmp_payload"
      echo "❌ [qdrant_scroll] curl 失敗 (exit=$curl_exit)，已重試 $max_retries 次" >&2
      return 1
    fi
  done

  rm -f "$tmp_payload" "$tmp_body"
  return 1
}

########################################
# Search by Payload (URL 查詢)
########################################

# qdrant_exists_by_url SOURCE_URL [COLLECTION_NAME]
#
# 功能：
#   - 檢查是否存在具有特定 source_url 的 point
#
# 參數：
#   SOURCE_URL: 要查詢的 source_url
#   COLLECTION_NAME: collection 名稱（預設使用 $QDRANT_COLLECTION）
#
# 回傳值：
#   0  = 存在
#   1  = 不存在
qdrant_exists_by_url() {
  local source_url="$1"
  local collection_name="${2:-${QDRANT_COLLECTION:-}}"

  require_cmd curl jq || return 1

  if [[ -z "$collection_name" ]]; then
    echo "❌ [qdrant_exists_by_url] 未指定 collection（設定 QDRANT_COLLECTION 或傳入第二參數）" >&2
    return 1
  fi

  local payload
  payload="$(
    jq -n \
      --arg url "$source_url" \
      '{
        filter: {
          must: [
            {
              key: "source_url",
              match: { value: $url }
            }
          ]
        },
        limit: 1,
        with_payload: false,
        with_vector: false
      }'
  )"

  local tmp_body http_code
  tmp_body="$(mktemp)"

  local curl_args=(
    -sS -X POST "${QDRANT_URL%/}/collections/${collection_name}/points/scroll"
    -H "Content-Type: application/json"
    --data-raw "$payload"
    -w '%{http_code}' -o "$tmp_body"
    --connect-timeout 15
    --max-time 30
    --tlsv1.2
  )

  if [[ -n "${QDRANT_API_KEY:-}" ]]; then
    curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    rm -f "$tmp_body"
    return 1
  }

  local resp
  resp="$(cat "$tmp_body")"
  rm -f "$tmp_body"

  if [[ "$http_code" != "200" ]]; then
    return 1
  fi

  # 檢查是否有結果
  local count
  count="$(printf '%s' "$resp" | jq -r '.result.points | length')"
  if [[ "$count" -gt 0 ]]; then
    return 0  # 存在
  fi
  return 1  # 不存在
}

########################################
# Search
########################################

# qdrant_search COLLECTION_NAME VECTOR_JSON LIMIT
#
# 功能：
#   - 搜尋最相似的 points
#
# 參數：
#   COLLECTION_NAME: collection 名稱
#   VECTOR_JSON: query vector (JSON array of floats)
#   LIMIT: 回傳結果數量
#
# stdout:
#   搜尋結果 JSON (包含 id, score, payload)
#
qdrant_search() {
  local collection_name="$1"
  local vector_json="$2"
  local limit="${3:-10}"

  require_cmd curl jq || return 1

  local max_retries=3
  local retry_delay=1

  local payload
  payload="$(
    printf '%s' "$vector_json" | jq -c \
      --argjson limit "$limit" \
      '{
        vector: .,
        limit: $limit,
        with_payload: true
      }'
  )"

  for ((attempt=1; attempt<=max_retries; attempt++)); do
    local tmp_body http_code
    tmp_body="$(mktemp)"

    local curl_args=(
      -sS -X POST "${QDRANT_URL%/}/collections/${collection_name}/points/search"
      -H "Content-Type: application/json"
      --data-raw "$payload"
      -w '%{http_code}' -o "$tmp_body"
      --connect-timeout 15
      --max-time 30
      --tlsv1.2
    )

    if [[ -n "${QDRANT_API_KEY:-}" ]]; then
      curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
    fi

    http_code="$(curl "${curl_args[@]}" 2>/dev/null)"
    local curl_exit=$?

    if [[ $curl_exit -eq 0 ]]; then
      local resp
      resp="$(cat "$tmp_body")"
      rm -f "$tmp_body"

      if [[ "$http_code" == "200" ]]; then
        printf '%s\n' "$resp"
        return 0
      fi

      echo "❌ [qdrant_search] HTTP=${http_code}" >&2
      if jq -e . >/dev/null 2>&1 <<<"$resp"; then
        echo "$resp" | jq -C '.' >&2
      else
        echo "$resp" >&2
      fi
      return 1
    fi

    rm -f "$tmp_body"
    if [[ $attempt -lt $max_retries ]]; then
      echo "⚠️  [qdrant_search] curl 失敗 (exit=$curl_exit)，重試 $attempt/$max_retries..." >&2
      sleep $retry_delay
    else
      echo "❌ [qdrant_search] curl 失敗 (exit=$curl_exit)，已重試 $max_retries 次" >&2
      return 1
    fi
  done

  return 1
}

########################################
# 文件級寫入：Markdown → embedding → Qdrant upsert
########################################

# qdrant_upsert_document MD_FILE [LAYER_NAME] [COLLECTION]
#
# 功能：
#   - 解析 Markdown 的 YAML frontmatter 與正文
#   - 以 source_url 去重（已存在則跳過）
#   - 將「標題 + 正文」做 embedding，寫入 Qdrant（payload 含必要欄位）
#
# 回傳：
#   0 = 成功寫入或已存在跳過；1 = 失敗
#
# 相依：chatgpt.sh（embedding）、python3、jq、curl
qdrant_upsert_document() {
  local md_file="$1"
  local layer_name="${2:-}"
  local collection_name="${3:-${QDRANT_COLLECTION:-}}"

  require_cmd curl jq python3 || return 1

  if [[ ! -f "$md_file" ]]; then
    echo "❌ [qdrant_upsert_document] 檔案不存在: $md_file" >&2
    return 1
  fi
  if [[ -z "$collection_name" ]]; then
    echo "❌ [qdrant_upsert_document] 未指定 collection（QDRANT_COLLECTION 或第三參數）" >&2
    return 1
  fi

  # 確保 embedding 函式可用
  if ! declare -f chatgpt_embed_batch >/dev/null 2>&1; then
    . "${_qdrant_lib_dir}/chatgpt.sh" 2>/dev/null || {
      echo "❌ [qdrant_upsert_document] 無法載入 chatgpt.sh" >&2; return 1; }
  fi
  if [[ -z "${CHATGPT_API_KEY:-}" ]]; then
    chatgpt_init_env >/dev/null 2>&1 || true
  fi

  # 解析 frontmatter + 正文 → JSON {source_url, payload, embed_text}
  local parsed
  parsed="$(python3 - "$md_file" "$layer_name" <<'PY'
import sys, json, re
path = sys.argv[1]
layer = sys.argv[2] if len(sys.argv) > 2 else ""
txt = open(path, encoding="utf-8").read()
head = txt.split("---", 1)[0] if "---" in txt else txt
review = "[REVIEW_NEEDED]" in head
m = re.search(r'^---\s*$(.*?)^---\s*$', txt, re.M | re.S)
fm, body = {}, txt
if m:
    block = m.group(1)
    body = txt[m.end():].strip()
    for line in block.splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        mm = re.match(r'^([A-Za-z_][\w]*):\s*(.*)$', line)
        if not mm:
            continue
        k, v = mm.group(1), mm.group(2).strip()
        if len(v) >= 2 and v[0] in "\"'" and v[-1] == v[0]:
            v = v[1:-1]
        fm[k] = v
src = fm.get("source_url", "").strip()
title = fm.get("title", "").strip()
if not title:
    # 後備：部分 Layer（如 hn_hiring、oecd_stats）無 title 欄位，改取正文第一個 H1 標題
    hm = re.search(r'^#\s+(.+?)\s*$', body, re.M)
    if hm:
        title = hm.group(1).strip()
payload = {
    "source_url": src,
    "title": title,
    "source_layer": fm.get("source_layer", layer) or layer,
    "category": fm.get("category", ""),
    "date": fm.get("date", ""),
    "fetched_at": fm.get("fetched_at", ""),
    "severity": fm.get("severity", ""),
    "confidence": fm.get("confidence", ""),
    "review_needed": review,
    "original_content": body[:4000],
}
embed_text = (title + "\n\n" + body)[:6000]
# doc_key：以「docs/Extractor 之下的相對路徑（去副檔名）」作為每份文件的唯一鍵，
# 避免統計型 Layer 多筆 .md 共用同一 source_url 時被塌縮成單一向量點。
marker = "/docs/Extractor/"
i = path.find(marker)
doc_key = path[i + len(marker):] if i >= 0 else path
if doc_key.endswith(".md"):
    doc_key = doc_key[:-3]
print(json.dumps({"source_url": src, "doc_key": doc_key, "payload": payload, "embed_text": embed_text}, ensure_ascii=False))
PY
)" || { echo "❌ [qdrant_upsert_document] 解析失敗: $md_file" >&2; return 1; }

  local source_url doc_key
  source_url="$(printf '%s' "$parsed" | jq -r '.source_url // ""')"
  doc_key="$(printf '%s' "$parsed" | jq -r '.doc_key // ""')"
  if [[ -z "$source_url" ]]; then
    echo "⚠️  [qdrant_upsert_document] 無 source_url，跳過: $md_file" >&2
    return 1
  fi

  # point_id 以 doc_key（每份文件唯一）為主鍵，確保每筆 .md 對應一個向量點
  local point_id
  point_id="$(_qdrant_id_to_uuid "$doc_key")"

  # 去重：以 point_id 直接查存在（不需 payload index）
  if qdrant_point_exists "$collection_name" "$point_id" >/dev/null 2>&1; then
    echo "  ⊘ 已存在，跳過: $(basename "$md_file")"
    return 0
  fi

  # Embedding
  local tmpin tmpout
  tmpin="$(mktemp)"; tmpout="$(mktemp)"
  printf '%s\n' "$(printf '%s' "$parsed" | jq -c '.embed_text')" > "$tmpin"
  chatgpt_embed_batch "$tmpin" "$tmpout" 1 >/dev/null 2>&1
  local vector_json
  vector_json="$(head -1 "$tmpout" 2>/dev/null)"
  rm -f "$tmpin" "$tmpout"
  if [[ -z "$vector_json" || "$vector_json" == "null" ]]; then
    echo "  ✗ embedding 失敗: $(basename "$md_file")" >&2
    return 1
  fi

  # Upsert
  local payload_json
  payload_json="$(printf '%s' "$parsed" | jq -c '.payload')"
  if qdrant_upsert_point "$collection_name" "$point_id" "$vector_json" "$payload_json" >/dev/null 2>&1; then
    echo "  ✓ 寫入 Qdrant: $(basename "$md_file")"
    return 0
  else
    echo "  ✗ Qdrant 寫入失敗: $(basename "$md_file")" >&2
    return 1
  fi
}

# 別名：相容各 Layer update.sh 使用的不同函式名
# qdrant_upsert_markdown MD_FILE LAYER_NAME [COLLECTION]
qdrant_upsert_markdown() { qdrant_upsert_document "$@"; }
# qdrant_upsert_from_md MD_FILE [LAYER_NAME] [COLLECTION]（layer 由 frontmatter 推導）
qdrant_upsert_from_md() { qdrant_upsert_document "$1" "${2:-}" "${3:-}"; }
