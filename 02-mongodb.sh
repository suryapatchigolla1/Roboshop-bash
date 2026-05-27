#!/bin/bash





ID=$(id -u)
COMPONENT="mongodb"
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

echo "Configuration Management for $COMPONENT in progress"
echo -n "Configuring the repo: "
cp mongo.repo /etc/yum.repos.d/mongo.repo
stat $?

echo -n "Install $COMPONENT: "
dnf install mongodb-org -y &>> $LOG
stat $?

echo -n "Updating the $COMPONENT configuration file: "
sed -ie 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
stat $?

echo -n "Start $COMPONENT service: "
systemctl enable mongod &>> $LOG
systemctl start mongod &>> $LOG
stat $? 

