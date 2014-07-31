::
:: Description
:: Windows batch file to create a 7-Zip archive of the holidayHomesImporter solution
::
:: Notes
:: Requires 7-Zip, in particular the 7z.exe command line executable
:: Make sure that the PATH environment variable includes the folder containing the 7z.exe command line executable
::
:: Alternative batch code short year %yy:~2,2%
::
:: History
:: 21/07/2014  TW  New
:: 31/07/2014  TW  * instead of *.* wildcard includes empty folders too (Unix style)
::

@ECHO OFF

:: Save to _holidayHomesImporter.7z file

REM del _holidayHomesImporter.7z
REM "C:\Program Files\7-Zip\7z.exe" a -r -t7z -x@_holidayHomesImporter_zip_exclude.txt _holidayHomesImporter.7z *

:: Save to datestamped filename (1)

REM set SAVEFILE=%DATE%@%TIME%
REM set SAVEFILE=%SAVEFILE:/=-%
REM set SAVEFILE=%SAVEFILE::=-%
REM set SAVEFILE=%SAVEFILE:.=-%
REM set SAVEFILE=%SAVEFILE: =%_holidayHomesImporter.7z
REM echo %SAVEFILE%
REM "C:\Program Files\7-Zip\7z.exe" a -r -t7z -x@_holidayHomesImporter_zip_exclude.txt %SAVEFILE% *

:: Save to datestamped filename (2)

call "batch\_SetDateTimeComponents.cmd" > nul
set SAVEFILE=%yy%-%mm%-%dd%_holidayHomesImporter(Tim).7z
"C:\Program Files\7-Zip\7z.exe" a -r -t7z -x@_holidayHomesImporter_zip_exclude.txt %SAVEFILE% *