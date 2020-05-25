# Dockerfile for Neo4j with APOC plugin
FROM neo4j:4.0.3

# versions
ARG NEO4J_VERSION=4.0.3
ENV GDS_VERSION=1.2.1

RUN apt-get update; apt-get install -y unzip

# Fetch the GDS Plugin
RUN wget --directory-prefix=/var/lib/neo4j/plugins \
  https://s3-eu-west-1.amazonaws.com/com.neo4j.graphalgorithms.dist/graph-data-science/\
neo4j-graph-data-science-${GDS_VERSION}-standalone.zip

WORKDIR /var/lib/neo4j/plugins
RUN unzip neo4j-graph-data-science-${GDS_VERSION}-standalone.zip

# mangle Neo4j config to allow APOC to function
RUN printf "# enable APOC\ndbms.security.procedures.unrestricted=apoc.*,gds.*\ndbms.security.procedures.whitelist=apoc.*,gds.*\napoc.import.file.enabled=true\ndbms.directories.import=/imports\n" >> /var/lib/neo4j/conf/neo4j.conf

# Create a graph import directory
RUN mkdir /imports \
  && chmod -R 777 /imports

VOLUME /imports
EXPOSE 7474 7473 7687

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["neo4j"]
