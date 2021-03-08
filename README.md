# ghost-dockerfile

### About

This is the dockerfile responsible for creating the docker image for Ghost,
which is being deployed to AWS ECS. It orginated from a
[ghost repo](https://github.com/docker-library/ghost/tree/d597db3b33396195576710c3af6c4c9dffbc454d/3/debian)
under docker-library. This version is modifieid to remove sqlite dependency and
to allow configuring database, smtp mail server at container start time.

----

### Getting Started

#### Prerequisite

(Docker)[https://docs.docker.com/get-started/] (docker.com)
(Ghost Cli)[https://ghost.org/docs/ghost-cli/] (ghost.org)


#### Build

```
docker build -t ghost:latest .
```

#### Run Locally

```
docker run --rm --name ghost -p 3001:2368 -e URL=http://localhost -e DB=mysql \
	-e DBHOST=<database url> \
	-e DBUSER=<database user> -e DBPASS=<database password> -e DBNAME=<database> \
	-e MAILUSER=<mail server username> -e MAILPASS=<mail server password> \
	-e MAILHOST=<mail server url> -e MAILPORT=<mail server port> \
	ghost:latest
```
