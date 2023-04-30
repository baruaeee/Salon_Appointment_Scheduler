#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?"
MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo -e "Pick a service by ID!"
  read SERVICE_ID_SELECTED
  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please enter a valied number!"
  elif [[ -z $SERVICE_SELECTED ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    echo -e "\nWhat time would you like your $(echo $SERVICE_SELECTED | sed -E 's/^ //g'), $CUSTOMER_NAME?"
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    read SERVICE_TIME
    if [[ $SERVICE_TIME ]]
    then
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo "I have put you down for a $(echo $SERVICE_SELECTED | sed -E 's/^ //g') at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU