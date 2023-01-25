; Create a file in the same directory as this script named "ActiveWindowMQTT.credentials.ahk" which contains these lines (customized with your MQTT broker host and credentials):
; MQTTBrokerHostname = 192.168.1.1
; MQTTBrokerUsername = mqtt
; MQTTBrokerPassword = your_password
#Include %A_ScriptDir%\ActiveWindowMQTT.credentials.ahk

MQTTPrefix = ActiveWindowMQTT
MosquittoPubExe := "C:\Program Files\mosquitto\mosquitto_pub.exe"

;MsgBox, Host: %MQTTBrokerHostname%`nUser: %MQTTBrokerUsername%`nPass: %MQTTBrokerPassword%

Menu, Tray, Icon, %SystemRoot%\system32\SHELL32.dll, 22
Menu, Tray, Tip, Active Window MQTT

; Get the Domain/Workgroup and Computer Name
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" A_ComputerName "\root\cimv2")
For objComputer in objWMIService.ExecQuery("Select * from Win32_ComputerSystem") {
   Name := objComputer.Name, Domain := objComputer.Domain, Workgroup := objComputer.Workgroup
}
If (Workgroup)
    NetworkOrg := Workgroup
If (Domain)
    NetworkOrg := Domain


; Generate HA MQTT Discovery Config
MQTTDiscoveryConfigJsonFile := A_ScriptDir "\ActiveWindowMQTT." NetworkOrg "." Name ".discovery.json"
RunWait, %comspec% /c echo|set /p "" > "%MQTTDiscoveryConfigJsonFile%",, Hide
Sleep 2000 ; Wait for the file truncation above to complete
NetworkOrgCleaned := RegExReplace(NetworkOrg, "\." , "_")
FileAppend,
(
{
  "state_topic": "%MQTTPrefix%/%NetworkOrg%/%Name%/activewindow",
  "name": "%NetworkOrg%/%Name% Active Window",
  "unique_id": "%NetworkOrgCleaned%_%Name%_activewindow",
  "payload_available": "ON",
  "payload_not_available": "OFF",
  "device": {
    "identifiers": [
      "%NetworkOrgCleaned%_%Name%_ActiveWindow"
    ],
    "name": "%NetworkOrg%/%Name% Active Window",
    "model": "ActiveWindowMQTT",
    "manufacturer": "Muchtall"
  }
}
), %MQTTDiscoveryConfigJsonFile%

; Publich HA MQTT Discovery Config
RunWait, "%MosquittoPubExe%" -h "%MQTTBrokerHostname%" -u "%MQTTBrokerUsername%" -P "%MQTTBrokerPassword%" -t "homeassistant/sensor/%MQTTPrefix%/%NetworkOrgCleaned%_%Name%_activewindow/config" -r -f "%MQTTDiscoveryConfigJsonFile%",,Hide

; Watch for changes to window titles
Loop {
	WinGetActiveTitle, MyWinTitle
	ActiveWindow := MyWinTitle
	vSize := StrPut(MyWinTitle, "UTF-8")
	VarSetCapacity(vUtf8, vSize)
	vSize := StrPut(MyWinTitle, &vUtf8, vSize, "UTF-8")
	MyWinTitleUTF8 := % StrGet(&vUtf8, "CP0")
	RunWait, "%MosquittoPubExe%" -h "%MQTTBrokerHostname%" -u "%MQTTBrokerUsername%" -P "%MQTTBrokerPassword%" -t "%MQTTPrefix%/%NetworkOrg%/%Name%/activewindow" -m "%MyWinTitleUTF8%",,Hide
        While MyWinTitle == ActiveWindow
	{
		WinGetActiveTitle, MyWinTitle
		Sleep 100
	}
}

