# Fan controlling daemon (service) for Banana Pi R3 (OpenWRT)
This OpenWRT script fixes well-known overheating issue due to incorrect fan controlling.

# Installation

- copy `fancontrol` into `/etc/init.d/`
- copy `fancontrol_daemon.sh` in `/usr/bin/`

do not forget to make them executible
- `chmod +x /etc/init.d/fancontrol`
- `chmod +x /usr/bin/fancontrol_daemon.sh`

setup service
- `/etc/init.d/fancontrol enable`
and then
- `/etc/init.d/fancontrol start`

# Description
*Everything described below could be modified in shell-script `fancontrol_daemon.sh`*

This daemon:
- Considers CPU thermal sensor and 2 Wireless sensors, and takes into consideration MAX(cpu_temp, AVG(wireless1_temp, wireless2_temp)) as EFFECTIVE temperature
- Uses hysteresis (2 degrees)
- Has 5 temperature points (to control fan speed by effective temperature value)
- Has NIGHT MODE. My fan is quite noisy, so I make it more silent. during night time (21.00 to 08.00) it uses "night points" instead

# Logs
Use `logread -e fancontrol` to check logs

# Important notes
Fan controlled via sending an 8bit integer value to `/sys/devices/platform/pwm-fan/hwmon/hwmon1/pwm1`
For some reason it works this way:
- 255 - means FAN if OFF (actually it still not working until 90)
- 40-60 - avarage speed
- 0 - FAN is ON MAXIMUM SPEED.
