FROM docker.elastic.co/elasticsearch/elasticsearch-oss:6.3.1

RUN bin/elasticsearch-plugin install ingest-attachment
