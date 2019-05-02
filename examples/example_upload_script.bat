@echo off

REM This example script assumes you want to use rsync for data transfer, use
REM plink to connect (so you can have Kerberos-powered login magic) and
REM use sudo to switch to a data-upload user.

REM Source data is in C:\data (or /cygdrive/c/data)
REM Destination is in /data on example.com

rsync -rv -e "./cygnative ./plink" --rsync-path="sudo -u data-upload /bin/rsync" /cygdrive/c/data/ %USERNAME%@example.com:/data
