#!/bin/bash

#Crear archivo comand.txt con informacion del manual
man $1 | col -b | tr -s ' ' | sed 's/\"/\\\"/g' > comand.txt
sed -i 's/	/ /g' comand.txt

#Contar numero de lineas del archivo comand.txt
nlineas=$(wc -l < comand.txt | awk '{print $1}')

#Declara arreglo para manipular ibformacion
lineasTexto=()
linea=1

while [ $linea -le $nlineas ]
do
  lineasTexto+=("$(head -n $linea comand.txt | tail -1)")
  linea=$(($linea+1))
done

#Crear archivo JSON para hacer solicitud
echo '{' > comand.json
echo '  "sourceLanguage": "en",' >> comand.json
echo '  "text": [' >> comand.json
for linea in "${lineasTexto[@]}"
do
  if [[ $linea = ${lineasTexto[-1]} ]]; then
echo "    \"$linea\"" >> comand.json
  else
echo "    \"$linea\"," >> comand.json
  fi
done 
echo '  ]' >> comand.json
echo '}' >> comand.json

#Hacer solicitud
curl -X POST -H "Content-Type: application/json" -d @comand.json https://mansp-back.onrender.com/linux/man > comando.txt

#Leer informacion
less comando.txt

#solicitud GET
#respuesta=$(curl -s https://mansp-back.onrender.com/linux)
#echo $respuesta
