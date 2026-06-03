#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPONENT="shipping"

echo "Configuration Management for $COMPONENT $ENVIRONMENT in progress"
source "$SCRIPT_DIR/common.sh"
maven

