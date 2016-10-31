# A step by step guide of setting up and running Dockerific ELK using Ubuntu 14.04 LTS on VirtualBox, part 3

## Running Dockerific ELK

Now we can get the Dockerific ELK's files, configure it and start the services:

```sh
# Get the files from GitHub
rex@beatrice:~$ git pull https://github.com/rexich/dockerific-elk-vm.git
rex@beatrice:~$ cd dockerific-elk-vm/

# Set up the system for Dockerific ELK
rex@beatrice:~$ sudo ./maintenance/setup install
- Creating rsyslog configuration file...DONE
- Creating sysctl configuration file...DONE
- Installing ls-images utility...DONE
- Installing maintenance scripts...DONE
Installation complete. Thank you for using the Dockerific ELK stack. :)

# Start Dockerific ELK
rex@beatrice:~$ docker-compose up
```

In VirtualBox, change again the settings for port forwarding, and add a rule to forward the port 5601 from the guest machine to `127.0.0.1`.

![VirtualBox Port Forwarding Window](images/10.png?raw=true)

Now, in your favorite browser open `localhost:5601` and you will see Kibana's interface. Congratulations! Everything works! :grin:

To stop the stack, issue `CTRL-C` in the terminal and then `docker-compose down`. 

## More resources

There is a detailed explanation of [how everything works](how_everything_works.md), and about how I set up and configured [Elasticsearch](setting_up_elasticsearch.md), [Logstash](setting_up_logstash.md), and [Kibana](setting_up_kibana.md).

Check out the source code of all the scripts in the [`maintenance'](../maintenance/) directory. Happy hacking! :bear:
