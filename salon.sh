#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
  echo -e "\nWelcome to My Salon, how can I help you?\n"

#service selector
SELECT_SERVICE() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  


  ALL_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  #display numbered list of services
  echo "$ALL_SERVICES" | while read -r SERVICE_ID _ NAME
  do
    echo -e "$SERVICE_ID) $NAME"
  done

  APPOINTMENT_CREATOR
  EXIT
}

APPOINTMENT_CREATOR() {
  
  read SERVICE_ID_SELECTED
  IS_ON_SERVICES_MENU=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ || -z $IS_ON_SERVICES_MENU ]]
  then
    SELECT_SERVICE "I could not find that service. What would you like today?"
    return
  fi 
  
  
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  if [[ ! $CUSTOMER_PHONE =~ ^[0-9-]+$ ]]
  then
    echo "Please enter an appropriate phone number."
    read CUSTOMER_PHONE
  fi
    
  IS_CUSTOMER=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")
      
  if [[ -z $IS_CUSTOMER ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
  
    #while [[ -z $CUSTOMER_NAME ]]
    #do
      #echo "Please enter something as you name."
      #read CUSTOMER_NAME
    #done

    INSERT_INTO_DB=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") 
  SERVICE_NAME_FORMATTED=$(echo $GET_SERVICE_NAME | sed -E 's/^ *| *$//g')
  GET_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME_FORMATTED=$(echo $GET_CUSTOMER_NAME | sed -E 's/^ *| *$//g')

  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME

  #while [[ ! $SERVICE_TIME =~ ^[0-9:]+( )?(am|pm|AM|PM)?$ ]]
  #do
    #echo "Please input an appropriate time."
    #read SERVICE_TIME
  #done

  
  GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  INSERT_INTO_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($GET_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  EXIT 
}

EXIT() {
  #echo -e "\nThank you for stopping by! Please come back soon!"
  exit
}


SELECT_SERVICE
