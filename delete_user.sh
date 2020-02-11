#! /bin/bash
user=$1
pass=$2
file=$3
host=$4
if [ "$#" -ne 4 ]; then
      echo "usage: sh delete_user.sh Options[username password file hostname]"
      echo "file: should be the fully qualified path with the usernames required to delete separated by newlines."
      echo "hostname: Should be in the <hostname:port> format. if the Identity server is exposed via an LB then no need for the port."
      exit
fi
rm -f request.xml
echo "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ser=\"http://service.ws.um.carbon.wso2.org\"><soapenv:Header/><soapenv:Body><ser:deleteUser><ser:userName>demo</ser:userName></ser:deleteUser></soapenv:Body></soapenv:Envelope" >> request.xml

starttime=`date "+%F-%T"`
echo "$starttime: User deletion started."
echo "$starttime: User deletion started." >> delete_user.log
while IFS= read line
do
	time=`date "+%F-%T"`
        sed=`sed -i "s/\(<ser:userName.*>\)[^<>]*\(<\/ser:userName.*\)/\1$line\2/" request.xml`
        echo "$time: Deleting the user: $line ..."
        echo "$time: Deleting the user: $line ..." >> delete_user.log
	echo "$time: Soap Request: " $(cat request.xml)
	echo "$time: Soap Request: " $(cat request.xml) >> delete_user.log
	rm -f tmp.log
        curl=`curl -ki -H "Content-Type: text/xml;charset=UTF-8"  -H "SOAPAction:urn:deleteUser" --basic -u "$user:$pass" --data @request.xml https://$host/services/RemoteUserStoreManagerService --write-out %{http_code} --silent --output tmp.log`
	echo "$time: User delete message trace for user: $line" >> message_trace.log
	echo "$time: " $(cat tmp.log) >> message_trace.log
	echo "$time: Recived response: $curl"
	echo "$time: Recived response: $curl" >> delete_user.log
	if [ "$curl" -ne 202 ]
	then
		echo "$time: Failed to delete user: $line"
		echo "$time: Failed to delete user: $line" >> delete_user.log
		echo "$time: User Failed to Delete: $line, Status: $curl" >> failed_user_delete.log
	else
	        echo "$time: The user: $line deleted."
	        echo "$time: The user: $line deleted." >> delete_user.log
		echo "$time: User Deleted: $line, Status: $curl" >> successful_user_delete.log
	fi
	sleep 5
done <"$file"
echo "$time: User deletion completed."
echo "$time: User deletion completed." >> delete_user.log
