#!/bin/bash
input="/home/pi/lista_macs.txt"

sleep 5

while IFS= read -r line
do
	sudo /usr/bin/ndsctl trust $line
done < "$input"
