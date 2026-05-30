#!/bin/bash

echo "Configuration Management for $COMPONENT $ENVIRONMENT in progress"

ID=$(id -u)
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


create_user() {
    id $APPUSER &>> $LOG
    if [ $? -ne 0 ]; then
        echo -n "creating user add roboshop: "
        useradd $APPUSER &>> $LOG
        stat $?
    else
        echo -n "user roboshop already exists: "
    fi
    stat $?
}
















#     i d $APPUSER &>/dev/null || useradd $APPUSER
#     stat $?
# }
# if [ "$USER" != "roboshop" ]; then
    #     echo -e "\e[33m This script should be run as roboshop user \e[0m"
    #     echo -e "\e[33m Use: su - roboshop \e[0m"
    #     exit 3
# fi



####