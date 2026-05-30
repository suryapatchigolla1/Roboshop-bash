#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Configuration Management for $COMPONENT $ENVIRONMENT in progress"
COMPONENT="user"
source ./common.sh
nodejs

