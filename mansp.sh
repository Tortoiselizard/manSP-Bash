#!/bin/bash

#Crear archivo comand.txt con informacion del manual
man $1 | col -b | tr -s ' ' | sed 's/\"/\\\"/g' > /data/data/com.termux/files/home/scripts/mansp/comand.txt
sed -i 's/	/ /g' /data/data/com.termux/files/home/scripts/mansp/comand.txt

#Contar numero de lineas del archivo comand.txt
nlineas=$(wc -l < /data/data/com.termux/files/home/scripts/mansp/comand.txt | awk '{print $1}')

#Declara arreglo para manipular ibformacion
lineasTexto=()
linea=1

while [ $linea -le $nlineas ]
do
  lineasTexto+=("$(head -n $linea /data/data/com.termux/files/home/scripts/mansp/comand.txt | tail -1)")
  linea=$(($linea+1))
done

#Crear archivo JSON para hacer solicitud
echo '{' > /data/data/com.termux/files/home/scripts/mansp/comand.json
echo '  "sourceLanguage": "en",' >> /data/data/com.termux/files/home/scripts/mansp/comand.json
echo '  "text": [' >> /data/data/com.termux/files/home/scripts/mansp/comand.json
for linea in "${lineasTexto[@]}"
do
  if [[ $linea = ${lineasTexto[-1]} ]]; then
echo "    \"$linea\"" >> /data/data/com.termux/files/home/scripts/mansp/comand.json
  else
echo "    \"$linea\"," >> /data/data/com.termux/files/home/scripts/mansp/comand.json
  fi
done 
echo '  ]' >> /data/data/com.termux/files/home/scripts/mansp/comand.json
echo '}' >> /data/data/com.termux/files/home/scripts/mansp/comand.json

#Hacer solicitud
curl -X POST -H "Content-Type: application/json" -d @/data/data/com.termux/files/home/scripts/mansp/comand.json https://mansp-back.onrender.com/linux/man > /data/data/com.termux/files/home/scripts/mansp/comando.txt

#Leer informacion
less /data/data/com.termux/files/home/scripts/mansp/comando.txt

#solicitud GET
#respuesta=$(curl -s https://mansp-back.onrender.com/linux)
#echo $respuesta
