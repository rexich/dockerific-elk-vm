# Setting up and configuring Logstash

Logstash is the is the component that is going to receive syslog entries emitted by `rsyslog`, which is configured to send the logs at port 5000.  In the same way I tested Elasticsearch, I used Docker Compose to automate the process of creating the image using the official one, and configuring the ports and volumes, and then after everything went fine I integrated it in the main `docker-compose.yml` file of the Dockerific ELK stack.

Simply starting the service with `docker-compose up` made it work. Logs were received once I set up the host machine's `rsyslog` daemon to send the logs at TCP port 5000, and were forwarded to Elasticsearch as syslog data. No special filtering is being done.

The configuration file resides in `logstash/conf/logstash.conf` mounted as a volume, and it's quite simple:

```yaml
input {
    syslog {
        type => syslog
        port => 5000
    }
}

syslog {
}

output {
    elasticsearch {
        hosts => "elasticsearch:9200"
    }
}

```

It is obvious that it takes syslog kind of data on port 5000, and then outputs it to our Elasticsearch instance (the hostname is the name of the service's container!) on port 9200. Later running Kebana and checking the data proved it works fine.

On the host machine, we need to add a file with a line that will tell `rsyslog` to start emitting syslog entries also on TCP port 5000. This simple command, run as the superuser (not `sudo`!) does what we need:

```sh
# echo "*.*    @@localhost:5000" > /etc/rsyslog.d/99-emit-logs.conf
```

The `setup.sh` does the trick for you when you run it for installation on the host machine.

This concludes the configuration and testing of Logstash.
