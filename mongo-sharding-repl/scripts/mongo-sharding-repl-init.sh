#!/bin/bash

echo $'Stage 1) configSrv start\n'
docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate(
  {
    _id : "config_server",
    configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF
echo 'Stage 1) configSrv finish'

#######################################################################

sleep 5
echo $'Stage 2) Shards start\n'

#######################################################################

echo $'Stage 2.1) Shard1 start\n'
docker compose exec -T shard1-primary mongosh --port 27018 --quiet <<EOF
rs.initiate({
    _id : "shard1ReplicaSet",
    members: [
        { _id : 0, host : "shard1-primary:27018" },
        { _id : 1, host : "shard1-1-secondary:27019" },
        { _id : 2, host : "shard1-2-secondary:27020" }
    ]
});
EOF
echo $'Stage 2.1) Shard1 finish'

#######################################################################

sleep 5
echo $'Stage 2.2) Shard2 start\n'
docker compose exec -T shard2-primary mongosh --port 27021 --quiet <<EOF
rs.initiate({
    _id : "shard2ReplicaSet",
    members: [
        { _id : 0, host : "shard2-primary:27021" },
        { _id : 1, host : "shard2-1-secondary:27022" },
        { _id : 2, host : "shard2-2-secondary:27023" }
    ]
});
EOF
echo $'Stage 2.2) Shard2 finish'

#######################################################################

sleep 5
echo $'Stage 3) Route Initialize start\n'
docker compose exec -T mongos_router mongosh --port 27024 --quiet <<EOF
sh.addShard("shard1ReplicaSet/shard1-primary:27018,shard1-1-secondary:27019,shard1-2-secondary:27020");
sh.addShard("shard2ReplicaSet/shard2-primary:27021,shard2-1-secondary:27022,shard2-2-secondary:27023");

sh.enableSharding("somedb")
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF
echo $'Stage 3) Route Initialize finish'

#######################################################################

sleep 5
echo $'Stage 4) Data Load start\n'
docker compose exec -T mongos_router mongosh --port 27024 --quiet <<EOF
use somedb;

for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i});

db.helloDoc.countDocuments();
EOF
echo $'Stage 4) Data Load finish'


#######################################################################

sleep 5
echo $'Stage 5) Check Data Shards start\n'

#######################################################################

echo $'Stage 5.1) Check Data Shards 1 start\n'

#######################################################################

echo $'Stage 5.1) Check Data Shard 1 primary start\n'
docker compose exec -T shard1-primary mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
echo $'Stage 5.1) Check Data Shard 1 primary finish'

#######################################################################

sleep 5
echo $'Stage 5.1) Check Data Shard 1-1 secondary start\n'
docker compose exec -T shard1-1-secondary mongosh --port 27019 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
echo $'Stage 5.1) Check Data Shard 1-1 secondary finish'

#######################################################################

sleep 5
echo $'Stage 5.1) Check Data Shard 1-2 secondary start\n'
docker compose exec -T shard1-2-secondary mongosh --port 27020 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
echo $'Stage 5.1) Check Data Shard 1-2 secondary finish'

#######################################################################

sleep 5
echo $'Stage 5.2) Check Data Shards 2 start\n'

#######################################################################

echo $'Stage 5.2) Check Data Shard 2 primary start\n'
docker compose exec -T shard2-primary mongosh --port 27021 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
echo $'Stage 5.2) Check Data Shard 2 primary finish'

#######################################################################

sleep 5
echo $'Stage 5.2) Check Data Shard 2-1 secondary start\n'
docker compose exec -T shard2-1-secondary mongosh --port 27022 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
echo $'Stage 5.2) Check Data Shard 2-1 secondary finish'

#######################################################################

sleep 5
echo $'Stage 5.2) Check Data Shard 2-2 secondary start\n'
docker compose exec -T shard2-2-secondary mongosh --port 27023 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
echo $'Stage 5.2) Check Data Shard 2-2 secondary finish'

echo $'Stage 5) Check Data Shards finish'