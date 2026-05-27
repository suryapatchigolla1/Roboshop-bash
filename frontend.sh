#!/bin/bash

echo "Configuration Management for $COMPONENT $ENVIRONMENT in progress"

ID=$(id -u)
COMPONENT="frontend"
LOG="/tmp/${COMPONENT}.log"


if [ $ID -ne 0 ]; then
    echo "This script must be run as root"
    echo "Use: sudo $0"
    exit 1
fi

stat() {
    if [ $1 -eq 0 ]; then 
        echo -e "\e[32m Success \e[0m"
    else
        echo -e "\e[33m Failure \e[0m "
        exit 2
    fi 
}

echo -n "Disable default nginx version: "
dnf module disable nginx -y &>> $LOG
stat $?

echo -n "Enable nginx:1.24 version: "
dnf module enable nginx:1.24 -y &>> $LOG
stat $?


echo -n "Install nginx: "
dnf install nginx -y &>> $LOG
stat $?


echo -n "Download the $COMPONENT component code: "
curl -L -o /tmp/${COMPONENT}.zip https://stan-robotshop.s3.amazonaws.com/$COMPONENT-v3.zip
stat $?


echo -n "Perform cleanup and unzip the $COMPONENT code: "
cd /usr/share/nginx/html 
rm -rf * &>> $LOG
stat $?


echo -n "Extract the $COMPONENT component code: "
unzip  -o /tmp/$COMPONENT.zip &>> $LOG
stat $?

echo -n "Configuring $COMPONENT proxy file"
cp nginx.conf /etc/nginx/nginx.conf
sed -i -e "s/env/${ENVIRONMENT}/g" /etc/nginx/nginx.conf
stat $?

echo -n "Start $COMPONENT service: "
systemctl enable nginx &>> $LOG
systemctl restart nginx &>> $LOG
stat $?

echo -e "\n \t ___ Configuration Management for $COMPONENT in completed! ___"

###