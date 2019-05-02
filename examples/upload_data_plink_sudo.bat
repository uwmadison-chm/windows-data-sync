@echo off

REM Uses rsync to upload data from the local machine to a unix host
REM src can be either Windows (C:\...) or cygwin (/cygdrive/c/...) paths

REM Relies on the variables:
REM UPLOAD_HOST (the host you'll connect to)
REM CONNECT_USER (the user you'll connect as, probably %USERNAME%)
REM DATA_USER (the user you'll switch to who can write to the upload location)

REM In this example, after connecting to the server as CONNECT_USER, it
REM immediatley uses sudo to switch to DATA_USER to run rsync. This needs to be
REM a 'NOPASSWD' sudo. This happens by (ab)using the --rsync-path option to
REM rsync, which tells the local rsync how to run rsync on the remote server.

SETLOCAL
set upload_user=%2
set src=%1
set dest=%2
set connect_user=%USERNAME%

REM Convert paths like "C:\Windows\Path" to "/cygrdrive/c/Windows/Path"
REM which rsync needs. Yes this command is insane, batch is generally insane
for /F "tokens=* USEBACKQ" %%F IN (`cygpath %src%`) DO (set cyg_src=%%F)

echo Uploading %src% to %dest%

set rsync_cmd=rsync -rv --size-only -e "./cygnative ./plink" --rsync-path="sudo -u %DATA_USER% /bin/rsync" "%cyg_src%" %CONNECT_USER%@%UPLOAD_HOST%:"%dest%"
echo %rsync_cmd%
%rsync_cmd%

ENDLOCAL