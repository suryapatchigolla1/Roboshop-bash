#!/bin/bash

COMPONENT="frontend"
LOG="/tmp/${COMPONENT}.log"
echo "Configuration Management for $COMPONENT $ENVIRONMENT in progress"

# It should run as root user or
ID=$(id -u)

if [ $ID -ne 0 ]; then
  echo "This script must be run as root"
  echo "Use: sudo $0"
  exit 1
fi

echo "Disable default nginx version"
dnf module disable nginx -y >> "$LOG" 2>&1
if [ $? -eq 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "Enable nginx:1.24 version"
dnf module enable nginx:1.24 -y >> "$LOG" 2>&1
if [ $? -eq 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "Install nginx"
dnf install nginx -y >> "$LOG" 2>&1
if [ $? -eq 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "Download the $COMPONENT component code"
curl -L -o /tmp/${COMPONENT}.zip https://stan-robotshop.s3.amazonaws.com/$COMPONENT-v3.zip
if [ $? -eq 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "Perform cleanup and unzip the $COMPONENT code"
cd /usr/share/nginx/html 
rm -rf * >> "$LOG" 2>&1
if [ $? -eq 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "extract the $COMPONENT component code"
unzip /tmp/$COMPONENT.zip >> "$LOG" 2>&1
if [ $? -eq 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "Start $COMPONENT service"
systemctl enable nginx >> "$LOG" 2>&1
systemctl restart nginx >> "$LOG" 2>&1
if [ $? -eq 0 ]; then
    echo "Pass"
else    
    echo "Fail"    
    exit 2
fi

echo "Configuration Management for $COMPONENT is completed"