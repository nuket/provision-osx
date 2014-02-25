provision-osx
=============

A batch file to provision OS X as a virtual machine host.

The goal is to disable as many services as possible, while leaving the system usable and stable. There are a lot of services that only make sense in the desktop use-case, but don't make as much sense in a server use-case.

Current numbers show memory usage without anyone logged in around "PhysMem: 1150M used (606M wired), 7040M unused." But I think this number could go even lower.


secure-vbox-rdp
===============

A script to set up VirtualBox using TLS cryptography to secure the link.

Adds a user and a password to the specified Virtual Machine.

To log in using Microsoft Remote Desktop Connection, you have to make sure you specify the username and password before attempting to connect, and save these credentials.


backup and backup-settings
==========================

A pair of scripts to back up VirtualBox virtual machines, by saving the current machine state (i.e. stopping the machines), then using Duplicity to send the current disk images and saved state to a backup system.

backup-single
=============

An improved script to back up individual VirtualBox machines. It saves the current machine state, uses Duplicity to send the disk images to a backup system, then optionally restarts the VirtualBox machines. 

Set it up by editing the `backup-settings.sh` file, making sure to set `SFTP_TARGET`, `PASSPHRASE`, `FTP_PASSWORD`, and `MAILTO`.

To use the script regularly, you just add something like the following to your `crontab` file:

    MAILTO=user@host
    
    # Start and Power Cycle this VM after backing it up.
    @weekly     $HOME/backup-single.sh -n "Some Machine"       -R &> $HOME/backup.log
    
    # Baseline VM (this doesn't change much), back it up, but do not Start it.
    30 22 * * * $HOME/backup-single.sh -n "Ubuntu 12.04.3"     -N &> $HOME/backup.log
    
    # Derived  VMs (these change constantly), once it's backed up, Start it again.
    0   0 * * * $HOME/backup-single.sh -n "Precise Machine"       &> $HOME/backup.log

Once `backup-single.sh` completes, it mails the log file to the `MAILTO` address. The log output looks something like:

    Exporting extra path.
    Exporting sftp target.
    Exporting passwords.
    Exporting reporting address.
    Backing up single VM: Some Machine
    Reset the VM after starting it again.
    Sleep the virtual machine: Some Machine
    vboxmanage controlvm "Some Machine" savestate
    0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
    Run backup: "/Users/user/VirtualBox VMs/Others/Some Machine" "sftp://user@host/VMs/Some Machine"
    Local and Remote metadata are synchronized, no sync needed.
    Last full backup date: Tue Feb 25 07:12:29 2014
    No old backup sets found, nothing deleted.
    Local and Remote metadata are synchronized, no sync needed.
    Last full backup date: Tue Feb 25 07:12:29 2014
    --------------[ Backup Statistics ]--------------
    StartTime 1393334744.89 (Tue Feb 25 07:25:44 2014)
    EndTime 1393334790.12 (Tue Feb 25 07:26:30 2014)
    ElapsedTime 45.23 (45.23 seconds)
    SourceFiles 11
    SourceFileSize 2531726484 (2.36 GB)
    NewFiles 4
    NewFileSize 101843900 (97.1 MB)
    DeletedFiles 1
    ChangedFiles 7
    ChangedFileSize 2429882584 (2.26 GB)
    ChangedDeltaSize 0 (0 bytes)
    DeltaEntries 12
    RawDeltaSize 107086570 (102 MB)
    TotalDestinationSizeChange 74829172 (71.4 MB)
    Errors 0
    -------------------------------------------------
    
    Wake the virtual machine: Some Machine
    vboxmanage startvm "Some Machine" --type headless
    Waiting for VM "Some Machine" to power on...
    VM "Some Machine" has been successfully started.
    Reset the restarted VM.
    Mail backup logs.
