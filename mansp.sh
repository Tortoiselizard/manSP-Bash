#!/bin/bash

#ruta directorio de comandos
pathComands="/data/data/com.termux/files/home/scripts/mansp/comands"

#ruta de archivos de datos
pathScript="/data/data/com.termux/files/home/scripts/mansp"

#Cuando no se pasa argumento
if [ "$1" = "" ]; then
	echo "usege: mansp.sh name ..."
	exit 0
fi

#Buscar en biblioteca
if test -e "$pathComands/$1.txt"; then
	less "$pathComands/$1.txt"
	exit 0
fi

if ! man $1 > "$pathComands/null" 2>&1; then
	echo "el comando $1 no se encuentra en man"
	exit 1
fi

#Crear archivo comand.txt con informacion del manual
man $1 | col -b | tr -s ' ' | sed 's/\"/\\\"/g' > "$pathScript/comand.txt"
sed -i 's/	/    /g' "$pathScript/comand.txt"
sed -i 's/\\/\\\\/g' "$pathScript/comand.txt"

#Contar numero de lineas del archivo comand.txt
nlineas=$(wc -l < "$pathScript/comand.txt" | awk '{print $1}')

#Declara arreglo para manipular ibformacion
lineasTexto=()
linea=1

while [ $linea -le $nlineas ]
do
  lineasTexto+=("$(head -n $linea $pathScript/comand.txt | tail -1)")
  linea=$(($linea+1))
done

#Crear archivo JSON para hacer solicitud
echo '{' > "$pathScript/comand.json"
echo '  "sourceLanguage": "en",' >> "$pathScript/comand.json"
echo '  "text": [' >> "$pathScript/comand.json"
for linea in "${lineasTexto[@]}"
do
  if [[ $linea = ${lineasTexto[-1]} ]]; then
echo "    \"$linea\"" >> "$pathScript/comand.json"
  else
echo "    \"$linea\"," >> "$pathScript/comand.json"
  fi
done 
echo '  ]' >> "$pathScript/comand.json"
echo '}' >> "$pathScript/comand.json"

#Hacer solicitud
curl -X POST -H "Content-Type: application/json" -d @"$pathScript/comand.json" https://mansp-back.onrender.com/linux/man > "$pathComands/$1.txt"

#Leer informacion
less "$pathComands/$1.txt"

#solicitud GET
#respuesta=$(curl -s https://mansp-back.onrender.com/linux)
#echo $respuesta
