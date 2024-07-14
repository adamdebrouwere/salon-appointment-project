#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Salon Appointments Assistant ~~~\n"
echo -e "\nWhich of our lovely services would you like?\n"

#service selector
SELECT_SERVICE() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES_DISPLAY;
  APPOINTMENT_CREATOR;
  EXIT;
}

SERVICES_DISPLAY() {
  ALL_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  #display numbered list of services
  echo "$ALL_SERVICES" | while read SERVICE_ID _ NAME _
  do
    echo -e "$SERVICE_ID) $NAME"
  done
}

APPOINTMENT_CREATOR() {
  
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SELECT_SERVICE "That's not a service we offer. Please try again.\n"
  else
    IS_ON_SERVICES_MENU=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
        
    if [[ -z $IS_ON_SERVICES_MENU ]]
    then
      SELECT_SERVICE "That's not a service we offer. Please try again.\n"
    else
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE

      if [[ ! $CUSTOMER_PHONE =~ ^[0-9-]+$ ]]
      then
        SELECT_SERVICE "Please enter an appropriate phone number."
      else
      
        IS_CUSTOMER=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")
        
        if [[ -z $IS_CUSTOMER ]]
        then
          echo -e "\nWhat is your name?"
          read CUSTOMER_NAME
        
          if [[ -z $CUSTOMER_NAME ]]
          then
            SELECT_SERVICE "Please enter something as you name."
          else 
            INSERT_NEW_CLIENT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          fi
        fi

        GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") 
        SERVICE_NAME_FORMATTED=$(echo $GET_SERVICE_NAME | sed -E 's/^ *| *$//g')
        GET_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        CUSTOMER_NAME_FORMATTED=$(echo $GET_CUSTOMER_NAME | sed -E 's/^ *| *$//g')

        echo -e "\nWhat time would you like to come in for your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
        read SERVICE_TIME

        if [[ ! $SERVICE_TIME =~ ^[0-9:]+( )?(am|pm|AM|PM)?$ ]]
        then
          SELECT_SERVICE "Please input an appropriate time."
        else
          GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          
          INSERT_APPOINTMENT_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($GET_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

          echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
        
        fi
      fi
    fi
  fi
}

EXIT() {
  echo -e "\nThank you for stopping by! Please come back soon!"
  exit
}


SELECT_SERVICE
