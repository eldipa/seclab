#!/bin/bash

set -e -o pipefail

# SSH/SCP config stuff
SSH_KEYFILE=./seclab-ssh.key
if [ ! -f "$SSH_KEYFILE" ]; then
    echo "SSH/SCP keyfile '$SSH_KEYFILE' for seclab account does not exist."
    echo "Abort."
    exit 1
fi

# More options
# Format:   <port>
if [ ! -z "$2" ]; then
    SSH_PORT="$(echo -n "$5" | awk -F ':' '{print $3}')"
fi

SSH_USER="seclab"
SSH_IP="127.0.0.1"
SSH_PORT="${SSH_PORT:-2222}"

if [ -z "$SSH_USER" -o -z "$SSH_IP" -o -z "$SSH_PORT" ]; then
    echo "SSH/SCP config incorrect: user='$SSH_USER' ip='$SSH_IP' port='$SSH_PORT'"
    echo "Abort."
    exit 1
fi

ARTIFACT_SCENARIO_DIR="challenges/$1/"

if [ ! -d "$ARTIFACT_SCENARIO_DIR" -o ! -f "$ARTIFACT_SCENARIO_DIR/challenge.data" -o ! -f "$ARTIFACT_SCENARIO_DIR/challenge.data.checksum" ]; then
    echo "Scenario artifacts '$ARTIFACT_SCENARIO_DIR' does not exist or it is incomplete."
    echo "Abort."
    exit 1
fi

BASE=$(pwd)
cd "$ARTIFACT_SCENARIO_DIR"
echo 'put -f challenge.data*' | sftp -P ${SSH_PORT} -i "$BASE/$SSH_KEYFILE" -b - ${SSH_USER}@${SSH_IP}

rm -f log-play-scenario
touch log-play-scenario
tail -f log-play-scenario &
while :; do
    sleep 10
    echo 'get -f -a log log-play-scenario' | sftp -P ${SSH_PORT} -i "$BASE/$SSH_KEYFILE" -b - ${SSH_USER}@${SSH_IP} > /dev/null
done
