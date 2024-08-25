#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo "$1"
  fi
  #get services
  SERVICES_OFFERED=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  #display services
  echo "$SERVICES_OFFERED" | while read SERVICE_ID BAR SERVICE
  do
    echo -e "$SERVICE_ID) $SERVICE"
  done

  #select service
  read SERVICE_ID_SELECTED

  #if not number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
  #return to main menu
  MAIN_MENU "Please, enter a valid number"

  else
    #get service
    SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    #if doesnt exist
    if [[ -z $SELECTED_SERVICE ]]
    then
      #return to main menu
      MAIN_MENU "Select a valid service id"
      #else get client phone
    else
      echo -e "\nEnter your phone number"
      read CUSTOMER_PHONE
      #if not in customers
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then
        #get customer name
        echo -e "\nYou don't seem to be registered, enter your name please"
        read CUSTOMER_NAME
        #insert into customers
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        
      fi
      #get time
      echo -e "\nAt what time would you like the appointment?"
      read SERVICE_TIME

      #check if its a real time

      #insert into appointments
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")

      #display appointment message
      echo -e "\nI have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME." | sed -E 's/ +/ /g'
    fi
  fi
}


MAIN_MENU