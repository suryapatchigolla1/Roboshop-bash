#!/bin/bash

echo "Configuration Management for $COMPONENT $ENVIRONMENT in progress"

# It should run as root user or
ID=$(id -u)
COMPONENT="frontend"
LOG="/tmp/${COMPONENT}.log"

if [ $ID -ne 0 ]; then
  echo "This script must be run as root"
  echo "Use: sudo $0"
  exit 1
fi

echo "Disable default nginx version"
dnf module disable nginx -y  &>> $LOG

echo "Enable nginx:1.24 version"
dnf module enable nginx:1.24 -y &>> $LOG

echo "Install nginx"
dnf install nginx -y &>> $LOG
#
echo "Download the $COMPONENT component code"
curl -L -o /tmp/${COMPONENT}.zip https://stan-robotshop.s3.amazonaws.com/$COMPONENT-v3.zip

echo "Perform cleanup and unzip the $COMPONENT code"
cd /usr/share/nginx/html 
rm -rf * &>> $LOG

echo "extract the $COMPONENT component code"
unzip /tmp/$COMPONENT.zip &>> $LOG


echo "Start $COMPONENT service"
systemctl enable nginx &>> $LOG
systemctl restart nginx &>> $LOG

echo "Configuration Management for $COMPONENT is completed"