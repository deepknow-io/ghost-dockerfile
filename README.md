# ghost-dockerfile

This is the dockerfile responsible for creating the docker image for Ghost,
which is being deployed to AWS ECS. It orginated from
[ghost repo](https://github.com/docker-library/ghost/tree/d597db3b33396195576710c3af6c4c9dffbc454d/3/debian)
under docker-library. This version is modifieid to remove sqlite dependency and
to allow configuring database at container run time.
