# windows-data-sync

The stuff you need to upload data from a Windows computer to a linux server

## The problem

Your data is on a Windows computer. You want to securely upload it to a linux server that stores all the data for your study. Maybe you even want to upload things to a read-only raw data directory. These tools can help.

## What we have here

This repository contains the Windows .exe and .dll files for:

* Cygwin's build of [rsync](https://rsync.samba.org/) (To transfer files)
* Cygwin's build of [openssh](https://www.openssh.com/) (To connect to your linux server)
* plink from [PuTTY](https://putty.org/) (Another way to connect to your server)
* A little wrapper called [cygnative](http://diario.beerensalat.info/2009/08/18/new_cygnative_version_1_2_for_rsync_plink.html) that somehow makes it so rsync and plink will work together.
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

```rsync -rv --rsync-path="sudo -u upload_user /bin/rsync" /cygdrive/c/data/DataSet1/ username@example.com:/data/dataset1```

#### "Wait, why would I want to do this?"

Raw data is important. If you can't trust that your raw data hasn't changed, you can't trust your processed data either. One way to make sure your raw data hasn't changed is to put it somewhere that you _can't_ change it.

"Hey, smart guy," you say, "If I can't change the data, how can I upload it in the first place?"

Good question. And the answer is: Use a program called `sudo` to upload it as another user to upload it in a place where you can't normally write. This can't totally prevent you from changing your raw data, but it'll stop people from doing it accidentally.

#### The setup

This is going to get into the weeds of linux permissions, accounts, and groups. Be prepared.

On the server, you'll need:

* Your user account (I'll call this `my_user`)
* A user account just for uploading raw data (`upload_user`)
* A group for people who can upload raw data (`upload_group`)
* A group for poeple who can read the data (`data_group`)
* A raw data directory on the server (`/data/dataset1`)

Now, you'll need to set things up so everyone in `data_group` can read the data, but only `upload_user` can write the data:

```
# You'll need to do these steps as the root user
# It may make sense to do this in a scheduled task to make sure nothing funny
# creeps in there
# Set ownership and group
chown -R raw_data_user:data_group /data/dataset1
# This changes all the directories to be writable by raw_data_user, readable by
# data_group, and makes sure all new files and directories are group-owned by
# data_group
find /data/dataset1 -type d -exec chmod 2750 {} \;
# Make sure the owner can read and write files, group can read, others can't see
find /data/dataset1 -type f -exec chmod u+rw,g+r-w,o= {} \;
```

You'll also need to set up an entry in your `sudoers` file (probably `/etc/sudoers` or `/etc/sudoers.d`) that lets people in `upload_group` use `sudo` to become `upload_user` without entering a password:

```
%upload_group ALL=(upload_user) NOPASSWD: ALL
```

If you'd like to make things more secure, you can set things so the only thing that works this way is `rsync`:

```
%upload_group ALL=(upload_user) NOPASSWD: /bin/rsync
```

You can that things are setup correctly by running `sudo -u upload_user /bin/rsync --help` — if all is well, you'll get the help page for `rsync` without entering a password.

#### Whew! Now back to that upload command:

```rsync -rv --rsync-path="sudo -u upload_user /bin/rsync" /cygdrive/c/data/DataSet1/ username@example.com:/data/dataset1```

The important part here is the `--rsync-path="sudo -u upload_user /bin/rsync"` part, which tells your copy of rsync "after connecting, instead of just running rsync on the server, use `sudo` to run `/bin/rsync` as `upload_user`.

Try it out, and it should upload your data to the server, and everything should be owned by `upload_user` and not writable by your normal user account.

#### "Can I combine the `sudo` thing with the `plink` thing from earlier?

You sure can. That's what we're doing.

#### What about permissions?

When uploading from windows, you may very well want to set permissions explicitly while uploading. You can use something like:

```rsync --perms --chmod=F0644,D2755 ...```

to set permissions to whatever you need — in this case, we'd be setting files to be read/write by the owner, readable by group and world, and directories to be read/write/list by the owner, read/list for group and world. In addition, new files and directories will be created with the parent's group.

#### "sudoers files are super confusing and the documentation is worse. Help!"

See this [better guide to sudo](http://toroid.org/sudoers-syntax).

## Wrapper scripts

If you need to upload data from a lot of computers and studies, you'll probably want to use a wrapper script so you don't need these complicated command lines in files all over the place. Check out the [examples](https://github.com/uwmadison-chm/windows-data-sync/tree/master/examples) for scripts you can modify and re-use across your studies. They're written in the [MS-DOS batch](https://www.dostips.com/) language so they're a little gnarly, but they'll run on any Windows machine.

## Questions?

Feel free to [file an issue](https://github.com/uwmadison-chm/windows-data-sync/issues) and I'll try and provide whatever help I can. You can also ask this sort of question on [SuperUser](https://superuser.com/) where people have far, far more expertise on this sort of thing than I do.

## Thanks!

I am indebted to the creators of some wonderful tools: **[rsync](https://rsync.samba.org/)** (which can solve a dizzying array of file management challenges), **[openssh](https://www.openssh.com/)** (upon which the security of modern networks is built), and the superlative **[PuTTY](https://putty.org/)** (which is one of the most-useful and best-built Windows programs there is).

Also many thanks to our system administrator, David Thompson, who worked tirelessly to help figure this out and test everything with me.
