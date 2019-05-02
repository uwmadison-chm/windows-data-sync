@echo off

REM This example script is most like what you'll probably want to run.
REM It usees one of the 'upload_data...' batch files so you don't need to have
REM a whole ton of weird batch script in all your data upload scripts.

REM Set variables required by upload script
REM %USERNAME% is set by Windows and is probably right if you're connecting to
REM a Windows server environment as well

set UPLOAD_HOST=example.com
set CONNECT_USER=%USERNAME%
set DATA_USER=upload-user

REM You'll want to make sure your SSH host keys for PuTTY are set up and saved
REM to a .reg file (I'll call it 'hostkeys.reg')
reg

REM Head to the place where all the .exe and .dll files from this repository
REM are stored
pushd c:\path\to\upload_stuff

call upload_data_plink_sudo C:\dataset1\ /data/dataset1
call upload_data_plink_sudo C:\dataset2\ /data/dataset2

popd