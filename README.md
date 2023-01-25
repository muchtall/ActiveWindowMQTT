# ActiveWindowMQTT
AutoHotKey script that reports the active window to a HomeAssistant MQTT Broker as a sensor.

## Prerequisites
- AutoHotKey (https://www.autohotkey.com/)
- Installation of Mosquitto (specifically mosquitto_pub) (https://mosquitto.org/download/)
## Usage
- Create an ank file named `ActiveWindowMQTT.credentials.ahk` in the same directory as ActiveWindowMQTT.ahk
- Add these lines to the file (with your credentials an host) and save:
```
MQTTBrokerHostname = 192.168.1.1
MQTTBrokerUsername = mqtt
MQTTBrokerPassword = your_password
```
- Run `ActiveWindowMQTT.ahk`
- You should now see an MQTT sensor with a name following this format: `Domain.fqdn/COMPUTERNAME Active Window` (unique ID: `sensor.domain_fqdn_computername_active_window`)
