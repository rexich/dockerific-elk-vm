# A step by step guide of setting up and running Dockerific ELK using Ubuntu 14.04 LTS on VirtualBox

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

Notice in the output of the `groups` command that the user `rex` is part of the group `vboxusers`. That will give us the permissions to connect USB devices to the guest system. Log out and log back in so that this change will be accepted.

Now we’re ready to rock! :grin:

### Starting VirtualBox and creating the virtual (guest) machine

Using your desktop environment, find the VirtualBox in the applications list and click its icon to open it. You will be presented with the main VirtualBox window:

![VirtualBox Main Window](images/01.png?raw=true)

We will create a new virtual (guest) machine. Click the New button, a new window will appear, then click Expert Mode.

For Name you can write Elk, for Type choose Linux, and for Version choose Ubuntu (64-bit). In Memory size, we’ll set it to 2048 MB. Click Create.

![VirtualBox Create Virtual Machine Window](images/02.png?raw=true)

The default settings are appropriate for us (8 GB, Dynamically allocated). Click Create. The guest machine will be created, and now we need to set it up. Click it in the list and click Settings. Click System from the list on the left. Make sure that Base Memory reads 2048 MB; that will be the amount of RAM available for use by the guest machine.

![VirtualBox System Motherboard Settings Window](images/03.png?raw=true)

Click the Processor tab, and make sure Processor(s) reads 2. This will speed up execution of the software on the guest machine. You can increase this along the green bar, and it depends on the number of cores your computer's processor has.

![VirtualBox System Processor Settings Window](images/04.png?raw=true)

Next, click Storage from the list on the left, and click on Empty from the list, below Controller: IDE. You will see a small blue CD icon on the right, click it and click Choose Virtual Optical Disk File. Find the file in your home directory, click it and click Open.

![VirtualBox Storage Settings Window](images/05.png?raw=true)

Lastly, click Audio from the list on the left, and uncheck Enable Audio. It’s a server machine, we do not need audio output, and we need to preserve resources for the execution of Docker’s containers, so we will disable it. Click OK.

![VirtualBox Audio Settings Window](images/06.png?raw=true)

### Installing Ubuntu Server

Now we are ready to start with the installation of Ubuntu Server. Click the Start button from the main window (the guest machine we’ve created will be selected) and the guest machine will start booting up. The installation of Ubuntu Server will boot up and present you with the Language menu. Press Enter to choose English. Press Enter again to choose Install Ubuntu Server. The installation will continue.

![VirtualBox Ubuntu Installation Window](images/07.png?raw=true)

In the Select a language menu, choose English. The Select your location menu appears. In my case, I live in Europe, but it does not appear on the list, so I navigate to Other using the arrow keys to highlight it and press Enter to select it. Then Europe appears, I choose it and a list of countries appears. You can choose your own location and continent, of course, and that will affect the time zone used on the guest machine, which is necessary to set up the clock correctly.

Afterwards, you will see the Configure locales menu, here choose `United States-en_US.UTF-8`. Make sure you choose an **UTF-8** locale to avoid any issues with processing Unicode text.

The installer will ask you to detect the keyboard layout. Most people use a standard QWERTY layout, so unless you have an exotic keyboard layout you can simply choose No. The Configure the keyboard menu appears and allows you to choose your keyboard layout. I simply chose English (US), and on the next screen I chose English (US) again.

The installer will reticulate some splines (that is, do some work :grin: ), and then you will be presented with the option to enter the `hostname` for the guest machine, which is the name of the computer on the network. `ubuntu` is too generic and can possible conflict with other computers on the network with the same name, and sounds uninspiring as well, so we will give it another name, such as `beatrice` - computing is fun, and it can be fancy as well. :grin:

In the Set up users and passwords menu, enter your full name and press Enter, then enter the username for the system. This is very important, you will use this name to log into the system, and it **has** to be **all lowercase**. I entered `rex` and I will use it throughout this guide.

You will need to provide a  password for this username. Remember, you will use this to log in to the system. I used `testing` as a password. Enter it twice, and when it complains it’s weak, you can choose Yes to dismiss the warning.

Remember: On real production servers, use complex passwords made up of letters, numbers, and other characters, to secure your server against unauthorized access.

When asked to encrypt your home directory, choose No, since if you choose to use this, it will incur a great performance penalty, and we do not want that on our server.

Next, you will be asked about the time zone. The installer said my time zone is Europe/Belgrade, which is correct, so I chose Yes. Choosing No will let you choose the correct time zone, which is important for the time to be correct.

After some more hardware detection, the server will let you partition your hard drive. Since this will be the only operating system on the guest machine and we need to simply get it running as soon as possible, choose Guided - use the entire disk, since it will offer us sane defaults for our installation. Then, select the only disk that appears, called `sda` - the first SATA/SAS hard drive in the guest system.

What will appear is a menu for configuring the partitions of the virtual hard drive. We will accept the defaults (first: primary partition ext4 for the root system, second: extended partition for the swap) and simply choose Finish partitioning and write changes to disk. You will be asked to confirm this and write changes to disk, choose Yes.

The installer will start installing the base system and kernel, generate the `initramfs`, and then it will ask you to provide a HTTP proxy server. I do not need one, so I just pressed Enter. The `apt` packages lists will be updated, and the installer will retrieve updates and start installing the packages on the virtual hard drive.

Next, it will ask you whether to automatically install security updates. We will be limited with space, and we do not want the system to update itself while work is being done, so choose No automatic updates - we will perform updates manually on maintenance time.

In Software selection, choose to have OpenSSH server installed, because you will use it to enter the system through the network securely and do work, instead of working in the VirtualBox window. OpenSSH rules. :grin:

After this is done, it will ask you where to install the GRUB boot loader. Since it is the only operating system on the machine, we do not need to worry for dual booting with other distributions or (God forbid!) Windows, so choose Yes to install it to the Master Boot Record.

The installer will finish and tell you it is time to boot into your new system. Yes! Press Enter and your fresh new Ubuntu Server guest machine will boot up. That's it! :grin:

