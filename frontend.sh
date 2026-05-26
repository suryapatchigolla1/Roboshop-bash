#!/bin/bash

echo "Configuration Management for $COMPONENT $ENVIRONMENT in progress"
echo "Disable default nginx version"
dnf module disable nginx -y
echo "Enable nginx:1.24 version"
dnf module enable nginx:1.24 -y
echo "Install nginx"
dnf install nginx -y