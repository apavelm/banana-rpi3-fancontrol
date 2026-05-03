#!/bin/sh

echo "fancontrol: daemon started"

DEBUG=1
HYST=2000
PREV_PWM=-1
SPEED_CHANGED=1
PWM_FILE="/sys/devices/platform/pwm-fan/hwmon/hwmon1/pwm1"
CPU_TEMP_FILE="/sys/class/thermal/thermal_zone0/temp"
SENSOR1="/sys/class/hwmon/hwmon2/temp1_input"
SENSOR2="/sys/class/hwmon/hwmon3/temp1_input"
LOG_FILE="/var/tmp/fancontrol.tmp"
PID_FILE="/var/run/fancontrol.pid"

# points
P0=45000
P1=52000
P2=63000
P3=66000
P4=69000

# night-mode points
NP0=52000
NP1=58000
NP2=62000
NP3=67000
NP4=69000


read_temp() {
  [ -f "$1" ] && read val < "$1" && echo "$val" || echo 0
}


  echo "Advanced fan control started"

  # this fixes the issue with PWM
  echo 0 > /sys/devices/platform/pwm-fan/hwmon/hwmon1/pwm1_enable
 
  while true; do
    CPU_TEMP=$(read_temp "$CPU_TEMP_FILE")
    T1=$(read_temp "$SENSOR1")
    T2=$(read_temp "$SENSOR2")
    HOUR=$(date +%H)

# this to set night-mode (21.00 - 08.00)
    if [ "$HOUR" -ge 21 ] || [ "$HOUR" -lt 8 ]; then
      POINT0=$NP0; POINT1=$NP1; POINT2=$NP2; POINT3=$NP3; POINT4=$NP4
    else
      POINT0=$P0; POINT1=$P1; POINT2=$P2; POINT3=$P3; POINT4=$P4;
    fi

    AVG_TEMP=$(( (T1 + T2) / 2 ))

    if [ "$CPU_TEMP" -gt "$AVG_TEMP" ]; then
      EFFECTIVE_TEMP="$CPU_TEMP"
    else
      EFFECTIVE_TEMP="$AVG_TEMP"
    fi
    
    if [ "$EFFECTIVE_TEMP" -lt "$POINT0" ]; then
      TARGET_PWM=255
    elif [ "$EFFECTIVE_TEMP" -lt "$POINT1" ]; then
      TARGET_PWM=90
    elif [ "$EFFECTIVE_TEMP" -lt "$POINT2" ]; then
      TARGET_PWM=60
    elif [ "$EFFECTIVE_TEMP" -lt "$POINT3" ]; then
      TARGET_PWM=40
    elif [ "$EFFECTIVE_TEMP" -lt "$POINT4" ]; then
      TARGET_PWM=25
    else
      TARGET_PWM=0
    fi

   if [ "$PREV_PWM" -ne -1 ]; then
     if [ "$TARGET_PWM" -ne "$PREV_PWM" ]; then
       case "$PREV_PWM:$TARGET_PWM" in
         255:90)  [ "$EFFECTIVE_TEMP" -lt $((POINT1 - HYST)) ] && TARGET_PWM=255 ;;
         90:255)  [ "$EFFECTIVE_TEMP" -gt $((POINT4 + HYST)) ] && TARGET_PWM=90 ;;
   
         90:60)  [ "$EFFECTIVE_TEMP" -lt $((POINT2 - HYST)) ] && TARGET_PWM=90 ;;
         60:90)  [ "$EFFECTIVE_TEMP" -gt $((POINT1 + HYST)) ] && TARGET_PWM=60 ;;

         60:40)  [ "$EFFECTIVE_TEMP" -lt $((POINT3 - HYST)) ] && TARGET_PWM=60 ;;
         40:60)  [ "$EFFECTIVE_TEMP" -gt $((POINT2 + HYST)) ] && TARGET_PWM=40 ;;

         40:25)  [ "$EFFECTIVE_TEMP" -lt $((POINT4 - HYST)) ] && TARGET_PWM=40 ;;
         25:40)  [ "$EFFECTIVE_TEMP" -gt $((POINT3 + HYST)) ] && TARGET_PWM=25 ;;

         25:0)   [ "$EFFECTIVE_TEMP" -lt $((70000 - HYST)) ] && TARGET_PWM=25 ;;
         0:25)   [ "$EFFECTIVE_TEMP" -gt $((POINT4 + HYST)) ] && TARGET_PWM=0 ;;
       esac
     fi
   fi

   if [ "$TARGET_PWM" -ne "$PREV_PWM" ]; then
      SPEED_CHANGED=1
   else
      SPEED_CHANGED=0
   fi


   PWM="$TARGET_PWM"
   PREV_PWM="$PWM"

   if [ "$SPEED_CHANGED" -eq 1 ]; then
	if [ "$DEBUG" -eq 1 ]; then
            echo "Changing fan speed: $PWM. Temperature: $EFFECTIVE_TEMP"
	fi

	if [ -w "$PWM_FILE" ]; then
	    echo "$PWM" > "$PWM_FILE"
	else
	    echo "PWM file not writable: $PWM_FILE"
	fi

	echo "$PWM" > "$LOG_FILE"
   fi

    sleep 10
  done


