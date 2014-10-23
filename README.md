# postgres-xc Docker image

This is a work-in-progress for standing up a development instance of postgres-xc running a GTM, 2 datanodes, and a coordinator.

## How to run

```shell
# Start up the cluster
$ docker run -ti -p 5432:5432 --name=pgcluster postgres-xc

# After cluster has completed booting, initialize it
$ docker exec -ti pgcluster /init_cluster
```
