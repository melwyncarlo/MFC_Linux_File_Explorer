#!/bin/bash



mfc_headerdesignresult=""

readonly MAX_TEXTLROFFSET=5
readonly MAX_TEXTTBOFFSET=5
readonly MAX_DESIGNMODEVAL=5
readonly SCROLLHEADER_MAINOFFSET=16
readonly RECTHEADER_MAINOFFSET=2


# Parameter 1 - Data	[ REFERENCE ]
# Parameter 2 - Whiptail Columns
# Parameter 3 - Multi Offset Mode
# Parameter 4 - Left Offset Code
# Parameter 5 - Right Offset Code
function_centredata()
{
	local mainStr=""
	local lhs=0
	local rhs=0

	local -n tmpStr=$1
	local tmpLen=${#tmpStr}
	local cols=$2
	local moffsetmode=$3
	local loffsetcode=$4
	local roffsetcode=$5
	
	let "lhs = (cols - tmpLen) / 2"
	let "rhs = cols - tmpLen - lhs"

	if [ ${#loffsetcode} -eq 0 ]; then
		loffsetcode=" "	
	fi
	if [ ${#roffsetcode} -eq 0 ]; then
		roffsetcode=" "	
	fi
	
	if [ $moffsetmode -eq 0 ]; then
		local i=1
		for ((i = 1 ; i <= $lhs ; i++))
		do
			mainStr+="${loffsetcode:0:1}"
		done
	else
		mainStr+="$loffsetcode"
	fi
	mainStr+=$tmpStr
	if [ $moffsetmode -eq 0 ]; then
		local j=1
		for ((j = 1 ; j <= $rhs ; j++))
		do
			mainStr+="${roffsetcode:0:1}"
		done
	else
		mainStr+="$roffsetcode"
	fi
	tmpStr="$mainStr"
}


# Parameter 1 - Columns
# Parameter 2 - Scroll Bar Color Code
# Parameter 3 - Offset
# Parameter 4 - String of Align Spaces
# Parameter 5 - Simple Mode
# Parameter 6 - Return Text	[ REFERENCE ]
private_func_sh1()
{
	local defaultformatcode=""
	local formatcode=""

	local cols=$1
	local bgcol2=$2
	local offset=$3	
	local repch="$5"
	local -n returntext=$6
	returntext=""

	if [ "$repch" == " " ]; then
		formatcode="\e[48;5;${bgcol2}m"
		defaultformatcode="\e[0m"
	fi

	local loop=1
	while [ $loop -le 2 ]
	do
		returntext+="$4   $formatcode$repch$repch$repch$defaultformatcode  "
		let "mid = cols - offset"
		local i=1
		for ((i = 1; i <= $mid ; i++))
		do
			returntext+=" "
		done
		returntext+="  $formatcode$repch$repch$repch$defaultformatcode   \n"
		let "loop++"
	done
}


# Parameter 1 - Columns
# Parameter 2 - Scroll Sheet Color Code
# Parameter 3 - Offset
# Parameter 4 - String of Align Spaces
# Parameter 5 - Simple Mode
# Parameter 6 - Return Text	[ REFERENCE ]
private_func_sh2()
{
	local defaultformatcode=""
	local formatcode=""

	local cols=$1
	local bgcol1=$2
	local offset=$3	
	local repch="$5"
	local -n returntext=$6
	returntext=""

	if [ "$repch" == " " ]; then
		formatcode="\e[48;5;${bgcol1}m"
		defaultformatcode="\e[0m"
	fi

	returntext+="$4 $formatcode$repch$repch$repch$repch$repch$repch$repch$defaultformatcode"
	let "mid = cols - offset"
	local i=1
	for ((i = 1; i <= $mid ; i++))
	do
		returntext+=" "
	done
	returntext+="$formatcode$repch$repch$repch$repch$repch$repch$repch$defaultformatcode \n"
}


# Parameter 1 - Columns
# Parameter 2 - Scroll Sheet Color Code
# Parameter 3 - Offset
# Parameter 4 - String of Align Spaces
# Parameter 5 - Simple Mode
# Parameter 6 - Return Text	[ REFERENCE ]
private_func_sh3()
{
	local defaultformatcode=""
	local formatcode=""

	local cols=$1
	local bgcol1=$2
	local offset=$3
	local repch="$5"
	local -n returntext=$6
	returntext=""

	if [ "$repch" == " " ]; then
		formatcode="\e[48;5;${bgcol1}m"
		defaultformatcode="\e[0m"
	fi

	returntext+="$4 $formatcode$repch$defaultformatcode     $formatcode$repch$defaultformatcode"
	let "mid = cols - offset"
	local i=1
	for ((i = 1; i <= $mid ; i++))
	do
		returntext+="$formatcode$repch$defaultformatcode"
	done
	returntext+="$formatcode$repch$defaultformatcode     $formatcode$repch$defaultformatcode \n"
}


# Parameter 1 - Columns
# Parameter 2 - Scroll Sheet Color Code
# Parameter 3 - Offset
# Parameter 4 - Number of Loops
# Parameter 5 - Text
# Parameter 6 - Left-Right Text Offset
# Parameter 7 - String of Align Spaces
# Parameter 8 - Simple Mode
# Parameter 9 - Return Text	[ REFERENCE ]
private_func_sh04()
{
	local defaultformatcode=""
	local formatcode=""

	local cols=$1
	local bgcol1=$2
	local offset=$3
	local nloops=$4
	local text=$5
	local textoffset=$6
	local repch="$8"
	local -n returntext=$9
	returntext=""

	if [ "$repch" == " " ]; then
		formatcode="\e[48;5;${bgcol1}m"
		defaultformatcode="\e[0m"
	fi

	local mid=0
	local tmpLen=0
	let "mid = cols - offset"
	let "tmpLen = mid - textoffset - textoffset"
	if [ ${#text} -gt $tmpLen ]; then
		text=${text:0:$tmpLen}
	fi

	local loop=1
	while [ $loop -le $nloops ]
	do
		returntext+="$7 $formatcode$repch$defaultformatcode     $formatcode$repch$defaultformatcode"
		if [ ${#text} -gt 0 ]; then
			function_centredata text "$mid" "0" " " " "
			returntext+="$text"
		else
			local i=1
			for ((i = 1; i <= $mid ; i++))
			do
				returntext+=" "
			done
		fi
		returntext+="$formatcode$repch$defaultformatcode     $formatcode$repch$defaultformatcode \n"
		let "loop++"
	done
}


# Parameter 1 - Columns
# Parameter 2 - Scroll Bar Color Code
# Parameter 3 - Offset
# Parameter 4 - String of Align Spaces
# Parameter 5 - Shadow Mode Color Code
# Parameter 6 - String of Shadow Thickness Spaces
# Parameter 7 - Simple Mode Character
# Parameter 8 - Return Text		[ REFERENCE ]
private_func_rh1()
{
	local defaultformatcode=""
	local formatcode1=""
	local formatcode2=""

	local cols=$1
	local bgcol=$2
	local offset=$3
	local smcol=$5
	local sts=$6
	local repch="$7"

	local -n returntext=$8
	returntext=""

	if [ "$repch" == " " ]; then
		formatcode1="\e[48;5;${bgcol}m"
		formatcode2="\e[48;5;${smcol}m"
		defaultformatcode="\e[0m"
	fi
	
	returntext+="$4 $formatcode1"
	let "mid = cols - offset - ${#sts}"
	local i=1
	for ((i = 1; i <= $mid ; i++))
	do
		returntext+="$repch"
	done
	returntext+="$formatcode2$sts$defaultformatcode\n"
}


# Parameter 1 - Columns
# Parameter 2 - Scroll Sheet Color Code
# Parameter 3 - Offset
# Parameter 4 - Number of Loops
# Parameter 5 - Text
# Parameter 6 - Text Alignment
# Parameter 7 - Left-Right Text Offset
# Parameter 8 - String of Align Spaces
# Parameter 9 - String of Left Thickness Spaces
# Parameter 10 - String of Right Thickness Spaces
# Parameter 11 - Shadow Mode Color Code
# Parameter 12 - String of Shadow Thickness Spaces
# Parameter 13 - Simple Mode
# Parameter 14 - Return Text		[ REFERENCE ]
private_func_rh4()
{
	local defaultformatcode=""
	local formatcode1=""
	local formatcode2=""

	local cols=$1
	local bgcol=$2
	local offset=$3
	local nloops=$4
	local text=$5
	local textalign=$6
	local textoffset=$7
	local lts=$9
	local rts=${10}
	local smcol=${11}
	local sts=${12}
	local -n returntext=${14}
	returntext=""

	if [ "${13}" == " " ]; then
		formatcode1="\e[48;5;${bgcol}m"
		formatcode2="\e[48;5;${smcol}m"
		defaultformatcode="\e[0m"
	fi

	local mid=0
	local tmpLen=0
	let "mid = cols - offset - ${#lts} - ${#rts} - ${#sts}"
	let "tmpLen = mid - textoffset - textoffset"
	if [ ${#text} -gt $tmpLen ]; then
		text=${text:0:$tmpLen}
	fi

	local loop=1
	while [ $loop -le $nloops ]
	do
		returntext+="$8 $formatcode1$lts$defaultformatcode"
		if [ ${#text} -gt 0 ]; then
			local tmpStr0=""
			if [ $textalign -eq 2 ]; then
				for ((i = 1; i <= $textoffset ; i++))
				do
					tmpStr0+=" "
				done
				tmpStr0+="$text"
				local j=1
				let "mid2 = mid - $textoffset - ${#text}"
				for ((j = 1; j <= $mid2 ; j++))
				do
					tmpStr0+=" "
				done
			else
				tmpStr1=" "
				function_centredata text "$mid" "0" "$tmpStr1" "$tmpStr1"
				tmpStr0=$text
			fi
			returntext+="$tmpStr0"
		else
			local k=1
			for ((k = 1; k <= $mid ; k++))
			do
				returntext+=" "
			done
		fi
		returntext+="$formatcode1$rts$formatcode2$sts$defaultformatcode\n"
		let "loop++"
	done
}


# Parameter 1 - Return Data as an Array		[ REFERENCE ]
# Parameter 2 - Columns
# Parameter 3 - Main Offset
# Parameter 4 - Other Offsets
# Parameter N - Data as an Array
prefunction_header()
{
	local -n returnArr=$1
	local cols=$2
	local mainoffset=$3
	local otheroffsets=$4
	shift 4
	local tmpStr1=("${@}")

	let "availablespace = cols - mainoffset - otheroffsets"

	local i=0
	for ((i = 0 ; i <= ${#tmpStr1[@]} ; i++))
	do
		local availableinput=$availablespace
		local tmpStr1b=(${tmpStr1[$i]})
		local tmpStr2=""
		local j=0

		for ((j = 0 ; j <= ${#tmpStr1b[@]} ; j++))
		do
			let "availableinputprediction = availableinput - ${#tmpStr1b[$j]} - 1"
			if [ $availableinputprediction -lt 0 ]; then
				returnArr+=("$tmpStr2")
				tmpStr2=""
				availableinput=$availablespace
				if [ ${#tmpStr1b[$j]} -lt $availablespace ]; then
					let "j--"
				fi
			elif [ $j -eq ${#tmpStr1b[@]} ]; then
				if [[ "$tmpStr2" == *"\n"* ]]; then
					tmpStr2=" "
				fi
				if [[ "$tmpStr2" != "" ]]; then
					returnArr+=("$tmpStr2")
				fi
				break
			else
				tmpStr2+="${tmpStr1b[$j]} "
				let "availableinput = availableinput - ${#tmpStr1b[$j]} - 1"
			fi
		done
	done
}


# Parameter 1 - String		[ REFERENCE ]
prefunc_parsenum()
{
	local strram=""
	local digitref='^[0-9]+$'

	local -n datastr=$1

	for ((i = 0 ; i < ${#datastr} ; i++))
	do
		if [[ ${datastr:$i:1} =~ $digitref ]] ; then
			strram+=${datastr:$i:1}
		fi
	done
	if [[ "$strram" == "" ]]; then
		strram="0"
	fi
	datastr=$strram
}


# Parameter 1 - Columns				[ REFERENCE ]
# Parameter 2 - Simple Mode Character		[ REFERENCE ]
# Parameter 3 - Text Left/Right Offset		[ REFERENCE ]
# Parameter 4 - Text Top/Bottom Offset		[ REFERENCE ]
# Parameter 5 - Full Size (Length)
# Parameter 6 - Scroll/Box Alignment
# Parameter 7 - Align Spaces			[ REFERENCE ]
prefunc_validation()
{
	local winCols=`tput cols`
	local remainderCols=0

	local -n input1=$1
	local -n input2="$2"
	local -n input3=$3
	local -n input4=$4
	local input5=$5
	local input6=$6
	local -n input7="$7"

	input2=${input2:0:1}
	if [[ $input2 == "" ]]; then
		input2=" "	# Meaning, NOT Simple
	fi

	if [ $input3 -le 0 ]; then
		input3=1
	elif [ $input3 -gt $MAX_TEXTLROFFSET ]; then
		input3=$MAX_TEXTLROFFSET
	fi

	if [ $input4 -le 0 ]; then
		input4=1
	elif [ $input4 -gt $MAX_TEXTTBOFFSET ]; then
		input4=$MAX_TEXTTBOFFSET
	fi

	if [ $input5 -eq 1 ]; then
		input1=$winCols
	fi

	let "remainderCols = winCols-input1"
	if [ $input6 -ne 2 -a $remainderCols -gt 1 ]; then
		let "remainderCols = remainderCols / 2"
		local i=0
		for ((i = 1 ; i <= $remainderCols ; i++))
		do
			input7+=" "
		done
	fi
}


# Parameter 1 - Columns
# Parameter 2 - Scroll Sheet Color Code
# Parameter 3 - Scroll Bar Color Code
# Parameter 4 - Full Size (Length)
# Parameter 5 - Scroll Alignment ( 1 => Center; 2 => Left)
# Parameter 6 - Text Left/Right Offset
# Parameter 7 - Text Top/Bottom Offset
# Parameter 8 - Simple Mode Character
# Parameter N - Data as an Array
mfc_scrollheader()
{
	mfc_headerdesignresult=""
	local tmpStr=""
	local tmpArr=()
	local alignSpaces=""
	local tmpNum=0

	local cols=$1			# INTEGER
	local bgcol1=$2			# INTEGER
	local bgcol2=$3			# INTEGER
	local fullLength=$4		# INTEGER
	local scrollAlign=$5		# INTEGER
	local textlroffset=$6		# INTEGER
	local texttboffset=$7		# INTEGER
	local simplemodechar=$8		# CHARACTER
	shift 8
	local data=("${@}")


	#     *****     PARSING DATA AS NUMBER     *****     #
	prefunc_parsenum cols
	prefunc_parsenum bgcol1
	prefunc_parsenum bgcol2
	prefunc_parsenum fullLength
	prefunc_parsenum scrollAlign
	prefunc_parsenum textlroffset
	prefunc_parsenum texttboffset


	#     *****     VALIDATION - START     *****     #

	prefunc_validation cols simplemodechar textlroffset texttboffset "$fullLength" "$scrollAlign" alignSpaces

	let "tmpNum = textlroffset + textlroffset"
	prefunction_header tmpArr "$cols" "$SCROLLHEADER_MAINOFFSET" "$tmpNum" "${data[@]}"

	#     *****     VALIDATION - END     *****     #


	private_func_sh1 "$cols" "$bgcol2" "$SCROLLHEADER_MAINOFFSET" "$alignSpaces" "$simplemodechar" tmpStr
	mfc_headerdesignresult+=$tmpStr
	private_func_sh2 "$cols" "$bgcol1" "$SCROLLHEADER_MAINOFFSET" "$alignSpaces" "$simplemodechar" tmpStr
	mfc_headerdesignresult+=$tmpStr
	private_func_sh3 "$cols" "$bgcol1" "$SCROLLHEADER_MAINOFFSET" "$alignSpaces" "$simplemodechar" tmpStr
	mfc_headerdesignresult+=$tmpStr

	local j=0
	for ((j = 0 ; j < ${#tmpArr[@]} ; j++))
	do
		private_func_sh04 "$cols" "$bgcol1" "$SCROLLHEADER_MAINOFFSET" "1" "${tmpArr[$j]}" "$textlroffset" "$alignSpaces" \
		"$simplemodechar" tmpStr
		mfc_headerdesignresult+=$tmpStr
	done

	private_func_sh3 "$cols" "$bgcol1" "$SCROLLHEADER_MAINOFFSET" "$alignSpaces" "$simplemodechar" tmpStr
	mfc_headerdesignresult+=$tmpStr
	private_func_sh2 "$cols" "$bgcol1" "$SCROLLHEADER_MAINOFFSET" "$alignSpaces" "$simplemodechar" tmpStr
	mfc_headerdesignresult+=$tmpStr
	private_func_sh1 "$cols" "$bgcol2" "$SCROLLHEADER_MAINOFFSET" "$alignSpaces" "$simplemodechar" tmpStr
	mfc_headerdesignresult+=$tmpStr
}


# Parameter 1 - Columns
# Parameter 2 - Border Color Code
# Parameter 3 - Full Size (Length)
# Parameter 4 - Box Alignment ( 1 => Center; 2 => Left)
# Parameter 5 - Text Alignment ( 1 => Center; 2 => Left)
# Parameter 6 - Text Left/Right Offset
# Parameter 7 - Text Top/Bottom Offset
# Parameter 8 - Design Mode ( 1 => Thickness Mode; 2 => Shadow Mode )
# Parameter 9 - Design Mode Value
# Parameter 10 - Shadow Mode Color Code
# Parameter 11 - Simple Mode Character
# Parameter N - Data as an Array
mfc_rectangularheader()
{
	mfc_headerdesignresult=""
	local tmpStr=""
	local tmpArr=()
	local bottomadditions=0
	local alignSpaces=""
	local leftadditions=""
	local rightadditions=""
	local shadowadditions=""

	local cols=$1			# INTEGER
	local bgcol=$2			# INTEGER
	local fullLength=$3		# INTEGER
	local boxAlign=$4		# INTEGER
	local textalign=$5		# INTEGER
	local textlroffset=$6		# INTEGER
	local texttboffset=$7		# INTEGER
	local designmode=$8		# INTEGER
	local designmodeval=$9		# INTEGER
	local shadowmodecol=${10}	# INTEGER
	local simplemodechar=${11}	# CHARACTER
	shift 11
	local data=("${@}")


	#     *****     PARSING DATA AS INTEGER     *****     #
	prefunc_parsenum cols
	prefunc_parsenum bgcol
	prefunc_parsenum fullLength
	prefunc_parsenum boxAlign
	prefunc_parsenum textalign
	prefunc_parsenum textlroffset
	prefunc_parsenum texttboffset
	prefunc_parsenum designmode
	prefunc_parsenum designmodeval
	prefunc_parsenum shadowmodecol


	#     *****     VALIDATION - START     *****     #

	prefunc_validation cols simplemodechar textlroffset texttboffset "$fullLength" "$boxAlign" alignSpaces

	if [[ "$simplemodechar" != " " ]]; then
		designmode=1
	fi

	if [ $textalign -ne 2 ]; then
		textalign=1
	fi

	if [ $designmode -lt 1 ]; then
		designmode=1
	elif [ $designmode -gt 2 ]; then
		designmode=2
	fi

	if [ $designmodeval -lt 1 ]; then
		designmodeval=1
	elif [ $designmodeval -gt $MAX_DESIGNMODEVAL ]; then
		designmodeval=$MAX_DESIGNMODEVAL
	fi

	local j=1
	for ((j = 1 ; j <= $designmodeval ; j++))
	do
		shadowadditions+="$simplemodechar"
	done

	if [ $designmode -ne 1 ]; then
		if [ $designmodeval -eq 1 ]; then
			bottomadditions=$designmodeval
		else
			let "bottomadditions = (designmodeval / 2)"
		fi
		leftadditions="$simplemodechar"
		rightadditions="$simplemodechar"
	else
		leftadditions="$shadowadditions"
		rightadditions="$shadowadditions"
		shadowadditions=""
		shadowmodecol=$bgcol
	fi

	if [ $bgcol -gt 256 ]; then
		$bgcol=256
	fi

	if [ $shadowmodecol -gt 256 ]; then
		$shadowmodecol=256
	fi

	let "tmpNum = textlroffset + textlroffset + ${#leftadditions} + ${#rightadditions} + ${#shadowadditions}"
	prefunction_header tmpArr "$cols" "$RECTHEADER_MAINOFFSET" "$tmpNum" "${data[@]}"

	#     *****     VALIDATION - END     *****     #


	private_func_rh1 "$cols" "$bgcol" "$RECTHEADER_MAINOFFSET" "$alignSpaces" "$shadowmodecol" "$shadowadditions" \
	"$simplemodechar" tmpStr
	mfc_headerdesignresult+=$tmpStr

	local l=0
	for ((l = 0 ; l < ${#tmpArr[@]} ; l++))
	do
		private_func_rh4 "$cols" "$bgcol" "$RECTHEADER_MAINOFFSET" "1" "${tmpArr[$l]}" "$textalign" "$textlroffset" \
		"$alignSpaces" "$leftadditions" "$rightadditions" "$shadowmodecol" "$shadowadditions" "$simplemodechar" tmpStr
		mfc_headerdesignresult+=$tmpStr
	done

	private_func_rh1 "$cols" "$bgcol" "$RECTHEADER_MAINOFFSET" "$alignSpaces" "$shadowmodecol" "$shadowadditions" \
	"$simplemodechar" tmpStr
	mfc_headerdesignresult+=$tmpStr

	if [ $designmode -ne 1 ]; then
		local m=0
		for ((m = 1 ; m <= $bottomadditions ; m++))
		do
			private_func_rh1 "$cols" "$shadowmodecol" "$RECTHEADER_MAINOFFSET" "$alignSpaces" "$shadowmodecol" \
			"$shadowadditions" "$simplemodechar" tmpStr
			mfc_headerdesignresult+=$tmpStr
		done
	fi
}



