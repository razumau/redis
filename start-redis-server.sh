#!/bin/sh

set -e

sysctl vm.overcommit_memory=1 || true
sysctl net.core.somaxconn=1024 || true

PW_ARG=""
if [[ ! -z "${REDIS_PASSWORD}" ]]; then
  PW_ARG="--requirepass $REDIS_PASSWORD"
fi

# Set maxmemory-policy to 'allkeys-lru' for caching servers that should always evict old keys
: ${MAXMEMORY_POLICY:="allkeys-lru"}
: ${APPENDONLY:="no"}
: ${FLY_VM_MEMORY_MB:=256}
if [ "${NOSAVE}" = "" ] ; then
  : ${SAVE:="3600 1 300 100 60 10000"}
fi
# Set maxmemory to 80% of available memory
MAXMEMORY=$(($FLY_VM_MEMORY_MB*80/100))

redis-server $PW_ARG \
  --dir /data/ \
  --maxmemory "${MAXMEMORY}mb" \
  --maxmemory-policy $MAXMEMORY_POLICY \
  --appendonly $APPENDONLY \
  --save "$SAVE"
