#! /bin/bash

PSQL='psql --username=freecodecamp --dbname=salon --no-align -t -c'
SERVICE_ID_SELECTED=""
service_name=""
CUSTOMER_PHONE=""
SERVICE_TIME=""
person_num=""
CUSTOMER_NAME=""


echo ""
echo "~~~~~ MY SALON ~~~~~"
echo ""
echo "Welcome to My Salon, how can I help you?"
echo ""

services=$($PSQL "SELECT service_id, name FROM services;")
services_formatted=()
services_names=()
services_ids=()

while IFS='|' read -r service_id service_name; do
  services_formatted+=("$service_id) $service_name")
  services_ids+=("$service_id")
  services_names+=("$service_name")
done <<< "$services"

printf '%s\n' "${services_formatted[@]}"
echo ""

# Select service
while [[ -z $SERVICE_ID_SELECTED ]]; do
  read SERVICE_ID_SELECTED
  if [[ $(echo ${services_ids[@]} | grep -ow "$SERVICE_ID_SELECTED" | wc -w) -eq 0 ]]; then
    echo ""
    echo "I could not find that service. What would you like today?"
    echo ""
    echo "${services_formatted[@]}"
  fi
done

echo ""
echo "Please enter your phone number:"

# Enter phone number, look up customer
while [[ -z $CUSTOMER_PHONE ]]; do
  read CUSTOMER_PHONE
  while IFS='|' read -r customer_id customer_name; do
    person_num="$customer_id"
    CUSTOMER_NAME="$customer_name"
  done <<< "$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
done

if [[ -z $CUSTOMER_NAME ]]; then
  while [[ -z $CUSTOMER_NAME ]]; do
    echo ""
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
  done
  $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
  person_num=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME';")
  echo ""
else
  echo ""
  echo "Hi, $CUSTOMER_NAME!"
fi

echo "What time would you like your appointment to be scheduled?"

while [[ -z $SERVICE_TIME ]]; do
  read SERVICE_TIME
done

service_name=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($person_num, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

echo "I have put you down for a $service_name at $SERVICE_TIME, $CUSTOMER_NAME."
echo ""
