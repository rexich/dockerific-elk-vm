# Dockerific ELK stack

Dockerific ELK is a collection of Docker services working together, whose task is to collect logs from a host machine that emits them through rsyslog, store them and provide analysis tools.

It uses the Docker Engine and Docker Compose in order to create and run the necessary containers for the three services separately. Also provided are several maintenance scripts. It also uses Elasticsearch's Curator for periodic maintenance of the Elasticsearch's indices, and some scripts to warn the user 

It uses the official Docker images of the powerful [Elasticsearch](https://registry.hub.docker.com/_/elasticsearch/) search and analytics engine, [Logstash](https://registry.hub.docker.com/_/logstash/) to capture and forward the logs, and [Kibana](https://registry.hub.docker.com/_/kibana/) to analyze and visualize information.

Tested successfully on Ubuntu 14.04 LTS running on VirtualBox, and Ubuntu 16.04 LTS running on my laptop.

## Prerequisites

* A host or VirtualBox machine running Ubuntu 14.04 or 16.04 LTS,
* latest [Docker Engine](https://docs.docker.com/engine/installation/) installed (tested on 1.12.3),
* latest [Docker Compose](https://docs.docker.com/compose/install/) installed (tested on 1.8.1),
* 4 GiB of RAM or more,
* superuser rights for the setup script,
* rsyslog installed and configured (by default in Ubuntu).
* latest [Curator](https://www.elastic.co/guide/en/elasticsearch/client/curator/current/apt-repository.html) installed.

## Important notes

Running the setup script requires superuser (root) rights, because it adds a configuration file for rsyslog in its configuration directory, and also adds a sysctl tunable for [increasing the limit of the maximum number of memory-mapped areas](http://stackoverflow.com/a/11685165), since Elasticsearch performs more rigorous checks by default.

Running the services using the `docker.io` package found in the official Ubuntu repositories is NOT supported.

## Setup, installation, and removal

Clone (or download as ZIP) this repository to the host computer. Install Docker Engine and Docker Compose.

Run the script `maintenance/setup` on the host machine with superuser rights (using `sudo`). It will configure `rsyslog` to emit the logs to Logstash, set the necessary `sysctl` tunable for Elasticsearch, configure several `cron` scripts for maintenance tasks, and add a tool called `ls-images` that displays a pretty-printed list of all available Docker images. Run `maintenance/setup` with no arguments for more information.

## Usage

Make sure your user is in the `docker` group, otherwise prepend `sudo` to these commands. Start the Dockerific ELK stack by running:

```sh
# Run the stack and display all messages
$ docker-compose up

# or run the services detached
$ docker-compose up -d
```

in the project's directory. Give it a few seconds to start, then open `http://localhost:5601` in your favorite browser and you will see Kibana's interface, and you're ready to go. :)

Stopping the services is simple. Issue `CTRL+C` in the terminal where Dockerific ELK is running, and then:

```sh
$ docker-compose down
```

## Some helpful information

The Elasticsearch indices and data are stored in the directory `elasticsearch/data`. The included `cron` scripts will make automatic backups, warn in case of lack of free space, and run Curator to remove indices older than 30 days. All these goodies are located in the `maintenance` directory.

This project expects to be located at `/home/rex/dockerific-elk-vm`, please change the apropriate paths in the `delk-cron` file and the `delk-maintenance` script. I will make it a possibility to declare this at installation in the future, stay tuned.

For complete documentation about the process of running the Dockerific ELK stack in VirtualBox, how things work together, and how I got to succeed in making all of this possible, refer to the `doc/` directory and look at the source code of the scripts in `maintenance/`.

Well, that would be all for now. I hope it serves you well! Cheers and happy hacking! :)

Copyright © 2016 Filip Dimovski (dimfilip20@gmail.com). The scripts and files of this project's repository are subject to the GNU General Public License, version 3, unless noted otherwise.
