# MFC_Linux_File_Explorer

<br>
A Bash Script Library that acts as a Dialog based File Explorer on a Linux Command Terminal (CUI).

<br><br>
### This repository contains 4 MAIN files :
<pre>
1.  mfc_linux_fileexplorer.sh                 =>  Main Source (Library) File
2.  *headerdesign.sh                          =>  Supplementary Library File
3.  fileexplorer_demo_1.sh                    =>  Demo 1 File
4.  fileexplorer_demo_2.sh                    =>  Demo 2 File
5.  mfc_linux_fileexplorer_demo_output.txt    =>  Youtube links to the outputs of Demos 1 and 2

* REF - https://github.com/melwyncarlo/Bash_Header_Design
  For Designing CUI-based Heading Banners
</pre>

<br><br>
### The source library contains 1 MAIN function. <br>Given below is a sample function call and descriptive lists of arguments :

**1.  Including the Main Source File in Demo Script Files and Function Call**

`start_directory="/"`
`root_access="0"`

`gnome-terminal --title="MFC Linux File Explorer" -- bash -c \
'source src/mfc_linux_fileexplorer.sh 24 80 37 150; mfc_fileexplore "$start_directory" "0" "0" "0" "0" "0" "1" "1" "load" "$root_access"'`

<ins>NOTE :</ins>
- _The main source file is located in the 'src' directory._
- _All temporary data and result based data will be stored in the 'src/bin' directory._
- _This application is meant to be used on a separate terminal window which is temporarily allocated._
- _If the variable `start_directory=""`, then the user's 'Home' directory will be used._
- _If the variable `start_directory="/"`, it implies the 'Root' directory._
- _If the variable `root_access="0"`, then certain locked files and folders cannot be selected._
- _If the variable `root_access="1"`, then a password will be requested to access root._
- _The values `24 80 37 150` are the inputted heights and widths of the command terminal for Simple and Complete modes respectively._
- _The values `24 80 37 150` must be within the limits as prescribed at the top of the main source file._
<br>

**2.  List of Arguments**

<pre>
mfc_fileexplore       -->   Parameter 1 - Start Directory
                            Parameter 2 - Complete Mode Options Mode
                            Parameter 3 - Complete Mode
                            Parameter 4 - Show Hidden Files Options Mode
                            Parameter 5 - Show Hidden Files Mode
                            Parameter 6 - Show Only ... Options Mode
                            Parameter 7 - Show Only ... Mode ( 1 => Files; 2 => Folders; 3 => Both )
                            Parameter 8 - Allow Multiple Selection Mode
                            Parameter 9 - File Explorer Action Text
                            Parameter 10 - Root Access Mode
</pre>

<ins>NOTE :</ins>
- _Unless otherwise stated, in mode arguments, an input value of 1 is ON, and 0 is OFF._
- _Simple Mode is a smaller version with less visible details, whereas Complete Mode includes all details and is larger._
- _Options Mode implies whether the relevant options are to be made available for the user to switch._
- _If Parameter 8 is OFF, then only one file can be selected per dialog session._
- _If Parameter 8 is ON, then multiple files (within a particular folder) can be selected per dialog session._


<br><br>
### For any other queries :

<ins>Email me on :</ins>
- _Github_
- _carlo.melwyn@outlook.com_

