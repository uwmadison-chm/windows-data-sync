@echo off

REM Uses rsync to upload data from the local machine to a unix host
REM src can be either Windows (C:\...) or cygwin (/cygdrive/c/...) paths

REM Relies on the variables:
REM CONNECT_USER (the user you'll connect as, probably %USERNAME%)
REM UPLOAD_HOST (the machine you'll be uploading to)

REM This will prompt for a password unless you have SSH key authenticaton set up

SETLOCAL
set upload_user=%2
set src=%1
set dest=%2
set connect_user=%USERNAME%

REM Convert paths like "C:\Windows\Path" to "/cygrdrive/c/Windows/Path"
REM which rsync needs. Yes this command is insane, batch is generally insane
for /F "tokens=* USEBACKQ" %%F IN (`cygpath %src%`) DO (set cyg_src=%%F)

echo Uploading %src% to %dest%

set rsync_cmd=rsync -rv "%cyg_src%" %CONNECT_USER%@%UPLOAD_HOST%:"%dest%"
echo %rsync_cmd%
%rsync_cmd%

ENDLOCAL