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
if [ $? -ne 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "Enable nginx:1.24 version"
dnf module enable nginx:1.24 -y &>> $LOG
if [ $? -ne 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "Install nginx"
dnf install nginx -y &>> $LOG
if [ $? -ne 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "Download the $COMPONENT component code"
curl -L -o /tmp/${COMPONENT}.zip https://stan-robotshop.s3.amazonaws.com/$COMPONENT-v3.zip
if [ $? -ne 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "Perform cleanup and unzip the $COMPONENT code"
cd /usr/share/nginx/html 
rm -rf * &>> $LOG
if [ $? -ne 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "extract the $COMPONENT component code"
unzip /tmp/$COMPONENT.zip &>> $LOG
if [ $? -ne 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "Start $COMPONENT service"
systemctl enable nginx &>> $LOG
systemctl restart nginx &>> $LOG
if [ $? -ne 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "Configuration Management for $COMPONENT is completed"