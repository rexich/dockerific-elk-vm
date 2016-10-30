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
* Curator installed (there is a script included that will do that for you).

## Important notes

Running the setup script requires superuser (root) rights, because it adds a configuration file for rsyslog in its configuration directory, and also adds a sysctl tunable for [increasing the limit of the maximum number of memory-mapped areas](http://stackoverflow.com/a/11685165), since Elasticsearch performs more rigorous checks by default.
Running the services using the `docker.io` package found in the official Ubuntu repositories is not supported.

## Setup, installation, and removal

Clone (or download as ZIP) this repository to the host computer. Install Docker Engine and Docker Compose.
Run the script maintenance/setup.sh on the host machine with superuser rights (using `sudo`). It will configure `rsyslog` to emit the logs to Logstash, set the necessary `sysctl` tunable for Elasticsearch, configure several `cron` scripts for maintenance tasks, and add a tool called `ls-images` that displays a pretty-printed list of all available Docker images. Run `setup.sh --help` for detailed information, including removal.

## Usage

Make sure your user is in the `docker` group, otherwise prepend `sudo` to these commands. Start the Dockerific ELK stack by running:

```sh
# Run the stack and display all messages
$ docker-compose up

# or run the services detached
$ docker-compose up -d
```

in the project's directory. Give it a few seconds to start, then open `https://localhost:5601` in your favorite browser and you will see Kibana's interface, and you're ready to go. :)
Stopping it is simple. Issue `CTRL+C` in the terminal where Dockerific ELK is running, or if detached:

```sh
$ docker-compose down
```

The Elasticsearch indices and data is stored in the directory `elasticsearch/data`.

That's it. I hope it serves you well! Cheers and happy hacking! :)

Copyright © 2016 Filip Dimovski (dimfilip20@gmail.com)
The scripts and files of this project's repository are subject to the GNU General Public License, version 3, unless noted otherwise.
