# Setting up and configuring Elasticsearch

Elasticsearch is the component that is going to receive input from Logstash in the form of properly-formatted syslog data. I used Docker Compose to automate the process of creating the image using the official one, and configuring the ports and volumes.

At first, I've created a `docker-compose.yml` file for Elasticsearch only for testing, and once I was sure everything works well, I've integrated it in the main `docker-compose.yml` file of the Dockerific ELK stack.

I built and ran the server by issuing `docker-compose up` in the `elasticsearch/` directory where the Dockerfile and necessary directories and configuration resided. When the Elasticsearch container started the first time on the host machine, an error appeared with error code 78 and the container stopped.

```sh
rex@ultrabuk:~/work/testing/elasticsearch$ docker-compose up
Recreating elasticsearch_elasticsearch_1
Attaching to elasticsearch_elasticsearch_1

... truncated ...

elasticsearch_1  | [2016-10-29T19:47:14,742][INFO ][o.e.b.BootstrapCheck     ] [84-ssR-] bound or publishing to a non-loopback or non-link-local address, enforcing bootstrap checks
elasticsearch_1  | ERROR: bootstrap checks failed
elasticsearch_1  | max virtual memory areas vm.max_map_count [65530] likely too low, increase to at least [262144]
elasticsearch_1  | [2016-10-29T19:47:14,750][INFO ][o.e.n.Node               ] [84-ssR-] stopping ...
elasticsearch_1  | [2016-10-29T19:47:14,880][INFO ][o.e.n.Node               ] [84-ssR-] stopped
elasticsearch_1  | [2016-10-29T19:47:14,880][INFO ][o.e.n.Node               ] [84-ssR-] closing ...
elasticsearch_1  | [2016-10-29T19:47:14,892][INFO ][o.e.n.Node               ] [84-ssR-] closed
elasticsearch_elasticsearch_1 exited with code 78
```

The Java Virtual Machine complained that the limit of the maximum number of memory-mapped areas is too low, so I found [a solution] (http://stackoverflow.com/a/11685165) - issuing this command on the host machine will rise the limit and alleviate the issue:

```sh
rex@ultrabuk:~/work/testing/elasticsearch$ sudo sysctl -w vm.max_map_count=262144
[sudo] password for rex: 
vm.max_map_count = 262144
```

This setting is necessary, but will last only until the next boot, so the `setup.sh` makes it permanent by creating a file in `/etc/sysctl.d/99-increase-max-map-count.conf` with this command.

Now, running the container again shows that Elasticsearch is up and running:

```sh
rex@ultrabuk:~/work/testing/elasticsearch$ docker-compose up
Starting elasticsearch_elasticsearch_1
Attaching to elasticsearch_elasticsearch_1
elasticsearch_1  | [2016-10-29T20:15:03,762][INFO ][o.e.n.Node               ] [] initializing ...
elasticsearch_1  | [2016-10-29T20:15:03,846][INFO ][o.e.e.NodeEnvironment    ] [Wg2kJbX] using [1] data paths, mounts [[/usr/share/elasticsearch/data (/dev/sda4)]], net usable_space [22.4gb], net total_space [49gb], spins? [possibly], types [ext4]
elasticsearch_1  | [2016-10-29T20:15:03,847][INFO ][o.e.e.NodeEnvironment    ] [Wg2kJbX] heap size [990.7mb], compressed ordinary object pointers [true]
elasticsearch_1  | [2016-10-29T20:15:03,848][INFO ][o.e.n.Node               ] [Wg2kJbX] node name [Wg2kJbX] derived from node ID; set [node.name] to override
elasticsearch_1  | [2016-10-29T20:15:03,851][INFO ][o.e.n.Node               ] [Wg2kJbX] version[5.0.0], pid[1], build[253032b/2016-10-26T05:11:34.737Z], OS[Linux/4.4.0-45-generic/amd64], JVM[Oracle Corporation/OpenJDK 64-Bit Server VM/1.8.0_102/25.102-b14]
elasticsearch_1  | [2016-10-29T20:15:04,898][INFO ][o.e.p.PluginsService     ] [Wg2kJbX] loaded module [aggs-matrix-stats]
elasticsearch_1  | [2016-10-29T20:15:04,898][INFO ][o.e.p.PluginsService     ] [Wg2kJbX] loaded module [ingest-common]
elasticsearch_1  | [2016-10-29T20:15:04,899][INFO ][o.e.p.PluginsService     ] [Wg2kJbX] loaded module [lang-expression]
elasticsearch_1  | [2016-10-29T20:15:04,899][INFO ][o.e.p.PluginsService     ] [Wg2kJbX] loaded module [lang-groovy]
elasticsearch_1  | [2016-10-29T20:15:04,899][INFO ][o.e.p.PluginsService     ] [Wg2kJbX] loaded module [lang-mustache]
elasticsearch_1  | [2016-10-29T20:15:04,899][INFO ][o.e.p.PluginsService     ] [Wg2kJbX] loaded module [lang-painless]
elasticsearch_1  | [2016-10-29T20:15:04,899][INFO ][o.e.p.PluginsService     ] [Wg2kJbX] loaded module [percolator]
elasticsearch_1  | [2016-10-29T20:15:04,903][INFO ][o.e.p.PluginsService     ] [Wg2kJbX] loaded module [reindex]
elasticsearch_1  | [2016-10-29T20:15:04,903][INFO ][o.e.p.PluginsService     ] [Wg2kJbX] loaded module [transport-netty3]
elasticsearch_1  | [2016-10-29T20:15:04,904][INFO ][o.e.p.PluginsService     ] [Wg2kJbX] loaded module [transport-netty4]
elasticsearch_1  | [2016-10-29T20:15:04,904][INFO ][o.e.p.PluginsService     ] [Wg2kJbX] no plugins loaded
elasticsearch_1  | [2016-10-29T20:15:05,098][WARN ][o.e.d.s.g.GroovyScriptEngineService] [groovy] scripts are deprecated, use [painless] scripts instead
elasticsearch_1  | [2016-10-29T20:15:07,870][INFO ][o.e.n.Node               ] [Wg2kJbX] initialized
elasticsearch_1  | [2016-10-29T20:15:07,871][INFO ][o.e.n.Node               ] [Wg2kJbX] starting ...
elasticsearch_1  | [2016-10-29T20:15:08,093][INFO ][o.e.t.TransportService   ] [Wg2kJbX] publish_address {172.18.0.2:9300}, bound_addresses {[::]:9300}
elasticsearch_1  | [2016-10-29T20:15:08,099][INFO ][o.e.b.BootstrapCheck     ] [Wg2kJbX] bound or publishing to a non-loopback or non-link-local address, enforcing bootstrap checks
elasticsearch_1  | [2016-10-29T20:15:11,200][INFO ][o.e.c.s.ClusterService   ] [Wg2kJbX] new_master {Wg2kJbX}{Wg2kJbX_QoiRBV2W3hbMsg}{8wSDEYljQ_uMabd0IJGV2g}{172.18.0.2}{172.18.0.2:9300}, reason: zen-disco-elected-as-master ([0] nodes joined)
elasticsearch_1  | [2016-10-29T20:15:11,228][INFO ][o.e.h.HttpServer         ] [Wg2kJbX] publish_address {172.18.0.2:9200}, bound_addresses {[::]:9200}
elasticsearch_1  | [2016-10-29T20:15:11,229][INFO ][o.e.n.Node               ] [Wg2kJbX] started
elasticsearch_1  | [2016-10-29T20:15:11,263][INFO ][o.e.g.GatewayService     ] [Wg2kJbX] recovered [0] indices into cluster_state
```

And using `curl` to see the status of Elasticsearch proves everything is working properly:

```sh
rex@ultrabuk:~/work/testing/elasticsearch$ curl 'http://localhost:9200/?pretty'
{
  "name" : "3bqynmO",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "vJFaPhpxRvOXbcNhxONwaQ",
  "version" : {
    "number" : "5.0.0",
    "build_hash" : "253032b",
    "build_date" : "2016-10-26T05:11:34.737Z",
    "build_snapshot" : false,
    "lucene_version" : "6.2.0"
  },
  "tagline" : "You Know, for Search"
}
```

I’ve stopped the service by issuing:

```sh
rex@ultrabuk:~/work/testing/elasticsearch$ docker-compose down 
Removing elasticsearch_elasticsearch_1 ... done
Removing network elasticsearch_default
rex@ultrabuk:~/work/testing/elasticsearch$ docker-compose ps
Name   Command   State   Ports 
------------------------------
```

Check the `elasticsearch/config/elasticsearch.yml` for the configuration, everything is well-documented.

This concludes the configuration and testing of Elasticsearch.
