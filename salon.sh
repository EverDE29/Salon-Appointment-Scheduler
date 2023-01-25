#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi

  echo "Which service would you like done?"
  echo -e "\n1) Hair\n2) Color\n3) Nail\n4) Exit"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
  1|2|3) SERVICE_MENU ;;
  4) EXIT ;;
  *) MAIN_MENU "Please enter a valid option."
  esac
}

SERVICE_MENU() {
  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # if phone number isn't valid
  if [[ -z $CUSTOMER_PHONE || $CUSTOMER_PHONE =~ ^[a-z]+$ ]]
    then
      SERVICE_MENU 
  fi

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nWould you please enter your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # get appointment time
  echo -e "\nWhat time would you like to schedule?"
  read SERVICE_TIME

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # insert new appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # get service name
  SERVICE_NAME=$($PSQL "SELECT s.name FROM customers INNER JOIN appointments USING(customer_id) INNER JOIN services AS s USING(service_id) WHERE customer_id=$CUSTOMER_ID AND time='$SERVICE_TIME'")

  # salon acknowledges customer's scheduled appointment
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/ //') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ //')."

} 

EXIT() {
  echo -e "\nThank you for your time.\n"
}

MAIN_MENU