#!/bin/bash


ID=$(id -u)
COMPONENT="redis"
LOG="/tmp/${COMPONENT}.log"
VERSION="7"

if [ $ID -ne 0 ]; then
    echo "This script must be run as root"
    echo "Use: sudo $0"
    exit 1
fi

echo "Configuration Management for $COMPONENT in progress"

stat() {
    if [ $1 -eq 0 ]; then 
        echo -e "\e[32m Success \e[0m"
    else
        echo -e "\e[33m Failure \e[0m "
        exit 2
    fi 
}

echo -n "Disable default $COMPONENT version: "
dnf module disable $COMPONENT -y &>> $LOG
stat $?

echo -n "Enable $VERSION: "
dnf module enable redis:7 -y &>> $LOG
stat $?

echo -n "Install $COMPONENT: "
dnf install $COMPONENT -y &>> $LOG
stat $?

echo -n "Updating the $COMPONENT configuration file: "
sed -ie 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf &>> $LOG
stat $?

echo -n "Updating the $COMPONENT Protected mode: "
sed -ie 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>> $LOG
stat $?

echo -n "Start $COMPONENT service: "
systemctl enable $COMPONENT &>> $LOG
systemctl start $COMPONENT &>> $LOG
stat $? 


echo -e "\n \t ___ Configuration Management for $COMPONENT in completed! ___"
