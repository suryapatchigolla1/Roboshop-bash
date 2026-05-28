#!/bin/bash

echo "Configuration Management for $COMPONENT $ENVIRONMENT in progress"

ID=$(id -u)
COMPONENT="catalogue"
APPUSER="roboshop"
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

echo -n "Disabling Node.js module: "
dnf module disable nodejs -y &>> $LOG
stat $?

echo -n "Enabling Node.js 20 module: "
dnf module enable nodejs:20 -y &>> $LOG 
stat $?

echo -n "Installing Node.js: "
dnf install nodejs -y &>> $LOG
stat $?

echo -n "creating user add roboshop: "
id $APPUSER &>/dev/null || useradd $APPUSER
stat $?

echo -n "perdorming cleanup: "
rm -rf /app || true &>> $LOG
stat $?

echo -n "creating APP directory: "
mkdir -p /app &>> $LOG
stat $?

echo -n "Downloading the $COMPONENT component code: "
curl -o /tmp/$COMPONENT.zip https://stan-robotshop.s3.amazonaws.com/${COMPONENT}-v3.zip &>> $LOG
stat $?

echo -n "Copying $COMPONENT systemd file: "
cp ${COMPONENT}.service /etc/systemd/system/${COMPONENT}.service
stat $?

echo -n "Extracting the $COMPONENT code: "
unzip -o /tmp/${COMPONENT}.zip -d /app &>> $LOG
stat $?

echo -n "Generation $COMPONENT Artifact: "

cd /app && npm install &>> $LOG
stat $?

echo "Installation mongodb schema: "
dnf install mongodb-mongosh -y &>> $LOG
stat $?

echo -n "Loading $COMPONENT schema: "
mongosh --host mongodb.robo60.online </app/db/master-data.js &>> $LOG
stat $?

echo -n "Starting $COMPONENT service: "
systemctl daemon-reload
systemctl enable $COMPONENT &>> $LOG
systemctl start $COMPONENT &>> $LOG
stat $?

echo -e "\n \t ___ Configuration Management for $COMPONENT in completed! ___"



# 