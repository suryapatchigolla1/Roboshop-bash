#!/bin/bash

COMPONENT="rabbitmq"
LOG="/tmp/${COMPONENT}.log"
source ./common.sh

echo -n "Configuring RabbitMQ repo: "
cp "$SCRIPT_DIR/$COMPONENT.repo" /etc/yum.repos.d/$COMPONENT.repo &>> $LOG    
stat $?

echo -n "Install $COMPONENT server: "
dnf install rabbitmq-server -y &>> $LOG
stat $?

echo -n "Enablingand starting $COMPONENT server: "
systemctl enable rabbitmq-server &>> $LOG
systemctl start rabbitmq-server &>> $LOG
systemctl status rabbitmq-server -l &>> $LOG
stat $?

echo -n "Configuring $COMPONENT user: "
rabbitmqctl add_user ${APPUSER} roboshop123
stat $?

echo -n "Configuring $APPUSER permissions: "
rabbitmqctl set_user_tags ${APPUSER} administrator
rabbitmqctl set_permissions -p / ${APPUSER} ".*" ".*" ".*"
stat $?

echo -e "\n \t ___ Configuration Management for $COMPONENT in completed! ___"