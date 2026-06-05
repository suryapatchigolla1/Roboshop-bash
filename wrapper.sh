#!/bin/bash


component=$1
environment=$2
if [ -z "$1" ] &&  [ -z "$2" ]; then
    echo -e "Expected usage \n \t : sudo bash $0 componentName environment name"
    exit 3
fi

bash ${1}.sh $ENVIRONMENT









# COMPONENT="mysql"
# source ./common.sh


# echo -n "Install $COMPONENT server: "
# dnf install mysql-server -y &>> $LOG
# stat $?

# echo -n "Enabling $COMPONENT server: "
# systemctl enable mysqld &>> $LOG
# stat $?

# echo -n "Starting $COMPONENT server: "
# systemctl start mysqld &>> $LOG
# stat $?

# echo -n "Configuring the Root password: "
# mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG
# stat $? 

# echo -e "\n \t ___ Configuration Management for $COMPONENT in completed! ___.."
