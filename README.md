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
