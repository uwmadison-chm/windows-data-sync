# windows-data-sync

The tools you need to sync data from a Windows computer to a linux server

## The problem

You have data. It's on a Windows computer. You want to upload it to a linux server that stores all your data. You need to upload the data via SSH. Maybe you even want to upload things to a read-only raw-data directory. These tools can help.

TODO: Add content

## What we have here

TODO: Add content

## Example commands

```rsync -rv --rsync-path="sudo -u mystudy-upload /bin/rsync" <source_path> <destination_path>```

```rsync -rv -e "./cygnative.exe plink.exe" --rsync-path="sudo -u mystudy-upload /bin/rsync" <source_path> <destination_path>```