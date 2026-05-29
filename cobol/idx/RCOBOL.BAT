rem Micro Focus Example batch file for
rem Linked-in Shared Run-Time Library (RCOBOL.LIB)
rem The parameter (%1) is the rootname of the last
rem compiled program. The EXE filename defaults to
rem the name of the first specified object file.
link %1/m,,,RCOBOL.LIB;
