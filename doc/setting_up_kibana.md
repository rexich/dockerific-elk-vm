# Setting up and configuring Kibana

Kibana is the component that is going to connect to and pull data from Elasticsearch, visualize it and allow us to see the logs realtime. In the same way I tested Elasticsearch and Logstash, I used Docker Compose to automate the process of creating the image using the official one, and configuring the ports and volumes.

Simply starting the service with `docker-compose up` did not made it work at first. I had to wait for Elasticsearch to start up, so first I joined everything in the main `docker-compose.yml` file of the Dockerific ELK stack. I've also defined a Docker network, to make sure the three containers will talk in the same network without any issues. Then, I created a small script that loops. It tries to open a port towards the Elasticsearch server, and once it is available it will stop looping and start Kibana.

The configuration file resides in `kibana/config/kibana.yml` mounted as a volume. Only several are defined:

* We need to use server port 5601 to get into Kibana's web inteface, so: `server.port: 5601`;
* Same as with Elasticsearch, we need to avoid using `localhost` to get to our server, that is why: `server.host: "0.0.0.0"`;
* Most importantly, we need to tell Kebana where Elasticsearch is: `elasticsearch.url: "http://elasticsearch:9200"`.

Once the whole Dockerific ELK stack starts up, and Kebana starts last, I've opened the website by pointing my browser at `localhost:5601`, gave Kibana few seconds to get ready and the web interface was up and running, and I was able to browse and visualize the logs! Voilà! :satisfied:

This concludes the configuration and testing of Kibana.
