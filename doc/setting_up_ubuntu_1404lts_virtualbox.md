# Setting up and running Dockerific ELK using Ubuntu 14.04 LTS on VirtualBox

This assignment consists of setting up a virtual (guest) machine running Ubuntu Server 14.04 and Docker, and running the ELK stack (Elasticsearch, Logstash, Kibana) as separate Docker containers within. The result is an ELK stack running in the virtual machine, parsing the syslog, and displaying the data in Kibana.

The included maintenance scripts will provide automatic management of the Elasticsearch indices and their backups, and will also monitor free disk space and warn the user if the machine's drives become nearly full by e-mail or `syslog`.

## Prerequisites

To set up and prepare the server before installing the Dockerific ELK stack, we need:

* [VirtualBox](https://www.virtualbox.org/wiki/Linux_Downloads) virtualization environment,
* [Ubuntu Server 14.04.5 Trusty Tahr](http://releases.ubuntu.com/14.04.5/) ISO image and SHA256 hash file.

After we set up the basic configuration, we will need:

* a working internet connection, preferably broadband, since Docker will pull lots of images,
* latest [Docker Engine](https://docs.docker.com/engine/installation/) installed (tested on 1.12.3),
* latest [Docker Compose](https://docs.docker.com/compose/install/) installed (tested on 1.8.1),
* latest [Curator](https://www.elastic.co/guide/en/elasticsearch/client/curator/current/apt-repository.html) installed,

## Setting up the virtual machine with Ubuntu

### Installing VirtualBox and getting the Ubuntu Server ISO file

Run the following commands on the host machine as an ordinary user, not superuser (`root`). Provide your password to `sudo` whenever asked. My host and guest computer’s user name is `rex`, please replace them with your user names appropriately, and don't forget to modify the scripts in `maintenance` when you pull the project's directory from Github!

The login details for the guest machine are: user name: **rex**, password: **testing**. The working path is your home directory `~/`. To make sure you are in the right place, open up your terminal emulator and type `cd ~`.

Now, let's begin by installing VirtualBox:

```sh
$ sudo apt-get update && sudo apt-get install -y virtualbox
```

The `apt` package manager will update the package lists, pull all the necessary packages and install the latest VirtualBox package available on your host machine. Check if the installation was successful:

```sh
$ VBoxManage --version
5.0.24_Ubuntur108355
```

Here we see that VirtualBox is successfully installed, with version 5.0.24 being present. Next, we download the Ubuntu Server 14.04.5 ISO image and check its SHA256 hash. We use the hash to check if the ISO file was downloaded correctly and that is it untampered:

```sh
$ wget http://releases.ubuntu.com/14.04.5/ubuntu-14.04.5-server-amd64.iso
$ wget http://releases.ubuntu.com/14.04.5/SHA256SUMS
$ sha256sum -c SHA256SUMS 2>&1 | grep OK
ubuntu-14.04.5-server-amd64.iso: OK
```

The last line should say OK, which means the file is good. If it doesn't say OK, download it once again.

### Installing the VirtualBox Extension Pack

The following step is optional, but recommended. In case you wish to connect USB devices to the guest machine, such as USB external drives, you will need to install the Extension Pack and add the user to the `vboxusers` group. Run these commands and provide your password:

```sh
$ wget http://download.virtualbox.org/virtualbox/5.0.26/Oracle_VM_VirtualBox_Extension_Pack-5.0.26-108824.vbox-extpack
$ sudo VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-5.0.26-108824.vbox-extpack 
[sudo] password for rex: 
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
Successfully installed "Oracle VM VirtualBox Extension Pack".
$ VBoxManage list extpacks
Extension Packs: 2
Pack no. 0:   VNC
Version:      5.0.24
Revision:     108355
Edition:      
Description:  VNC plugin module
VRDE Module:  VBoxVNC
Usable:       true 
Why unusable: 

Pack no. 1:   Oracle VM VirtualBox Extension Pack
Version:      5.0.26
Revision:     108824
Edition:      
Description:  USB 2.0 and USB 3.0 Host Controller, Host Webcam, VirtualBox RDP, PXE ROM, Disk Encryption.
VRDE Module:  VBoxVRDP
Usable:       true 
Why unusable: 
```

Notice the pack number 1 - that is the one we need. It is successfully installed and usable. Now we add the user to the vboxusers group and remove the downloaded file, we will not need it anymore:

```sh
$ sudo usermod -a -G vboxusers rex
$ groups rex
rex : rex adm cdrom sudo dip plugdev lpadmin sambashare docker vboxusers
$ rm Oracle_VM_VirtualBox_Extension_Pack-5.0.26-108824.vbox-extpack 
```

Notice in the output of the `groups` command that the user `rex` is part of the group `vboxusers`. That will give us the permissions to connect USB devices to the guest system.

Now we’re ready to rock. :grin:

### Starting VirtualBox and creating the virtual (guest) machine

Using your desktop environment, find the VirtualBox in the applications list and click its icon to open it. You will be presented with the main VirtualBox window:

![VirtualBox Main Window](images/01.png?raw=true)

We will create a new virtual machine and start it. Click the New button, a new window will appear, then click Expert Mode.
