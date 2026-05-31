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

download_and_extract() {
    echo -n "performing cleanup: "
    rm -rf /app || true &>> $LOG
    stat $?

    echo -n "creating APP directory: "
    mkdir -p /app &>> $LOG
    stat $?

    echo -n "Downloading the $COMPONENT component code: "
    curl -o /tmp/$COMPONENT.zip https://stan-robotshop.s3.amazonaws.com/${COMPONENT}-v3.zip &>> $LOG
    stat $?

    echo -n "Extracting the $COMPONENT code: "
    unzip -o /tmp/$COMPONENT.zip -d /app &>> $LOG
    stat $?
}

config_svc() {
    echo -n "Copying $COMPONENT systemd file: "
    cp "$SCRIPT_DIR/${COMPONENT}.service" /etc/systemd/system/${COMPONENT}.service
    stat $?

    echo -n "Starting $COMPONENT service: "
    systemctl daemon-reload 
    systemctl enable $COMPONENT &>> $LOG
    systemctl start $COMPONENT &>> $LOG
    stat $?
}

install_mongo_shell() {
    echo -n "Configuring Mongo shell repo: "
    cp "$SCRIPT_DIR/mongo.repo" /etc/yum.repos.d/mongo.repo &>> $LOG    

    echo "Installation mongodb shell: "
    dnf install mongodb-mongosh -y &>> $LOG
    stat $?
}


install_mysql() {
    echo -n "Install mysql server: "
    dnf install mysql -y &>> $LOG
    stat $?
}

nodejs() {
    echo -n "Disabling Node.js module: "
    dnf module disable nodejs -y &>> $LOG
    stat $?

    echo -n "Enabling Node.js 18.x: "
    dnf module enable nodejs:18 -y &>> $LOG
    stat $?

    echo -n "Installing Node.js: "
    dnf install nodejs -y &>> $LOG
    stat $?

    create_user #source ./common.sh

    download_and_extract

    config_svc

    echo -n "Generation $COMPONENT Artifact: "
    cd /app 
    npm install &>> $LOG
    stat $?
   
    if [ $COMPONENT == "catalogue" ]; then    
        echo -n "Loading $COMPONENT schema: "
        mongosh --host mongodb.robo60.online </app/db/master-data.js &>> $LOG
        stat $?
    fi  

    echo -e "\n \t ___ Configuration Management for $COMPONENT in completed! ___"
}



maven() {
    echo -n "Installing maven: "
    dnf install maven -y &>> $LOG
    stat $?

    create_user #source ./common.sh

    download_and_extract

    echo -n "Generation $COMPONENT Artifact: "
    cd /app 
    mvn clean package &>> $LOG
    mv target/$COMPONENT-1.0.jar ${COMPONENT}.jar &>> $LOG
    stat $?

    install_mysql

    if [ $COMPONENT == "shipping" ]; then    
        echo -n "Loading schema: "
        mysql -h shipping.robo60.online -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOG
        stat $?
        echo -n "Injection the appUser: "
        mysql -h shipping.robo60.online -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOG
        stat $?
        echo -n "Loading the appUser data: "
        mysql -h shipping.robo60.online -uroot -pRoboShop@1 < /app/db//master-data.sql &>> $LOG
        stat $?
    fi  

    config_svc

    echo -e "\n \t ___ Configuration Management for $COMPONENT in completed! ___"
    
}




        # echo -n "Copying JAR file: "
        # mv target/shipping-1.0.jar shipping.jar 
        # stat $?


#     i d $APPUSER &>/dev/null || useradd $APPUSER
#     stat $?
# }
# if [ "$USER" != "roboshop" ]; then
    #     echo -e "\e[33m This script should be run as roboshop user \e[0m"
    #     echo -e "\e[33m Use: su - roboshop \e[0m"
    #     exit 3
# fi



####