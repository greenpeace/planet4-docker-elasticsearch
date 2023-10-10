FROM docker.elastic.co/elasticsearch/elasticsearch:8.5.0

RUN bin/elasticsearch-plugin install https://github.com/spinscale/elasticsearch-ingest-langdetect/releases/download/8.5.0.1/ingest-langdetect-8.5.0.1.zip
