# Sphinx Search

![Sphinx Version](https://img.shields.io/badge/version-2.3.2-green.svg?style=for-the-badge)
![Stars](https://img.shields.io/docker/stars/jc21/sphinxsearch.svg?style=for-the-badge)
![Pulls](https://img.shields.io/docker/pulls/jc21/sphinxsearch.svg?style=for-the-badge)

[Sphinx Search](http://sphinxsearch.com/) running on Centos 7

Due to the way Sphinx operates, you need to follow these steps:

- Define your Sphinx Configuration - [sphinx.conf](http://sphinxsearch.com/docs/latest/indexing.html)
- Get Sphinx to build the Indexes
- Run the Server
- Rotate the Indexes periodically


## Docker Compose Example

```yml
version: "2"
services:
  sphinx:
    image: jc21/sphinxsearch
    ports:
      - 9306:9306
      - 9312:9312
    volumes:
      - "./sphinx.conf:/etc/sphinx/sphinx.conf"
      - "./data:/var/data/sphinx"
```


## Creating the Indexes

With docker-compose:

```bash
docker-compose run --rm sphinx indexer --all
```

With docker vanilla:

```bash
docker run --rm -it \
    -v /path/to/sphinx.conf:/etc/sphinx/sphinx.conf \
    -v /path/to/data:/var/data/sphinx \
    jc21/sphinxsearch \
    indexer --all
```


## Running the Sphinx Search Server

With docker-compose:

```bash
docker-compose up -d
```

With docker vanilla:

```bash
docker run --detach \
    --name sphinxsearch \
    -p 9306:9306 \
    -p 9312:9312 \
    -v /path/to/sphinx.conf:/etc/sphinx/sphinx.conf \
    -v /path/to/data:/var/data/sphinx \
    jc21/sphinxsearch
```


## Rotating the Indexes

The docker container must be running for rotating to work.

With docker-compose:

```bash
docker-compose exec sphinx indexer --all --rotate 
```

With docker vanilla (assuming your container name is "sphinxsearch"):

```bash
docker exec -it sphinxsearch indexer --all --rotate
```
