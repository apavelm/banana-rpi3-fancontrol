#!/bin/sh

HOST=$(cat /proc/sys/kernel/hostname)

PWM_STATE_FILE="/var/run/fancontrol_pwm"
TEMP_STATE_FILE="/var/run/fancontrol_temp"

INTERVAL=10

#exec 3<> >(socat - UNIX-CONNECT:$SOCK)

while true; do
  # PWM
  if [ -f "$PWM_STATE_FILE" ]; then
    read PWM < "$PWM_STATE_FILE"
    PWM=${PWM:-0}
  else
    PWM=0
  fi

  PWM_INV=$((255 - PWM))

  # TEMP
  if [ -f "$TEMP_STATE_FILE" ]; then
    read TEMP < "$TEMP_STATE_FILE"
    TEMP=${TEMP:-0}
  else
    TEMP=0
  fi

  TEMP_FLOAT=$(awk "BEGIN { printf \"%.2f\", $TEMP/1000 }")

  TS=$(date +%s)

  echo "PUTVAL \"$HOST/fan/fanpwm\" $TS:$PWM_INV"
  echo "PUTVAL \"$HOST/fan/fantemp\" $TS:$TEMP_FLOAT"


  # PWM (int)
  #printf "PUTVAL \"%s/fan/fanpwm\" %d:%d\n" "$HOST" "$TS" "$PWM_INV" >&3

  # TEMP (float)
  #printf "PUTVAL \"%s/fan/fantemp\" %d:%s\n" "$HOST" "$TS" "$TEMP_FLOAT" >&3

  sleep "$INTERVAL"
done
