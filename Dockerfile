FROM centerforopenscience/elasticsearch:5.4

RUN bin/elasticsearch-plugin install ingest-attachment
