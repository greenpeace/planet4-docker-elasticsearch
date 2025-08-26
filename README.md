# Planet 4 Elasticsearch Docker Image

![Planet4](./planet4.png)

Docker image for building [Elasticsearch helm chart](https://github.com/greenpeace/planet4-helm-elasticsearch).

## Development

Running `make` will build the images and run the tests.

### Requirements

1. docker
2. make

### Image versions and tags

- Creating a new branch will use the branch name to tag the docker image
- Commiting on `main` branch will build an image using both the upstream image version and `latet`
