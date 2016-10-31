FROM kibana:5
# Use the official image, latest version (currently, version 5)
# https://hub.docker.com/_/kibana/
# The FROM instruction MUST be first, according to the Dockerfile spec.

# The following is a crude hack, that will make Kibana wait until
# Elasticsearch server is up and running, and then connect on it.

RUN apt-get update && apt-get install -y netcat bzip2

COPY startup.sh /tmp/startup.sh
RUN chmod +x /tmp/startup.sh

# Replace the default command of the official image with this script
CMD ["/tmp/startup.sh"]
