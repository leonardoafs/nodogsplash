#!/bin/bash
input="/home/pi/lista_macs.txt"

IFS=$'\n'
for i in `sudo cat /var/log/syslog | grep hostapd | grep associated`
do
	mes=`cut -d' ' -f1 <<< "$i" ` 
	dia=`cut -d' ' -f3 <<< "$i" ` 
	hora=`cut -d' ' -f4 <<< "$i" ` 
	mac=`cut -d' ' -f9 <<< "$i" ` 
	horario="${mes} ${dia} ${hora}"
	estado=${i: -13}
	if [ $estado == "disassociated" ]
	then
		echo "{
				\"Mac\": \"$mac\",
				\"Datetime\": \"$horario\",
				\"tipoAcesso\": \"saida\"
			},	
		" >> /home/pi/entrada_e_saida.json 
	else
		echo "{
				\"Mac\": \"$mac\",
				\"Datetime\": \"$horario\",
				\"tipoAcesso\": \"entrada\"
			},	
		" >> /home/pi/entrada_e_saida.json 
	fi
done
`sudo truncate -s 0 /var/log/syslog`
