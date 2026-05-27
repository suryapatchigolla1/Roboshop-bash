#!/bin/bash

echo "Configuration Management for $COMPONENT $ENVIRONMENT in progress"

# It should run as root user or

ID=$(id -u)

if [ $ID -ne 0 ]; then
  echo "This script must be run as root"
  echo "Use: sudo $0"
  exit 1
fi

echo "Disable default nginx version"
dnf module disable nginx -y

echo "Enable nginx:1.24 version"
dnf module enable nginx:1.24 -y

echo "Install nginx"
dnf install nginx -y
#
echo "Download the frontend code"
curl -L -o /tmp/frontend.zip https://stan-robotshop.s3.amazonaws.com/frontend-v3.zip

echo "Perform cleanup and unzip the frontend code"
cd /usr/share/nginx/html
rm -rf *

echo "extract the frontend code"
unzip /tmp/frontend.zip


echo "Start nginx service"
systemctl enable nginx
systemctl restart nginx

echo "Configuration Management for frontend is completed"