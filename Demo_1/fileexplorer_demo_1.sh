#!/bin/bash


clear
clear
echo "------------------------------------------------------------------"
echo
echo -e "\e[1m FILE  EXPLORER  -  DEMO 1"
echo
echo -e "\e[0mA simple script by \e[1m\e[7mMelwyn  F. Carlo"
echo -e "\e[0m"
echo -e "\e[5m`date`"
echo -e "\e[0m------------------------------------------------------------------"
echo
echo
echo

echo -n "Opening up the dialog box . . . "
gnome-terminal --title="MFC Linux File Explorer" -- bash -c \
	'source src/mfc_linux_fileexplorer.sh 24 80 37 150; mfc_fileexplore "" "0" "0" "0" "0" "0" "1" "1" "load" "0"'

while :
do
	line=`head "src/bin/mfc_fileexplorer_processdone.txt"`
	if [[ "$line" == *"1"* ]]; then
		break
	fi
done

echo "Done !"

echo
echo

filedir=""
filename=()
filepath=()
outputsource=("src/bin/mfc_fileexplorer_dirpath.txt")
outputsource+=("src/bin/mfc_fileexplorer_filename.txt")
outputsource+=("src/bin/mfc_fileexplorer_filepath.txt")

for ((i = 0 ; i < 3 ; i++))
do
	while read -rs line
	do
		if [ $i -eq 0 ]; then
			filedir="$line"
		elif [ $i -eq 1 ]; then
			filename+=("$line")
		elif [ $i -eq 2 ]; then
			filepath+=("$line")
		fi
	done < "${outputsource[$i]}"
done

echo " Output :"
echo "------------------------------------------------------------------"
echo
echo
echo " 1.  Directory Path  :  $filedir"
echo
echo " 2.  Filenames       :  ${filename[0]}"
for ((j = 1 ; j < ${#filename[@]} ; j++))
do
	echo "                        ${filename[$j]}"
done
echo
echo " 3.  File Paths      :  ${filepath[0]}"
for ((k = 1 ; k < ${#filepath[@]} ; k++))
do
	echo "                        ${filepath[$k]}"
done 

echo
echo
echo
echo "------------------------------------------------------------------"
echo
echo -e "\e[1m THIS  PROGRAM  HAS  ENDED !\e[0m"
echo
echo -e "\e[0m------------------------------------------------------------------"
echo
echo
echo



