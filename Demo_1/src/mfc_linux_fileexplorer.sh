#!/bin/bash



echo "0" > "src/bin/mfc_fileexplorer_processdone.txt"


readonly MFC_SIMPLE_MODE_MIN_W=80
readonly MFC_SIMPLE_MODE_MIN_H=24
readonly MFC_COMPLETE_MODE_MIN_W=150
readonly MFC_COMPLETE_MODE_MIN_H=37
readonly MFC_DISPLAY_FILENAME_LENGTH=25
readonly MFC_DISPLAY_FILETYPE_LENGTH=26
readonly MFC_DISPLAY_FILESIZE_LENGTH=6
readonly MFC_DISPLAY_FILETIME_LENGTH=11
readonly MFC_HEADING_LENGTH=$(($MFC_SIMPLE_MODE_MIN_W-5))


readonly FILE_TYPE_DIRECTORY="----|  DIRECTORY  |----"
readonly SWITCH_FROM_MULTI_SEL="*** SWTICH FROM MULTI-SEL MODE ***"


declare -ir MFC_SIMPLE_MODE_H=$1
declare -ir MFC_SIMPLE_MODE_W=$2
declare -ir MFC_COMPLETE_MODE_H=$3
declare -ir MFC_COMPLETE_MODE_W=$4


source src/headerdesign.sh


mfc_fileexplorer_filename=()
mfc_fileexplorer_filepath=()
mfc_fileexplorer_dirpath=""
mfc_fileexplorer_exit=0



# Parameter 1 - Data
# Parameter 2 - Mode ( 1 => Alpha; 2 => Num; 3 => AlphaNum; ?* => Specific Characters)
# Parameter 3 - Return Data	[ REFERENCE ]
mfc_remove()
{
	local tmpNum=0

	local mainStr=$1
	local mode=$2
	local -n returnStr=$3
	returnStr=""
	
	for ((i = 0 ; i < ${#mainStr} ; i++))
	do
		if [[ "$mode" == "1" ]] && ! [[ "${mainStr:$i:1}" =~ ^[a-zA-Z]+$ ]]; then
			returnStr+="${mainStr:$i:1}"
		elif [[ "$mode" == "2" ]] && ! [[ "${mainStr:$i:1}" =~ ^[0-9]+$ ]]; then
			returnStr+="${mainStr:$i:1}"
		elif [[ "$mode" == "3" ]] && ! [[ "${mainStr:$i:1}" =~ ^[0-9a-zA-Z]+$ ]]; then
			returnStr+="${mainStr:$i:1}"
		else
			let "tmpNum = ${#mode} - 1"
			if [[ "${mode:0:1}" == "?" ]] && [[ "${mainStr:$i:$tmpNum}" == "${mode:1:$tmpNum}" ]]; then
				let "i = i + tmpNum - 1"
			else
				if [[ "$mode" != "1" ]] && [[ "$mode" != "2" ]] && [[ "$mode" != "3" ]]; then
					returnStr+="${mainStr:$i:1}"
				fi
			fi
		fi
	done
}


# Parameter 1 - Number of Spaces
# Parameter 2 - Return String	[ REFERENCE ]
private_func_spaces()
{
	local spacesnum=$1
	local -n returnStr="$2"
	returnStr=""

	for ((i = 1 ; i <= $spacesnum ; i++))
	do
		returnStr+=" "
	done
}


# Parameter 1 - String Data	[ REFERENCE ]
# Parameter 2 - File Path
private_func_cleanfilepropdata()
{
	local tmpStr0=""

	local -n dataStr="$1"
	local filepath="$2"

	mfc_remove "$dataStr" "?$filepath" tmpStr0
	tmpStr0=$(echo -e $tmpStr0 | tr -d '\t')
	tmpStr0=$(echo -e $tmpStr0 | tr -d '\n')
	tmpStr0=$(echo -e $tmpStr0 | tr -d ' ')
	tmpStr0=$(echo -e $tmpStr0 | tr -d ':')
	dataStr="$tmpStr0"
}


# Parameter 1 - File Path
# Parameter 2 - Complete Mode
# Parameter 3 - Return File Size	[ REFERENCE ]
private_func_getfilesize()
{
	local tmpStr1=""
	local tmpStr2=""

	local filepath="$1"
	local compmode="$2"
	local -n returnStr=$3
	returnStr=""

	echo "0" > "src/bin/finderr1.txt"
	if [ $compmode -eq -1 ]; then
		tmpStr1=`du -bs "$filepath" 2> src/bin/finderr1.txt`
	else
		tmpStr1=`du -bsh "$filepath" 2> src/bin/finderr1.txt`
	fi
	tmpStr2=""
	while read -r -s line
	do
		tmpStr2+="$line"
	done < "src/bin/finderr1.txt"
	if [[ "$tmpStr2" != "0" ]] && [[ "$tmpStr2" != "" ]]; then
		if [ $compmode -eq -1 ]; then
			tmpStr1="0"
		else
			tmpStr1=""
		fi
	fi

	private_func_cleanfilepropdata tmpStr1 "$filepath"
	tmpStr2="$tmpStr1"	

	if [ $compmode -ne -1 ]; then
		if [[ "$compmode" == "1" ]]; then
			if [[ "$tmpStr2" == *"T"* ]] || [[ "$tmpStr2" == *"t"* ]]; then
				tmpStr2="${tmpStr2:0:$((${#tmpStr2}-1))} Terabytes"
			elif [[ "$tmpStr2" == *"G"* ]] || [[ "$tmpStr2" == *"g"* ]]; then
				tmpStr2="${tmpStr2:0:$((${#tmpStr2}-1))} Gigabytes"
			elif [[ "$tmpStr2" == *"M"* ]] || [[ "$tmpStr2" == *"m"* ]]; then
				tmpStr2="${tmpStr2:0:$((${#tmpStr2}-1))} Megabytes"
			elif [[ "$tmpStr2" == *"K"* ]] || [[ "$tmpStr2" == *"k"* ]]; then
				tmpStr2="${tmpStr2:0:$((${#tmpStr2}-1))} Kilobytes"
			else
				tmpStr2="$tmpStr2 Bytes"
			fi
		else
			tmpStr1="$tmpStr2"
			mfc_remove "$tmpStr1" "2" tmpStr2
			if [ ${#tmpStr2} -eq 0 ]; then
				tmpStr1="$tmpStr1""B"
			fi
			tmpStr2="$tmpStr1"
		fi
	fi

	returnStr="$tmpStr2"
}


# Parameter 1 - File Path
# Parameter 2 - Date Format
# Parameter 3 - Return String	[ REFERENCE ]
private_func_filedatecmd()
{
	local tmpStr0=""

	local filepath="$1"
	local dateform="$2"
	local -n returnStr=$3
	returnStr=""

	echo "0" > "src/bin/finderr1.txt"
	returnStr=`date +"$dateform" -r "$filepath" 2> src/bin/finderr1.txt`
	tmpStr0=""
	while read -r -s line
	do
		tmpStr0+="$line"
	done < "src/bin/finderr1.txt"
	if [[ "$tmpStr0" != "0" ]] && [[ "$tmpStr0" != "" ]]; then
		returnStr=""
	fi
}


# Parameter 1 - File Path
# Parameter 2 - Complete Mode
# Parameter 3 - Return File Time	[ REFERENCE ]
private_func_getfiletime()
{
	local tmpStr1=""
	local tmpStr2=""
	local tmpStr3=""

	local filepath="$1"
	local compmode="$2"
	local -n returnStr=$3
	returnStr=""

	if [[ "$compmode" == "1" ]]; then
		private_func_filedatecmd "$filepath" "%A, %d %B, %Y, at %T" tmpStr3
	else
		private_func_filedatecmd "$filepath" "%a" tmpStr1
		if [[ "${tmpStr1:0:2}" == "Sa" ]]; then
			tmpStr1="Sa"
		elif [[ "${tmpStr1:0:2}" == "Su" ]]; then
			tmpStr1="Su"
		elif [[ "${tmpStr1:0:2}" == "Tu" ]]; then
			tmpStr1="Tu"
		elif [[ "${tmpStr1:0:2}" == "Th" ]]; then
			tmpStr1="Th"
		else
			tmpStr1="${tmpStr1:0:2}"
		fi
		tmpStr2=`date +"%d%m%y"`
		private_func_filedatecmd "$filepath" "%d%m%y" tmpStr3
		if [[ "$tmpStr2" == "$tmpStr3" ]]; then
			tmpStr1=""
			private_func_filedatecmd "$filepath" "%R" tmpStr2
		else
			private_func_filedatecmd "$filepath" "/%d/%m/%y" tmpStr2
		fi
		tmpStr3="$tmpStr1$tmpStr2"
	fi

	returnStr="$tmpStr3"
}


# Parameter 1 - Complete Mode Options Mode
# Parameter 2 - Opposite Mode Name
# Parameter 3 - Show Hidden Files Opposite Mode Name
# Parameter 4 - Show Hidden Files Options Mode
# Parameter 5 - Show Only ... Options Mode
# Parameter 6 - Return Display Options Array	[ REFERENCE ]
# Parameter 7 - Return Real Options Array	[ REFERENCE ]
private_func_recreate_optmenu()
{
	local tmpArr=()
	local count=2

	local completemodeopt="$1"
	local oppmodename="$2"
	local oppshowhide="$3"
	local hiddenfilesopt="$4"
	local showonlyopt="$5"
	local -n returnArr1=$6
	local -n returnArr2=$7
	returnArr2=("" "1")

	tmpArr=("" "   ▮▮▮▮▮▮  SORT MENU  ▮▮▮▮▮▮▮▮▮▮▮▮▮▮")
	tmpArr+=(" " "   ▯▯▯▯▯▯   GO BACK   ▯▯▯▯▯▯▯▯▯▯▯▯▯▯")
	tmpArr+=("[1]" "   Sort")
	if [ $showonlyopt -eq 1 ]; then
		tmpArr+=("[$count]" "   Show only ...")
		returnArr2+=("2")
		let "count++"
	fi
	if [ $hiddenfilesopt -eq 1 ]; then
		tmpArr+=("[$count]" "   $oppshowhide hidden files")
		returnArr2+=("3")
		let "count++"
	fi
	if [ $completemodeopt -eq 1 ]; then
		tmpArr+=("[$count]" "   Switch to $oppmodename Mode")
		returnArr2+=("4")
	fi

	returnArr1=("${tmpArr[@]}")

	unset tmpArr
}


# Parameter 1 - Return Show Only Array	[ REFERENCE ]
private_func_recreate_showonlymenu()
{
	local tmpArr=()

	local -n returnArr=$1

	tmpArr=("" "   ▮▮▮▮▮▮  SHOW ONLY ... MENU  ▮▮▮▮▮▮▮▮▮▮▮▮▮▮")
	tmpArr+=(" " "   ▯▯▯▯▯▯   GO BACK   ▯▯▯▯▯▯▯▯▯▯▯▯▯▯")
	tmpArr+=("[1]" "   Show only Files")
	tmpArr+=("[2]" "   Show only Folders")
	tmpArr+=("[3]" "   Show Both")

	returnArr=("${tmpArr[@]}")

	unset tmpArr
}


# Parameter 1 - Opposite Mode Name
# Parameter 2 - Return Sort Array	[ REFERENCE ]
private_func_recreate_sortmenu()
{
	local tmpArr=()

	local oppmodename="$1"
	local -n returnArr=$2

	tmpArr=("" "   ▮▮▮▮▮▮  SORT MENU  ▮▮▮▮▮▮▮▮▮▮▮▮▮▮")
	tmpArr+=(" " "   ▯▯▯▯▯▯   GO BACK   ▯▯▯▯▯▯▯▯▯▯▯▯▯▯")
	tmpArr+=("[1]" "   Sort as Folders and Files")
	tmpArr+=("[2]" "   Sort Alphabetically (Ascending)")
	tmpArr+=("[3]" "   Sort Alphabetically (Descending)")

	if [[ "$oppmodename" == "Simple" ]]; then	# COMPLETE MODE
		tmpArr+=("[4]" "   Sort by File Type (Ascending)")
		tmpArr+=("[5]" "   Sort by File Type (Descending)")
		tmpArr+=("[6]" "   Sort by File Size (Ascending)")
		tmpArr+=("[7]" "   Sort by File Size (Descending)")
		tmpArr+=("[8]" "   Sort by File Time (Ascending)")
		tmpArr+=("[9]" "   Sort by File Time (Descending)")
	fi

	returnArr=("${tmpArr[@]}")

	unset tmpArr
}


# Parameter 1 - Text	[ REFERENCE ]
# Parameter 2 - Maximum Length of Characters
# Parameter 3 - Number of Required Start Characters
# Parameter 4 - Number of Required End Characters
private_func_shortentext()
{
	local -n returnStr="$1"
	local maxLen=$2
	local startchnum=$3
	local endchnum=$4

	if [ ${#returnStr} -gt $maxLen ]; then
		returnStr="${returnStr:0:$startchnum}...${returnStr:$((${#returnStr}-$endchnum)):$endchnum}"
	fi
}


# Parameter 1 - Return Array	[ REFERENCE ]
# Parameter 2 - Mode ( 1 => Ascending; 2 => Descending )
# Parameter N - String Array Input
private_func_sortalpha()
{
	local tmpElem=""

	local -n returnArr=$1
	returnArr=()
	local mode="$2"
	shift 2
	local inputArr=("${@}")

	if [ ${#inputArr[@]} -gt 0 ]; then
		echo -n "" > "src/bin/tempfile.txt"
		for tmpElem in "${inputArr[@]}"
		do
			echo "$tmpElem" >> "src/bin/tempfile.txt"
		done
		if [[ "$mode" == "2" ]]; then
			returnArr=(`sort -r "src/bin/tempfile.txt"`)
		else
			returnArr=(`sort "src/bin/tempfile.txt"`)
		fi
	fi
}


# Parameter 1 - Return Array	[ REFERENCE ]
# Parameter 2 - Directory (Along with the '/' at the end)
# Parameter N - String Array Input
private_func_sortfiledir()
{
	local tmpArr1a=()	# Folders Container
	local tmpArr1b=()
	local tmpArr2a=()	# Files Container
	local tmpArr2b=()

	local -n returnArr=$1
	returnArr=()
	local dirnme="$2"
	shift 2
	local inputArr=("${@}")

	if [ ${#inputArr[@]} -gt 0 ]; then

		for tmpElem in "${inputArr[@]}"
		do
			if [ -d "$dirnme$tmpElem" ]; then
				tmpArr1a+=("$tmpElem")
			else
				tmpArr2a+=("$tmpElem")
			fi
		done

		private_func_sortalpha tmpArr1b "1" "${tmpArr1a[@]}"
		private_func_sortalpha tmpArr2b "1" "${tmpArr2a[@]}"

		returnArr=("${tmpArr1b[@]}")
		returnArr+=("${tmpArr2b[@]}")
	fi
}


# Parameter 1 - Return Array	[ REFERENCE ]
# Parameter 2 - Mode ( 1 => Ascending; 2 => Descending )
# Parameter 3 - Directory (Along with the '/' at the end)
# Parameter N - String Array Input
private_func_sortfiletype()
{
	local tmpArr=()
	local tmpElem=""
	local tmpStr1=""
	local tmpStr2=""

	local -n returnArr=$1
	returnArr=()
	local mode="$2"
	local dirnme="$3"
	shift 3
	local inputArr=("${@}")

	if [ ${#inputArr[@]} -gt 0 ]; then
		echo -n "" > "src/bin/tempfile.txt"
		for tmpElem in "${!inputArr[@]}"
		do
			tmpStr1=`file "$dirnme${inputArr[$tmpElem]}" --mime-type`
			private_func_cleanfilepropdata tmpStr1 "$dirnme${inputArr[$tmpElem]}"
			printf -v tmpStr2 "%05d" $tmpElem
			if [[ "$tmpStr1" == *"directory"* ]]; then
				tmpStr1="Directory$tmpStr2"
			fi
			echo "$tmpStr1$tmpStr2" >> "src/bin/tempfile.txt"
		done
		if [[ "$mode" == "2" ]]; then
			tmpArr=(`sort -r "src/bin/tempfile.txt"`)
		else
			tmpArr=(`sort "src/bin/tempfile.txt"`)
		fi
		for tmpElem in "${tmpArr[@]}"
		do
			tmpStr1="${tmpElem:$((${#tmpElem[@]}-5)):5}"
			tmpStr1=$((10#$tmpStr1))
			returnArr+=("${inputArr[$tmpStr1]}")
		done
	fi
}


# Parameter 1 - Return Array	[ REFERENCE ]
# Parameter 2 - Mode ( 1 => Ascending; 2 => Descending )
# Parameter 3 - Directory (Along with the '/' at the end)
# Parameter 4 - String Array Input
private_func_sortfilesize()
{
	local tmpElem=""
	local tmpStr01=""
	local tmpStr02=""

	local -n returnArr=$1
	returnArr=()
	local mode="$2"
	local dirnme="$3"
	shift 3
	local inputArr=("${@}")

	if [ ${#inputArr[@]} -gt 0 ]; then
		private_func_sortfiledir tmpArr "$dirnme" "${inputArr[@]}"
		inputArr=("${tmpArr[@]}")
		echo -n "" > "src/bin/tempfile.txt"
		for tmpElem in "${!inputArr[@]}"
		do
			if [ -d "$dirnme${inputArr[tmpElem]}" ]; then
				tmpStr01="1000000000000"
			else
				private_func_getfilesize "$dirnme${inputArr[$tmpElem]}" "-1" tmpStr01
			fi
			printf -v tmpStr02 "%05d" $tmpElem
			echo "$tmpStr01-$tmpStr02" >> "src/bin/tempfile.txt"
		done
		if [[ "$mode" == "2" ]]; then
			tmpArr=(`sort -nr "src/bin/tempfile.txt"`)
		else
			tmpArr=(`sort -n "src/bin/tempfile.txt"`)
		fi
		for tmpElem in "${tmpArr[@]}"
		do
			tmpStr01="${tmpElem:$((${#tmpElem[@]}-5)):5}"
			tmpStr01=$((10#$tmpStr01))
			returnArr+=("${inputArr[$tmpStr01]}")
		done
	fi
}


# Parameter 1 - Return Array	[ REFERENCE ]
# Parameter 2 - Mode ( 1 => Ascending; 2 => Descending )
# Parameter 3 - Directory (Along with the '/' at the end)
# Parameter 4 - String Array Input
private_func_sortfiletime()
{
	local tmpElem=""
	local tmpArr=()

	local -n returnArr=$1
	returnArr=()
	local mode="$2"
	local dirnme="$3"
	shift 3
	local inputArr=("${@}")

	if [ ${#inputArr[@]} -gt 0 ]; then
		private_func_sortfiledir tmpArr "$dirnme" "${inputArr[@]}"
		inputArr=("${tmpArr[@]}")
		echo -n "" > "src/bin/tempfile.txt"
		for tmpElem in "${!inputArr[@]}"
		do
			if [ -d "$dirnme${inputArr[tmpElem]}" ]; then
				tmpStr1="0"
			else
				private_func_filedatecmd "$dirnme${inputArr[tmpElem]}" "%s" tmpStr1
				if [[ "$tmpStr1" == "" ]]; then
					tmpStr1="0"
				fi
			fi
			printf -v tmpStr2 "%05d" $tmpElem
			echo "$tmpStr1-$tmpStr2" >> "src/bin/tempfile.txt"
		done
		if [[ "$mode" == "2" ]]; then
			tmpArr=(`sort -nr "src/bin/tempfile.txt"`)
		else
			tmpArr=(`sort -n "src/bin/tempfile.txt"`)
		fi
		for tmpElem in "${tmpArr[@]}"
		do
			tmpStr1="${tmpElem:$((${#tmpElem[@]}-5)):5}"
			tmpStr1=$((10#$tmpStr1))
			returnArr+=("${inputArr[$tmpStr1]}")
		done
	fi
}


# Parameter 1 - Current Directory
# Parameter 2 - Opposite Mode Name
# Parameter 3 - Show Hidden Files Mode
# Parameter 4 - Show Only ... Mode
# Parameter 5 - Allow Multiple Selection Mode
# Parameter 6 - Multiple Selection Mode
# Parameter 7 - Sorting Type (Option)
# Parameter 8 - Return Filename Array	[ REFERENCE ]
# Parameter 9 - Return Menu Array	[ REFERENCE ]
private_func_recreate_filemenu()
{
	local tmpArr=()
	local tmpArr1=()	# File Name
	local tmpArr2=()	# File Type
	local tmpArr3=()	# File Size
	local tmpArr4=()	# File Time
	local tmpElem=""
	local tmpStr1=""
	local tmpStr2=""
	local tmpStr3=""
	local spacesStr=""

	local curdir="$1"
	local oppmodename="$2"
	local oppshowhide="$3"
	local showonlymode="$4"
	local allowmultisel="$5"
	local multiselmode="$6"
	local sortoptnum="$7"
	local -n returnArr1=$8
	local -n returnArr2=$9

	# Dealing with File Names
	if [[ "$oppshowhide" == "1" ]]; then
		tmpArr=($(ls -A $curdir))	# SHOW HIDDEN FILES
	else
		tmpArr=($(ls $curdir))	# DON'T SHOW HIDDEN FILES
	fi

	# Dealing with Show Only ... Mode
	for tmpElem in "${!tmpArr[@]}"
	do
		if [ $showonlymode -eq 1 ] && [ -d "$curdir/${tmpArr[$tmpElem]}" ]; then		# Show only FILES
			unset tmpArr[$tmpElem]
		elif [ $showonlymode -eq 2 ] && [ ! -d "$curdir/${tmpArr[$tmpElem]}" ]; then		# Show only FOLDERS
			unset tmpArr[$tmpElem]
		fi
	done

	# Sorting Files/Folders
	if [[ "$curdir" == "/" ]]; then
		tmpStr1="$curdir"
	else
		tmpStr1="$curdir/"
	fi
	if [ $sortoptnum -eq 1 ]; then
		private_func_sortfiledir returnArr1 "$tmpStr1" "${tmpArr[@]}"
	elif [ $sortoptnum -eq 3 ]; then
		private_func_sortalpha returnArr1 "2" "${tmpArr[@]}"
	elif [ $sortoptnum -eq 4 ]; then
		private_func_sortfiletype returnArr1 "1" "$tmpStr1" "${tmpArr[@]}"
	elif [ $sortoptnum -eq 5 ]; then
		private_func_sortfiletype returnArr1 "2" "$tmpStr1" "${tmpArr[@]}"
	elif [ $sortoptnum -eq 6 ]; then
		private_func_sortfilesize returnArr1 "1" "$tmpStr1" "${tmpArr[@]}"
	elif [ $sortoptnum -eq 7 ]; then
		private_func_sortfilesize returnArr1 "2" "$tmpStr1" "${tmpArr[@]}"
	elif [ $sortoptnum -eq 8 ]; then
		private_func_sortfiletime returnArr1 "1" "$tmpStr1" "${tmpArr[@]}"
	elif [ $sortoptnum -eq 9 ]; then
		private_func_sortfiletime returnArr1 "2" "$tmpStr1" "${tmpArr[@]}"
	else # if [ $sortoptnum -eq 2 ]; then
		private_func_sortalpha returnArr1 "1" "${tmpArr[@]}"
	fi
	tmpArr=()

	for tmpElem in "${returnArr1[@]}"
	do
		# Dealing with File Names
		tmpStr1="$tmpElem"
		let "tmpStr2 = ($MFC_DISPLAY_FILENAME_LENGTH - 3 ) / 2"
		private_func_shortentext tmpStr1 "$MFC_DISPLAY_FILENAME_LENGTH" "$tmpStr2" "$tmpStr2"
		tmpArr1+=(" $tmpStr1")

		# Dealing with File Types
		tmpStr1=`file "$curdir/$tmpElem" --mime-type`
		if [[ "$tmpStr1" == *"directory"* ]]; then
			tmpStr2="$FILE_TYPE_DIRECTORY"
		else
			mfc_remove "$tmpStr1" "?$curdir/$tmpElem" tmpStr2
			tmpStr1="$tmpStr2"
			mfc_remove "$tmpStr1" "?: " tmpStr2
		fi
		if [ ${#tmpStr2} -gt 22 ]; then
			tmpStr2="${tmpStr2:0:19}..."
		fi
		tmpArr2+=("$tmpStr2")
	done

	if [[ "$oppmodename" == "Simple" ]]; then	# COMPLETE MODE
		for tmpElem in "${returnArr1[@]}"
		do
			tmpStr1=`file "$curdir/$tmpElem" --mime-type`
			if [[ "$tmpStr1" == *"directory"* ]]; then
				# Dealing with File Sizes
				tmpArr3+=("")

				# Dealing with File Times
				tmpArr4+=("")
			else
				# Dealing with File Sizes
				private_func_getfilesize "$curdir/$tmpElem" "0" tmpStr4
				tmpArr3+=("$tmpStr4")

				# Dealing with File Times
				private_func_getfiletime "$curdir/$tmpElem" "0" tmpStr4
				tmpArr4+=("$tmpStr4")
			fi
		done

		if [ $multiselmode -eq 0 ]; then
			tmpArr=("▮▮▮▮▮▮▮▮▮  FILE NAME  ▮▮▮▮▮▮▮▮▮" "▮▮▮▮▮▮▮▮▮  FILE TYPE  ▮▮▮▮▮▮▮▮▮  FILE SIZE  ▮▮▮▮▮▮  FILE TIME  ▮▮▮▮▮▮")
		fi
	else	# SIMPLE MODE
		if [ $multiselmode -eq 0 ]; then
			tmpArr=("▮▮▮▮▮▮▮▮▮  FILE NAME  ▮▮▮▮▮▮▮▮▮" "   ▮▮▮▮▮▮▮▮▮  FILE TYPE  ▮▮▮▮▮▮▮▮▮")
		fi
	fi

	if [ $multiselmode -eq 0 ]; then
		if [[ "$curdir" != "/" ]] && [ $showonlymode -ne 1 ]; then
			tmpArr+=("▯▯▯▯▯▯▯▯▯▯  GO BACK  ▯▯▯▯▯▯▯▯▯▯" "")
		fi
		tmpArr+=("▯▯▯▯▯▯▯▯▯▯▯ OPTIONS ▯▯▯▯▯▯▯▯▯▯▯" "")
		if [ $allowmultisel -eq 1 ]; then	
			tmpArr+=("▯▯ SWTICH TO MULTI-SEL MODE ▯▯▯" "")
		fi
		if [ $showonlymode -ne 1 ]; then	
			tmpArr+=("***  CHOOSE DIRECTORY ITSELF  ***" "")
		fi
	else
		tmpArr+=("$SWITCH_FROM_MULTI_SEL" "" "OFF")
	fi


	for tmpElem in "${!tmpArr1[@]}"
	do
		tmpStr1=""
		tmpArr+=("${tmpArr1[tmpElem]}")
		tmpStr2="${tmpArr2[tmpElem]}"
		function_centredata tmpStr2 "$MFC_DISPLAY_FILETYPE_LENGTH" "0"
		if [[ "$oppmodename" == "Simple" ]]; then	# COMPLETE MODE
			private_func_spaces "3" spacesStr
			tmpStr1+="$spacesStr$tmpStr2"

			tmpStr2="${tmpArr3[tmpElem]}"
			tmpStr2="${tmpStr2:0:$MFC_DISPLAY_FILESIZE_LENGTH}"
			function_centredata tmpStr2 "$MFC_DISPLAY_FILESIZE_LENGTH" "0"
			private_func_spaces "5" spacesStr
			tmpStr1+="$spacesStr$tmpStr2"

			tmpStr2="${tmpArr4[tmpElem]}"
			tmpStr2="${tmpStr2:0:$MFC_DISPLAY_FILETIME_LENGTH}"
			function_centredata tmpStr2 "$MFC_DISPLAY_FILETIME_LENGTH" "0"
			private_func_spaces "11" spacesStr
			tmpStr1+="$spacesStr$tmpStr2"
			if [ $multiselmode -eq 1 ]; then
				tmpStr1+="$spacesStr"
			fi
		else						# SIMPLE MODE
			private_func_spaces "1" spacesStr
			tmpStr1+="$spacesStr$tmpStr2"
		fi
		tmpArr+=("$tmpStr1")
		if [ $multiselmode -eq 1 ]; then
			tmpArr+=("OFF")
		fi
	done

	returnArr2=("${tmpArr[@]}")

	unset tmpArr
	unset tmpArr1
	unset tmpArr2
	unset tmpArr3
	unset tmpArr4
}


# Parameter 1 - Complete Mode
private_func_maintainmode()
{
	local lin=`tput lines`
	local col=`tput cols`

	local term_w=0
	local term_h=0

	local completemode="$1"

	if [[ "$completemode" == "1" ]]; then
		if [[ "$MFC_COMPLETE_MODE_W" != "" ]] && [[ "$MFC_COMPLETE_MODE_W" != "0" ]] && \
		[[ "$MFC_COMPLETE_MODE_H" != "" ]] && [[ "$MFC_COMPLETE_MODE_H" != "0" ]]; then
			if [ $MFC_COMPLETE_MODE_W -ge $MFC_COMPLETE_MODE_MIN_W ] && [ $MFC_COMPLETE_MODE_H -ge $MFC_COMPLETE_MODE_MIN_H ]; then
				term_w=$MFC_COMPLETE_MODE_W
				term_h=$MFC_COMPLETE_MODE_H
			else
				term_w=$MFC_COMPLETE_MODE_MIN_W
				term_h=$MFC_COMPLETE_MODE_MIN_H
			fi
		else
			term_w=$MFC_COMPLETE_MODE_MIN_W
			term_h=$MFC_COMPLETE_MODE_MIN_H
		fi
	else
		if [[ "$MFC_SIMPLE_MODE_W" != "" ]] && [[ "$MFC_SIMPLE_MODE_W" != "0" ]] && \
		[[ "$MFC_SIMPLE_MODE_H" != "" ]] && [[ "$MFC_SIMPLE_MODE_H" != "0" ]]; then
			if [ $MFC_SIMPLE_MODE_W -ge $MFC_SIMPLE_MODE_MIN_W ] && [ $MFC_SIMPLE_MODE_H -ge $MFC_SIMPLE_MODE_MIN_H ]; then
				term_w=$MFC_SIMPLE_MODE_W
				term_h=$MFC_SIMPLE_MODE_H
			else
				term_w=$MFC_SIMPLE_MODE_MIN_W
				term_h=$MFC_SIMPLE_MODE_MIN_H
			fi
		else
			term_w=$MFC_SIMPLE_MODE_MIN_W
			term_h=$MFC_SIMPLE_MODE_MIN_H
		fi
	fi

	eval `resize -s $term_h $term_w`
	clear
	clear
}


private_func_displaywait()
{
	clear
	clear
	echo
	echo
	echo
	echo
	echo "  Please Wait . . ."
}



# Parameter 1 - Start Directory
# Parameter 2 - Complete Mode Options Mode
# Parameter 3 - Complete Mode
# Parameter 4 - Show Hidden Files Options Mode
# Parameter 5 - Show Hidden Files Mode
# Parameter 6 - Show Only ... Options Mode
# Parameter 7 - Show Only ... Mode ( 1 => Files; 2 => Folders; 3 => Both )
# Parameter 8 - Allow Multiple Selection Mode
# Parameter 9 - File Explorer Action Text
# Parameter 10 - Root Access Mode
mfc_fileexplore()
{
	echo "0" > "src/bin/mfc_fileexplorer_processdone.txt"
	mfc_fileexplorer_filename=()
	mfc_fileexplorer_filepath=()
	mfc_fileexplorer_dirpath=()
	echo -n "" > "src/bin/mfc_fileexplorer_filename.txt"
	echo -n "" > "src/bin/mfc_fileexplorer_filepath.txt"
	echo -n "" > "src/bin/mfc_fileexplorer_dirpath.txt"

	local tmpArr=()

	local filenameArr=()
	local dispoptionsmenu=()
	local realoptionsmenu=()
	local showonlymenu=()
	local filemenu=()
	local sortmenu=()

	local menuselection=""
	local sortselection=""
	local showonlyselection=""
	local optionsselection=""

	local oppmodename="Complete"
	local oppshowhide="Show"
	local sortmode=2

	local spacesStr=""
	local menuhead=""
	local tmpElem=""
	local tmpStr1=""
	local tmpStr2=""
	local tmpStr3=""
	local tmpStr4=""
	local tmpStr5=""
	local dirnme=""
	local curdir=""
	local line=""
	
	local fmid6temp=999990
	local multiselmode=0
	local rootdirmode=0
	local exitstatus=0
	local loopPos=4
	local tmpVal1=0
	local tmpVal2=0
	local fmid2=2
	local fmid4=4
	local fmid6=6
	local i=0

	local startdir="$1"
	local completemodeopt="$2"
	local completemode="$3"
	local hiddenfilesopt="$4"
	local hiddenfilesmode="$5"
	local showonlyopt="$6"
	local showonlymode="$7"
	local allowmultisel="$8"
	local feactext="$9"
	local rootaccessmode="${10}"


	# VALIDATION - START

	if [ -d "$startdir" ]; then
		curdir="$startdir"
	else
		curdir="/home/"`whoami`
	fi

	if [[ "$curdir" != "/" ]] && [[ "${curdir:$((${#curdir}-1)):1}" == "/" ]]; then
		curdir="${curdir:0:$((${#curdir}-1))}"
	fi

	if [[ "$completemodeopt" != "1" ]]; then
		completemodeopt=0
	fi

	if [[ "$completemode" == "1" ]]; then
		oppmodename="Simple"
	else
		completemode=0
	fi

	if [[ "$hiddenfilesopt" != "1" ]]; then
		hiddenfilesopt=0
	fi

	if [[ "$hiddenfilesmode" == "1" ]]; then
		oppshowhide="Hide"
	else
		hiddenfilesmode="0"
	fi

	if [[ "$showonlyopt" != "1" ]]; then
		showonlyopt=0
	fi

	if [[ "$showonlymode" != "1" ]] && [[ "$showonlymode" != "2" ]]; then
		showonlymode="3"
	fi

	if [[ "$allowmultisel" != "1" ]]; then
		allowmultisel="0"
	fi

	if [ ${#feactext} -eq 0 -o ${#feactext} -gt 10 ]; then
		feactext="use"
	else
		feactext=$(echo -e $feactext | tr -d '\t')
		feactext=$(echo -e $feactext | tr -d '\n')
		feactext=$(echo -e $feactext | tr -d ' ')
	fi

	if [[ "$rootaccessmode" == "1" ]]; then
		sudo -s
		clear
		clear
	else
		rootaccessmode="0"
	fi

	# VALIDATION - END


	while :
	do
		if [ $loopPos -eq 0 ]; then
			break
		fi

		private_func_maintainmode "$completemode"

		dirnme=""
		tmpStr1="$curdir"
		for ((i = $((${#tmpStr1}-1)) ; i >= 0 ; i--))
		do
			if [[ "${tmpStr1:$i:1}" == "/" ]]; then
				break
			else
				dirnme="${tmpStr1:$i:1}""$dirnme"
			fi
		done

		local fmid2=2
		local fmid4=4
		local fmid6=6
		local fmid6temp=999990
		if [[ "$dirnme" == "" ]]; then
			curdir=""
			rootdirmode=1
			fmid2=999999
			fmid4=2
			fmid6=4
		else
			curdir="${tmpStr1:0:$((${#tmpStr1}-${#dirnme}-1))}"
		fi

		if [ $allowmultisel -eq 1 ]; then
			fmid6temp=$fmid6
			if [ $showonlymode -eq 1 ]; then
				let "fmid6temp = fmid6temp - 2"
			fi
			let "fmid6 = fmid6 + 2"
		fi

		if [ $showonlymode -eq 1 ]; then
			fmid2=999999
			fmid4=2
			fmid6=899999
		fi

		private_func_recreate_optmenu "$completemodeopt" "$oppmodename" "$oppshowhide" "$hiddenfilesopt" \
		"$showonlyopt" dispoptionsmenu realoptionsmenu
		private_func_recreate_sortmenu "$oppmodename" sortmenu
		private_func_recreate_showonlymenu showonlymenu
		private_func_recreate_filemenu "$curdir/$dirnme" "$oppmodename" "$hiddenfilesmode" "$showonlymode" \
		"$allowmultisel" "$multiselmode" "$sortmode" filenameArr filemenu

		loopPos=4

		if [ $showonlymode -eq 1 ]; then
			if [ $multiselmode -eq 0 ]; then
				tmpArr=("\n" "Choose a File :" "\n")
			else
				tmpArr=("\n" "Choose one or more Files :" "\n")
			fi
		elif [ $showonlymode -eq 2 ]; then
			if [ $multiselmode -eq 0 ]; then
				tmpArr=("\n" "Choose a Directory or Enter Directories :" "\n")
			else
				tmpArr=("\n" "Choose one or more Directories or Enter Directories :" "\n")
			fi
		else
			if [ $multiselmode -eq 0 ]; then
				tmpArr=("\n" "Choose a File/Directory or Enter Directories :" "\n")
			else
				tmpArr=("\n" "Choose one or more Files/Directories or Enter Directories :" "\n")
			fi
		fi
		mfc_rectangularheader "$MFC_HEADING_LENGTH" "" "0" "1" "1" "3" "1" "1" "3" "" "*" "${tmpArr[@]}"
		menuhead="$mfc_headerdesignresult"


		while :
		do
			private_func_displaywait

			if [ $loopPos -le 1 ]; then
				break
			else
				loopPos=4
			fi

			private_func_maintainmode "$completemode"


			clear
			clear
			if [ $multiselmode -eq 1 ]; then
				eval `resize`
				menuselection=$(whiptail --title "MFC Linux File Explorer" --checklist --separate-output \
				"\n\n$menuhead\n\n\n" $LINES $(( $COLUMNS )) $(( $LINES - 15 )) "${filemenu[@]}" 3>&2 2>&1 1>&3)
			else
				eval `resize`
				menuselection=$(whiptail --title "MFC Linux File Explorer" --menu "\n\n$menuhead\n\n\n" \
				$LINES $(( $COLUMNS )) $(( $LINES - 15 )) "${filemenu[@]}" 3>&2 2>&1 1>&3)
			fi

			exitstatus=$?

			private_func_displaywait

			if [ $exitstatus -eq 0 -a $multiselmode -eq 0 ]; then

				if [[ "$menuselection" == "${filemenu[0]}" ]]; then		# HEADING Clicked
					loopPos=2
				elif [[ "$menuselection" == "${filemenu[$fmid2]}" ]]; then	# GO BACK Clicked
					loopPos=1
				elif [[ "$menuselection" == "${filemenu[$fmid4]}" ]]; then	# OPTIONS Clicked
					while :
					do
						if [ $loopPos -le 2 ]; then
							break
						else
							loopPos=4
						fi

						private_func_maintainmode "$completemode"

						optionsselection=$(whiptail --title "MFC Linux File Explorer" --menu "\n\n\n" --nocancel \
						$LINES "$COLUMNS" $(( $LINES - 12 )) "${dispoptionsmenu[@]}" 3>&2 2>&1 1>&3)
						if [[ "$optionsselection" == "${dispoptionsmenu[2]}" ]]; then	# GO BACK Clicked
							loopPos=2
						elif [[ "${realoptionsmenu[${optionsselection:1:1}]}" == "1" ]]; then	# SORT Clicked
							while :
							do
								if [ $loopPos -le 3 ]; then
									break
								fi

								private_func_maintainmode "$completemode"

								sortselection=$(whiptail --title "MFC Linux File Explorer" --menu "\n\n\n" --nocancel \
								$LINES "$COLUMNS" $(( $LINES - 12 )) "${sortmenu[@]}" 3>&2 2>&1 1>&3)
								if [[ "$sortselection" == "${sortmenu[2]}" ]]; then	# GO BACK Clicked
									loopPos=3
								else
									if [[ "$sortselection" == "${sortmenu[4]}" ]]; then
										sortmode=1
									elif [[ "$sortselection" == "${sortmenu[6]}" ]]; then
										sortmode=2
									elif [[ "$sortselection" == "${sortmenu[8]}" ]]; then
										sortmode=3
									elif [[ "$sortselection" == "${sortmenu[10]}" ]]; then
										sortmode=4
									elif [[ "$sortselection" == "${sortmenu[12]}" ]]; then
										sortmode=5
									elif [[ "$sortselection" == "${sortmenu[14]}" ]]; then
										sortmode=6
									elif [[ "$sortselection" == "${sortmenu[16]}" ]]; then
										sortmode=7
									elif [[ "$sortselection" == "${sortmenu[18]}" ]]; then
										sortmode=8
									elif [[ "$sortselection" == "${sortmenu[20]}" ]]; then
										sortmode=9
									fi
									curdir="$curdir/$dirnme"
									loopPos=1
								fi
							done
						elif [[ "${realoptionsmenu[${optionsselection:1:1}]}" == "2" ]]; then	# SHOW ONLY Clicked
							while :
							do
								if [ $loopPos -le 3 ]; then
									break
								fi

								private_func_maintainmode "$completemode"

								showonlyselection=$(whiptail --title "MFC Linux File Explorer" --menu \
								"\n\n\n" --nocancel $LINES "$COLUMNS" $(( $LINES - 12 )) "${showonlymenu[@]}" \
								3>&2 2>&1 1>&3)
								if [[ "$showonlyselection" == "${showonlymenu[2]}" ]]; then	# GO BACK Clicked
									loopPos=3
								else
									if [[ "$showonlyselection" == "${showonlymenu[4]}" ]]; then
										showonlymode=1
									elif [[ "$showonlyselection" == "${showonlymenu[6]}" ]]; then
										showonlymode=2
									elif [[ "$showonlyselection" == "${showonlymenu[8]}" ]]; then
										showonlymode=3
									fi
									curdir="$curdir/$dirnme"
									loopPos=1
								fi
							done
						elif [[ "${realoptionsmenu[${optionsselection:1:1}]}" == "3" ]]; then
														# SHOW/HIDE HIDDEN FILES Clicked
							if [[ "$hiddenfilesmode" == "1" ]]; then	# Switch to Hide Mode
								hiddenfilesmode="0"
								oppshowhide="Show"
							else						# Switch to Show Mode
								hiddenfilesmode="1"
								oppshowhide="Hide"
							fi
							curdir="$curdir/$dirnme"
							loopPos=1
						elif [[ "${realoptionsmenu[${optionsselection:1:1}]}" == "4" ]]; then	# SWITCH MODE Clicked
							if [ $completemode -eq 1 ]; then	# Switch to Simple Mode
								completemode=0
								oppmodename="Complete"
							else				# Switch to Complete Mode
								completemode=1
								oppmodename="Simple"
							fi
							curdir="$curdir/$dirnme"
							loopPos=1
						fi
					done

				elif [[ "$menuselection" == "${filemenu[$fmid6temp]}" ]]; then	# Switch to MULTI-SELECTION Mode

					multiselmode=1
					curdir="$curdir/$dirnme"
					loopPos=1

				else							# Some FILE/DIRECTORY Clicked
					while :
					do
						if [ $loopPos -le 2 ]; then
							break
						fi

						private_func_maintainmode "$completemode"

						if [[ "$menuselection" != "${filemenu[0]}" ]]; then
							tmpStr1="---"
							for tmpElem in ${filenameArr[@]}
							do
								if [ ${#menuselection} -gt $MFC_DISPLAY_FILENAME_LENGTH ]; then
									tmpStr3="${menuselection:1:$MFC_DISP_SHORT_FN_HALF_LEN}"
									tmpStr4="$((${#menuselection}-$MFC_DISP_SHORT_FN_HALF_LEN))"
									tmpStr5="${menuselection:$tmpStr4:$MFC_DISP_SHORT_FN_HALF_LEN}"
									if [[ "$tmpElem" == *"$tmpStr3"* ]] && \
										[[ "$tmpElem" == *"$tmpStr5"* ]]; then
										tmpStr1="$tmpElem"
										break
									fi
								else
									if [[ "$tmpElem" == *"${menuselection:1}"* ]]; then
										tmpStr1="$tmpElem"
										break
									fi
								fi
							done
							private_func_spaces "2" spacesStr
							if [ -d "$curdir/$dirnme/$tmpStr1" ]; then	# DIRECTORY Clicked
								echo "0" > "src/bin/findperm.txt"
								tmpStr3=`ls -ld "$curdir/$dirnme/$tmpStr1" 2> "src/bin/findperm.txt"`
								tmpStr4=""
								while read -r -s line
								do
									tmpStr4+="$line"
								done < "src/bin/findperm.txt"
								if [[ "$tmpStr4" == "0" ]] || [[ "$tmpStr4" == "" ]]; then
									if [ $rootaccessmode -eq 1 ] && [[ "$tmpStr3" == *"root"* ]]; then
										curdir="$curdir/$dirnme/$tmpStr1"
										loopPos=1
										break
									elif [ $rootaccessmode -eq 0 ] && [[ "$tmpStr3" != *"root"* ]]; then
										curdir="$curdir/$dirnme/$tmpStr1"
										loopPos=1
										break
									fi
								fi
								tmpStr2="\n$spacesStr""Permissions have been denied to access the "
								tmpStr2+="selected\n$spacesStr""directory ! 'Root' privilege is required."
								whiptail --title "ERROR" --msgbox "$tmpStr2" 10 65
								loopPos=2

							elif [ -f "$curdir/$dirnme/$tmpStr1" ]; then	# FILE Clicked

								tmpStr2="\n$spacesStr""Permissions have been denied to access the "
								tmpStr2+="selected\n$spacesStr""directory ! 'Root' privilege is required."
								echo "0" > "src/bin/findperm.txt"
								tmpStr3=`ls -ld "$curdir/$dirnme/$tmpStr1" 2> "src/bin/findperm.txt"`
								tmpStr4=""
								while read -r -s line
								do
									tmpStr4+="$line"
								done < "src/bin/findperm.txt"
								if [[ "$tmpStr4" == "0" ]] || [[ "$tmpStr4" == "" ]]; then
									if [ $rootaccessmode -eq 0 ] && [[ "$tmpStr3" == *"root"* ]]; then
										whiptail --title "ERROR" --msgbox "$tmpStr2" 10 65
										loopPos=2
										break
									fi
								else
									whiptail --title "ERROR" --msgbox "$tmpStr2" 10 65
									loopPos=2
									break
								fi

								tmpStr3="$tmpStr1"
								private_func_shortentext tmpStr3 "40" "18" "19"
								tmpStr2="\n$spacesStr""File Name :$spacesStr$tmpStr3"
								tmpStr3="$curdir/$dirnme"
								if [[ "$curdir" == "" ]]; then
									tmpStr3="/$dirnme"
								fi
								private_func_shortentext tmpStr3 "80" "40" "37"
								tmpStr2+="\n$spacesStr""File Path :$spacesStr${tmpStr3:0:40}"
								if [ ${#tmpStr3} -gt 40 ]; then
									private_func_spaces "11" tmpStr4
									tmpStr2+="\n$spacesStr""$tmpStr4$spacesStr${tmpStr3:40}"
								fi
								private_func_getfilesize "$curdir/$dirnme/$tmpStr1" "1" tmpStr4
								tmpStr2+="\n\n$spacesStr""File Size :$spacesStr$tmpStr4"
								private_func_getfiletime "$curdir/$dirnme/$tmpStr1" "1" tmpStr5
								tmpStr2+="\n$spacesStr""File Time :$spacesStr$tmpStr5"
								tmpStr2+="\n\n$spacesStr""Do you wish to "$feactext" this file ?\n"
								if (whiptail --title "QUERY" --yesno "$tmpStr2" --yes-button "No" \
								--no-button "Yes" 16 65); then
									loopPos=2
								else
									if [ $rootdirmode -eq 1 ]; then
										mfc_fileexplorer_dirpath="/"
										tmpStr3=""
									else
										mfc_fileexplorer_dirpath="$curdir/$dirnme"
										tmpStr3="/"
									fi
									echo "$mfc_fileexplorer_dirpath" > "src/bin/mfc_fileexplorer_dirpath.txt"
									mfc_fileexplorer_filename+=("$tmpStr1")
									echo "$tmpStr1" > "src/bin/mfc_fileexplorer_filename.txt"
									tmpStr4="$mfc_fileexplorer_dirpath$tmpStr3$tmpStr1"
									mfc_fileexplorer_filepath+=("$tmpStr4")
									echo "$tmpStr4" > "src/bin/mfc_fileexplorer_filepath.txt"
									mfc_fileexplorer_exit=1
									echo "1" > "src/bin/mfc_fileexplorer_processdone.txt"
									loopPos=0
								fi

							elif [[ "$menuselection" == "${filemenu[$fmid6]}" ]]; then   # CURRENT DIRECTORY Clicked

								tmpStr3="$dirnme"
								if [[ "$curdir" == "" ]]; then
									tmpStr3="/"
								fi
								private_func_shortentext tmpStr3 "40" "18" "19"
								tmpStr2="\n$spacesStr""Directory Name :$spacesStr$tmpStr3"
								tmpStr3="$curdir"
								private_func_shortentext tmpStr3 "80" "40" "37"
								tmpStr2+="\n$spacesStr""Directory Path :$spacesStr${tmpStr3:0:40}"
								if [ ${#tmpStr3} -gt 40 ]; then
									private_func_spaces "15" tmpStr4
									tmpStr2+="\n$spacesStr""$tmpStr4:$spacesStr${tmpStr3:0:40}"
								fi
								echo "0" > "src/bin/finderr1.txt"	# For Files
								echo "0" > "src/bin/finderr2.txt"	# For Directories
								tmpStr4=`find "$curdir/$dirnme" -type f 2> src/bin/finderr1.txt | wc -l`
								tmpStr5=`find "$curdir/$dirnme" -type d 2> src/bin/finderr2.txt | wc -l`
								tmpStr3=""
								while read -r -s line
								do
									tmpStr3+="$line"
								done < "src/bin/finderr1.txt"
								if [[ "$tmpStr3" == "0" ]] || [[ "$tmpStr3" == "" ]]; then
									tmpStr2+="\n\n$spacesStr""There are exactly :$spacesStr$tmpStr4 files"
								else
									tmpStr2+="\n\n$spacesStr""There are about   :$spacesStr$tmpStr4 files"
								fi
								tmpStr3=""
								while read -r -s line
								do
									tmpStr3+="$line"
								done < "src/bin/finderr2.txt"
								if [[ "$tmpStr3" == "0" ]] || [[ "$tmpStr3" == "" ]]; then
									tmpStr2+="\n$spacesStr""There are exactly :$spacesStr$tmpStr5 directories"
								else
									tmpStr2+="\n$spacesStr""There are about   :$spacesStr$tmpStr5 directories"
								fi
								echo "0" > "src/bin/finderr1.txt"
								echo "0" > "src/bin/finderr2.txt"
								tmpStr2+="\n\n$spacesStr""Do you wish to "$feactext" this folder ?\n"
								if (whiptail --title "QUERY" --yesno "$tmpStr2" --yes-button "No" \
								--no-button "Yes" 16 65); then
									loopPos=2
								else
									if [ $rootdirmode -eq 1 ]; then
										mfc_fileexplorer_dirpath="/"
										tmpStr1=""
										tmpStr3=""
									else
										mfc_fileexplorer_dirpath="$curdir"
										tmpStr1="$dirnme"
										tmpStr3="/"
									fi
									echo "$mfc_fileexplorer_dirpath" > "src/bin/mfc_fileexplorer_dirpath.txt"
									mfc_fileexplorer_filename+=("$tmpStr1")
									echo "$tmpStr1" > "src/bin/mfc_fileexplorer_filename.txt"
									tmpStr4="$mfc_fileexplorer_dirpath$tmpStr3$tmpStr1"
									mfc_fileexplorer_filepath+=("$tmpStr4")
									echo "$tmpStr4" > "src/bin/mfc_fileexplorer_filepath.txt"
									mfc_fileexplorer_exit=1
									echo "1" > "src/bin/mfc_fileexplorer_processdone.txt"
									loopPos=0
								fi
							else
								tmpStr2="\n$spacesStr""The file/directory selected does not exist in your system."
								tmpStr2+="\n$spacesStr""Please try again !"
								whiptail --title "ERROR" --msgbox "$tmpStr2" 10 65
								loopPos=2
							fi
						fi
					done
				fi

			elif [ $exitstatus -eq 0 -a $multiselmode -eq 1 ]; then

				private_func_spaces "2" spacesStr

				if [[ "$menuselection" == *"$SWITCH_FROM_MULTI_SEL"* ]]; then	# Switch from MULTI-SELECTION Mode
					multiselmode=0
					curdir="$curdir/$dirnme"
					loopPos=1
				elif [[ "$menuselection" == "" ]]; then # NO SELECTION
					tmpStr2="\n$spacesStr""No Selection has been made yet. Please try again !\n"
					whiptail --title "ERROR" --msgbox "$tmpStr2" 10 65
					loopPos=2
				else
					tmpVal1=0	# Number of Folders
					tmpVal2=0	# Number of Files
					tmpArr=($menuselection)
					for tmpElem in "${!tmpArr[@]}"
					do
						i=1
						tmpStr1="${tmpArr[$tmpElem]}"
						echo "0" > "src/bin/findperm.txt"
						tmpStr3=`ls -ld "$curdir/$dirnme/$tmpStr1" 2> "src/bin/findperm.txt"`
						tmpStr4=""
						while read -rs line
						do
							tmpStr4+="$line"
						done < "src/bin/findperm.txt"
						if [[ "$tmpStr4" == "0" ]] || [[ "$tmpStr4" == "" ]]; then
							if [ $rootaccessmode -eq 0 ] && [[ "$tmpStr3" == *"root"* ]]; then
								i=0
								break
							fi
						else
							i=0
							break
						fi

						if [ -d "$curdir/$dirnme/$tmpStr1" ]; then
							let "tmpVal1++"
						else
							let "tmpVal2++"
						fi
						tmpArr[$tmpElem]="$tmpStr1"
					done

					if [ $i -eq 1 ]; then

						if [ $tmpVal1 -ne 0 -a $tmpVal2 -eq 0 ]; then		# Folders, No Files
							tmpStr2+="\n$spacesStr""$tmpVal1 Folders have been selected."
							tmpStr3="folders"
						elif [ $tmpVal1 -eq 0 -a $tmpVal2 -ne 0 ]; then		# Files, No Folders
							tmpStr2+="\n$spacesStr""$tmpVal2 Files have been selected."
							tmpStr3="files"
						else							# Both Files and Folders
							tmpStr2+="\n$spacesStr""$tmpVal1 Folders and $tmpVal2 Files have been selected."
							tmpStr3="files and folders"
						fi
						tmpStr2+="\n\n$spacesStr""Do you wish to "$feactext" these $tmpStr3 ?\n"
						if (whiptail --title "QUERY" --yesno "$tmpStr2" --yes-button "No" \
						--no-button "Yes" 12 65); then
							loopPos=2
						else
							if [ $rootdirmode -eq 1 ]; then
								mfc_fileexplorer_dirpath="/"
								tmpStr3=""
							else
								mfc_fileexplorer_dirpath="$curdir/$dirnme"
								tmpStr3="/"
							fi
							echo "$mfc_fileexplorer_dirpath" > "src/bin/mfc_fileexplorer_dirpath.txt"
							for tmpElem in "${tmpArr[@]}"
							do
								mfc_fileexplorer_filename+=("$tmpElem")
								tmpStr4="$mfc_fileexplorer_dirpath$tmpStr3$tmpElem"
								mfc_fileexplorer_filepath+=("$tmpStr4")
								echo "$tmpElem" >> "src/bin/mfc_fileexplorer_filename.txt"
								echo "$tmpStr4" >> "src/bin/mfc_fileexplorer_filepath.txt"
							done
							mfc_fileexplorer_exit=1
							echo "1" > "src/bin/mfc_fileexplorer_processdone.txt"
							loopPos=0

						fi
					else

						if [ $tmpVal1 -ne 0 -a $tmpVal2 -eq 0 ]; then		# Folders, No Files
							tmpStr3="directories"
						elif [ $tmpVal1 -eq 0 -a $tmpVal2 -ne 0 ]; then		# Files, No Folders
							tmpStr3="files"
						else							# Both Files and Folders
							tmpStr3="files/directories"
						fi
						tmpStr2="\n$spacesStr""Permissions have been denied to access one of the "
						tmpStr2+="selected\n$spacesStr""$tmpStr3 ! 'Root' privilege is required."
						whiptail --title "ERROR" --msgbox "$tmpStr2" 10 65
						loopPos=2
						tmpArr=()

					fi
				fi
			else
				loopPos=0
			fi
		done
	done

	if [ $mfc_fileexplorer_exit -ne 1 ]; then
		mfc_fileexplorer_exit=-1
		echo "-1" > "src/bin/mfc_fileexplorer_processdone.txt"
	fi

	exit 0
}



