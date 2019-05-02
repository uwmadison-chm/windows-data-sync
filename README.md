# windows-data-sync

The stuff you need to sync data from a Windows computer to a linux server

## The problem

You have data. It's on a Windows computer. You want to upload it to a linux server that stores all the data for your study. You need to upload the data via SSH. Maybe you even want to upload things to a read-only raw data directory. These tools can help.

## What we have here

This repository contains the Windows .exe and .dll files for:

* Cygwin's build of [openssh](https://www.openssh.com/)
* Cygwin's build of [rsync](https://rsync.samba.org/)
* plink from [PuTTY](https://putty.org/)
* A little wrapper called [cygnative](http://diario.beerensalat.info/2009/08/18/new_cygnative_version_1_2_for_rsync_plink.html) that somehow makes it so rsync and plink can be friends.
* Some cleaned-up and probably useful example scripts in `/examples`

These tools should be enough to get your data up and happy on a server. Let see some examples of how they work:

### rsync and openssh (the simplest setup)

```rsync -rv /cygdrive/c/data/DataSet1/ username@example.com:/data/dataset1```

This should automatically use the bundled `ssh.exe` to connect as `username` to `example.com` and upload data from `c:\data\DataSet1` to `/data/dataset1.` Things to note:

* You need to change Windows-style paths (`C:\data`) to cygwin-style paths (`/cgydrive/c/data`)
* You'll be prompted for a password unless you have SSH keys set up, which is a pain with cygwin (and a bad idea if you share logins on a machine)
* The trailing `/` for the source path tells rsync not to create `/data/dataset1/DataSet1`, but rather to copy its contents.
* [rsync has a million options.](https://linux.die.net/man/1/rsync) `-rv` says to be recursive and verbose, so it copies all files and directories from the source and tells us about each one.

### rsync with plink (for passwordless login)

```rsync -rv -e "./cygnative ./plink" /cygdrive/c/data/DataSet1/ username@example.com:/data/dataset1```

If you're lucky (or hard-working) enough to have your Windows computers and linux computers both connected to the same authentication system [using Active Directory and Kerberos](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/windows_integration_guide/introduction), you can use plink (from the excellent package [PuTTY](https://putty.org/)) to connect without a password.

* The magic here is `-e ./cygnative ./plink` which tells rsync to use plink (via cygnative) to connect to the server.

### rsync with sudo (to store data as a different user than you log in as)

```rsync -rv --size-only -e "./cygnative ./plink" --rsync-path="sudo -u data-user /bin/rsync" /cygdrive/c/data/DataSet1/ username@example.com:/data/dataset1```

In this case, the `--rsync-path` option tells