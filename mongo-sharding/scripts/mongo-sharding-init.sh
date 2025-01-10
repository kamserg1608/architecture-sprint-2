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
echo $'Stage 1) configSrv finish'

#######################################################################

sleep 5
echo $'Stage 2) Shards start\n'

#######################################################################

echo $'Stage 2.1) Shard1 start\n'
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27018" },
      ]
    }
);
EOF
echo $'Stage 2.1) Shard1 finish'

#######################################################################

sleep 5
echo $'Stage 2.2) Shard2 start\n'
docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 1, host : "shard2:27019" }
      ]
    }
  );
EOF
echo $'Stage 2.2) Shard2 finish'

#######################################################################

sleep 5
echo $'Stage 3) Route Initialize start\n'
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard( "shard1/shard1:27018")
sh.addShard( "shard2/shard2:27019")

sh.enableSharding("somedb")
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF
echo $'Stage 3) Route Initialize finish'

#######################################################################

sleep 5
echo $'Stage 4) Data Load start\n'
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb;

for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i});

db.helloDoc.countDocuments();
EOF
echo $'Stage 4) Data Load finish'

#######################################################################

sleep 5
echo $'Stage 5) Check Data Shards start\n'

#######################################################################

echo $'Stage 5.1) Check Data Shard 1 start\n'
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
echo $'Stage 5.1) Check Data Shard 1 finish'
#######################################################################

sleep 5
echo $'Stage 5.2) Check Data Shard 2 start\n'
docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
echo $'Stage 5.2) Check Data Shard 2 finish'

echo $'Stage 5) Check Data Shards finish'