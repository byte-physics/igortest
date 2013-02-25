@echo off
set IgorPath="%PROGRAMFILES(x86)%\WaveMetrics\Igor Pro Folder\Igor.exe"
set StateFile="DO_AUTORUN.TXT"

if exist %IgorPath% goto foundIgor
echo Igor Pro could not be found in %IgorPath%, please adjust the variable IgorPath in the script
goto done

:foundIgor

if "%1" NEQ "" goto hasArgument
echo Missing experiment file
goto done

:hasArgument

echo "" > %StateFile%
%IgorPath% /I "%1"
del %StateFile%

:done

