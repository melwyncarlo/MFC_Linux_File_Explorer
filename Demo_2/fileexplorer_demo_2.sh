#!/bin/bash



exitstatus=""

clear
clear
echo "-----------------------------------------------------------------------------------------------------"
echo
echo -e "\e[1m FILE  EXPLORER  -  DEMO 2\e[0m"
echo
echo -e "A simple script by \e[1m\e[7mMelwyn  F. Carlo\e[0m"
echo
echo "-----------------------------------------------------------------------------------------------------"
echo
echo
echo

echo -n "Opening up the dialog box . . . "
gnome-terminal --title="MFC Linux File Explorer" -- bash -c \
	'source src/mfc_linux_fileexplorer.sh 24 80 37 150; mfc_fileexplore "/home/mfcarlo/Documents" "1" "1" "1" "0" "1" "3" "0" "" "0"'

while :
do
	line=`head "src/bin/mfc_fileexplorer_processdone.txt"`
	if [[ "$line" == "1" ]]; then
		exitstatus=1
		break
	elif [[ "$line" == "-1" ]]; then
		exitstatus=-1
		break
	fi
done

echo "Done !"

echo
echo

if [ $exitstatus -eq 1 ]; then

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
	echo "-----------------------------------------------------------------------------------------------------"
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
else
	echo -e "\e[1mERROR :\e[0m  The File Explorer Dialog has ended"
	echo "         without any selection."
fi

echo
echo
echo
echo "-----------------------------------------------------------------------------------------------------"
echo
echo -e "\e[1m THIS  PROGRAM  HAS  ENDED !\e[0m"
echo
echo "-----------------------------------------------------------------------------------------------------"
echo
echo
echo



