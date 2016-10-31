# A step by step guide of setting up and running Dockerific ELK using Ubuntu 14.04 LTS on VirtualBox, part 2

## Some maintenance work

Once the installer restarts the guest machine, Ubuntu will load and you will be presented with the login prompt. Enter the username `rex` and password `testing` to log in. First, let’s check if we are connected to the internet:

```sh
rex@beatrice:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:3b:65:98 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe3b:6598/64 scope link 
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:ce:7d:eb:50 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 scope global docker0
       valid_lft forever preferred_lft forever
rex@beatrice:~$ ping -c 3 www.google.com
PING www.google.com (216.58.214.196) 56(84) bytes of data.
64 bytes from bud02s23-in-f4.1e100.net (216.58.214.196): icmp_seq=1 ttl=63 time=15.4 ms
64 bytes from bud02s23-in-f4.1e100.net (216.58.214.196): icmp_seq=2 ttl=63 time=15.2 ms
64 bytes from bud02s23-in-f4.1e100.net (216.58.214.196): icmp_seq=3 ttl=63 time=15.9 ms

--- www.google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 15.223/15.519/15.903/0.302 ms
```

I discovered in the `inet` part of `eth0` that the address to this machine is 10.0.2.15, and pinging Google’s servers with 3 ICMP Echo requests was successful, so that means we have internet connectivity. So far, so good. Let’s update the packages, and clean up the cache:

```sh
rex@beatrice:~$ sudo apt-get update && sudo apt-get upgrade -y
rex@beatrice:~$ sudo apt-get clean
rex@beatrice:~$ df -h
```

The df utility showed me that the system drive /dev/sda1 uses 1.2 GB, and has 4.4 GB free, which is great, we’ll have enough space for Docker and the images.

## Using OpenSSH to connect to and work with the guest system

I wanted to play with the machine from the comfort of my terminal emulator by logging into it using OpenSSH, but nope, it refused cooperation. Why?

VirtualBox created a NAT internal network shared between any running virtual machines, but it does not let you access the machine from outside that network. Luckily, we can alleviate the issue by using [port forwarding](http://unix.stackexchange.com/a/146028). Configure it clicking Devices > Network > Network settings... in the VirtualBox’s menu bar, and in the window that appears click Advanced and then click Port forwarding.

![VirtualBox Network Adapter 1 Window](images/08.png?raw=true)

Click the little green plus button in the upper right part of the window. A new rule will be created.

![VirtualBox Port Forwarding Rules Window](images/09.png?raw=true)

In Name, write anything you want to call this rule. Protocol should be TCP, for Host IP we’ll put `127.0.0.1` (local loopback address), so that we can access the guest machine from the host machine. For Host Port I’ve chosen `4286`, because I already have an OpenSSH daemon running on the host machine, and they cannot use the same ports, so to avoid conflicts I’ve chosen [a port](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers) that is not officially used by any other protocol or software.

In Guest IP type in the address we’ve discovered from the `ip a` command, `10.0.2.15`. That is the address of the guest machine on the NAT virtual network. The Guest Port is the port of the OpenSSH daemon, which is `22` by default. Click OK and we’re done.

Now, open your terminal emulator on the host computer, and access the guest computer using SSH:

```sh
$ ssh rex@localhost -p 4286
The authenticity of host '[localhost]:4286 ([127.0.0.1]:4286)' can't be established.
ECDSA key fingerprint is SHA256:Hbtz8qgqKsDC8Tm7Jd+Jslp/tJC5FM7FNNLqm/AGUAU.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[localhost]:4286' (ECDSA) to the list of known hosts.
rex@localhost's password: 
Welcome to Ubuntu 14.04.5 LTS (GNU/Linux 4.4.0-31-generic x86_64)

 * Documentation:  https://help.ubuntu.com/

  System information as of Sat Oct 29 14:42:29 CEST 2016

  System load: 0.0               Memory usage: 3%   Processes:       120
  Usage of /:  19.2% of 5.78GB   Swap usage:   0%   Users logged in: 0

  Graph this data and manage this system at:
    https://landscape.canonical.com/

New release '16.04.1 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Your Hardware Enablement Stack (HWE) is supported until April 2019.
Last login: Sat Oct 29 14:17:09 2016 from localhost
rex@beatrice:~$ 
```

Such success, much happy, wow. :dog2: :grin:
Now that our base system is ready, we can continue working from the SSH session.

## Installing and configuring Docker Engine

Let’s find Docker in the Ubuntu’s repositories:

```sh
rex@beatrice:~$ apt-cache search docker
pidgin - graphical multi-protocol instant messaging client for X
docker - System tray for KDE3/GNOME2 docklet applications
karbon - vector graphics application for the Calligra Suite
kdocker - lets you dock any application into the system tray
docker.io - Linux container runtime
golang-docker-dev - Externally reusable Go packages included with Docker
vim-syntax-docker - Docker container engine - Vim highlighting syntax files
```

Obviously, the name of the package is docker.io. What about its version?

```sh
rex@beatrice:~$ apt-cache policy docker.io | grep Candidate
  Candidate: 1.6.2~dfsg1-1ubuntu4~14.04.1
```

Current version of Docker is 1.12.3, but Ubuntu’s repositories hold an older version. We will refer to the [official Docker's documentation](https://docs.docker.com/engine/installation/linux/ubuntulinux/) for installing Docker on Ubuntu and obtain the latest version.

But first, the prerequisites must be satisfied. Is our Ubuntu version supported? Yes, it’s Ubuntu Trusty 14.04 (LTS), which Docker supports fully. Is our Linux kernel’s version 3.10 or later? Let’s check:

```sh
rex@beatrice:~$ uname -r
4.4.0-31-generic
```

Great, all the conditions to install Docker are satisfied. We can start with the installation by updating out `apt` sources and installing the prerequisites:

```sh
rex@beatrice:~$ sudo apt-get update && sudo apt-get install apt-transport-https ca-certificates
--- LOTS OF RANDOM GIBBERISH OF DOWNLOADING PACKAGE LISTS ---
Fetched 4856 kB in 5s (938 kB/s)           
Reading package lists... Done
Reading package lists... Done
Building dependency tree       
Reading state information... Done
apt-transport-https is already the newest version.
ca-certificates is already the newest version.
0 upgraded, 0 newly installed, 0 to remove and 3 not upgraded.
```

They are already installed by default. Now we add the `apt` GPG key and a list to the Docker's `apt` repository:

```sh
rex@beatrice:~$ sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
rex@beatrice:~$ echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
deb https://apt.dockerproject.org/repo ubuntu-trusty main
```

Now let’s update the package lists and check where is Docker pulled from:

```sh
rex@beatrice:~$ sudo apt-get update
rex@beatrice:~$ apt-cache policy docker-engine
docker-engine:
  Installed: (none)
  Candidate: 1.12.3-0~trusty
  Version table:
     1.12.3-0~trusty 0
        500 https://apt.dockerproject.org/repo/ ubuntu-trusty/main amd64 Packages
--- OUTPUT TRUNCATED ---
```

We can see that it pulls the newest versions of Docker from the Docker project’s server, which is what we need, and we can see that the latest version is available. Now we can install the recommended packages and Docker:

```sh
rex@beatrice:~$ sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
rex@beatrice:~$ sudo apt-get install -y docker-engine
```

After this is done, we can check if Docker is up and working well:

```sh
rex@beatrice:~$ sudo docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
c04b14da8d14: Pull complete 
Digest: sha256:0256e8a36e2070f7bf2d0b0763dbabdd67798512411de4cdcf9431a1feb60fd9
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker Hub account:
 https://hub.docker.com

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/
```

Success! Docker is up and running! Now, let’s make our lives easier by adding the user `rex` in the `docker` group, so we can use Docker without issuing sudo every time:

```sh
rex@beatrice:~$ sudo groupadd docker
groupadd: group 'docker' already exists
rex@beatrice:~$ sudo usermod -aG docker rex
rex@beatrice:~$ logout
```

Changing the groups requires that we log out and log in again. Connect again to the guest machine and check if `rex` is part of the group and that Docker works without sudo:

```sh
rex@beatrice:~$ groups rex
rex : rex adm cdrom sudo dip plugdev lpadmin sambashare docker
rex@beatrice:~$ docker run hello-world

Hello from Docker!
--- OUTPUT TRUNCATED ---
```

Docker is ready to use, congratulations! :grin:

### Installing Docker Compose

We want to implement Elasticsearch, Logstash, and Kibana as separate containers that run at the same time. Instead of issuing separate commands for starting each Docker container separately, we can simplify their deployment using [Docker Compose](https://docs.docker.com/compose/overview/).

Each service is defined in a separate Dockerfile in its own directoriy, containing their configuration files. The Compose file will use their Dockerfiles to start all three services at once. Docker Composer will also handle the linking of volumes, creation persistent storage, and creation of a Docker network where our three services will communicate.

We will use the [Docker Compose documentation](https://docs.docker.com/compose/install/) as our guide to install the latest version, 1.8.1. Do this as superuser (`sudo curl` did not work):

```sh
rex@beatrice:~$ sudo su
[sudo] password for rex: 
root@beatrice:/home/rex# curl -L https://github.com/docker/compose/releases/download/1.8.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   600    0   600    0     0    731      0 --:--:-- --:--:-- --:--:--   730
100 7798k  100 7798k    0     0   894k      0  0:00:08  0:00:08 --:--:-- 1356k
root@beatrice:/home/rex# chmod +x /usr/local/bin/docker-compose
root@beatrice:/home/rex# ls -l /usr/local/bin/docker-compose 
-rwxr-xr-x 1 root root 7986086 Oct 29 19:17 /usr/local/bin/docker-compose
```

Let’s check if Docker Compose works and exit the root shell:

```sh
root@beatrice:/home/rex# docker-compose --version
docker-compose version 1.8.1, build 878cff1
root@beatrice:/home/rex# exit
exit
rex@beatrice:~$
```

Docker Compose works and is ready for use.

Using [Curator's documentation](https://www.elastic.co/guide/en/elasticsearch/client/curator/current/apt-repository.html), we will install Curator for managing Elasticsearch's indices:

```sh
rex@beatrice:~$ wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
rex@beatrice:~$ echo "deb http://packages.elastic.co/curator/4/debian stable main" | sudo tee /etc/apt/sources.list.d/curator.list
deb http://packages.elastic.co/curator/4/debian stable main
rex@beatrice:~$ sudo apt-get update && sudo apt-get install -y elasticsearch-curator
rex@beatrice:~$ curator --version
curator, version 4.1.2
```

Everything is ready for starting using the Dockerific ELK stack! Let's go [next](setting_up_ubuntu_1404lts_virtualbox_part_03.md).
