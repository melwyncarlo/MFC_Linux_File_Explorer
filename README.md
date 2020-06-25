# MFC_Linux_File_Explorer

<br>
A Bash Script Library that acts as a Dialog based File Explorer on a Linux Command Terminal (CUI).

<br><br>
### This repository contains 5 MAIN files :
<pre>
1.  webdatacapture.sh                         =>  Main Source (Library) File
2.  *headerdesign.sh                          =>  Supplementary Library File
3.  dailyreading_webdatacapture_demo.shh      =>  Demo 1 File
4.  currencyconverter_webdatacapture_demo.sh  =>  Demo 2 File
5.  webdatacapture_demo_output.txt            =>  Youtube links to the outputs of Demos 1 and 2

* REF - https://github.com/melwyncarlo/Bash_Header_Design
  For Designing CUI-based Heading Banners
</pre>

<br><br>
### The source library contains 2 MAIN functions. <br>Given below are function calls and descriptive lists of arguments :

**1.  Including the Main Source File in Demo Script Files**

`webdata_directory="data"`

`source src/webdatacapture.sh "$webdata_directory/"`

<ins>NOTE :</ins>
- _The main source file is located in the 'src' directory._
- _The argument denotes that downloaded data will be stored in the 'data' directory._
- _Don't forget to add the ending '/' in the argument. (e.g. 'data/' is valid; but 'data' is not)_
- _If the variable `webdata_directory=""`, then the application directory will be used._
<br>

`url="SOME_WEBSITE_ADDRESS"` <br>
`sorted_contents_directory="$webdata_directory"` <br>
`sorted_contents_filename="stuff"` <br>

`startClues=("Tag1" "Tag2" "Tag3")` <br>
`endClues=("Tag1" "Tag2" "Tag3")` <br><br>

<ins>NOTE :</ins>
- _Start Tags may be of the form ' ... Some Text ... <TAG> ... Some Text ... '._
- _End Tags may be of the form ' ... Some Text ... </TAG> ... Some Text ... '._
- _'Some Text' may not exist in some cases._
- _'TAG' is meant to be replaced with actual HTML tag names._
- _In some cases, simply text may be used instead of tags._
- _All this depends on the required contents and their placement in the webpage soruce file_
<br>

**2.  Function Calls**

`mfc_getwebdata "$url" "1" "0" "1" "1" "0" "0" "$sorted_contents_directory" \ `<br>
`"$sorted_contents_filename" "${startClues[@]}" "${endClues[@]}"`

To obtain result : `$mfc_getwebdata_success` <br>
_OR_ <br>
Read the file `mfc_getwebdata_success.txt` in the directory named in `$webdata_directory` <br>
_[ If '1', it implies Success; if '0', it implies Failure. ]_<br><br>

`mfc_removetags "$sorted_contents_directory" "$sorted_contents_filename" "0" "0" ` <br>

To obtain result : `$mfc_removetags_success` <br>
_OR_ <br>
Read the file `mfc_removetags_success.txt` in the directory named in `$webdata_directory` <br>
_[ If '1', it implies Success; if '0', it implies Failure. ]_<br><br>

To know how old the file is : `$mfc_time`, `$mfc_time_code` and `$mfc_time_text` <br>
_OR_ <br>
Read the file `mfc_time.txt`, `mfc_time_code.txt` and `mfc_time_text.txt` in the directory <br>
named in `$webdata_directory` <br><br>
`$mfc_time` contains the time in seconds in numerical format. <br><br>
`$mfc_time_code` contains the time in the following format : <br>
<pre>Xs, Xmin, Xh, Xd, or Xm.</pre>
Where, 'X' is a number and : <br>
<pre>
s   =>  seconds
min =>  minutes
h   =>  hours
d   =>  days
m   =>  months
</pre> <br>
`$mfc_time_text` contains the time in the following format : <br>
<pre>X second(s), X minute(s), X hours(s), X day(s), or X month(s).</pre>
Where, 'X' is a number. <br><br>

<ins>NOTE :</ins>
- _Read the resultant files and variables immediately after calling the functions._

<br><br>
### For any other queries :

<ins>Email me on :</ins>
- _Github_
- _carlo.melwyn@outlook.com_

