rem Micro Focus Example batch file for
rem Linked-in Run-Time Library (LCOBOL.LIB)
rem You may edit this file
rem Insert your own Object Libraries before LCOBOL.LIB
rem The parameter (%1) is a list of object files to link,
rem each separated by a plus ("+") with no spaces.
rem The name of the EXE file is defaulted to be the name
rem of the first specified object file.
link %1,,,LCOBOL.LIB;
