#!/bin/bash

mongo --eval "db = db.getSiblingDB(\"admin\"); db.createUser({ user: \"$MONGO_ADMIN\", pwd: \"$MONGO_ADMIN_PASSWORD\", roles: [{ role: \"userAdminAnyDatabase\", db: \"admin\" }, { role: \"readWriteAnyDatabase\", db: \"admin\" }]});";
mongo --eval "db = db.getSiblingDB(\"$MONGO_DB\"); db.createUser({ user: \"$MONGO_USER\", pwd: \"$MONGO_PASSWORD\", roles: [{ role: \"readWrite\", db: \"$MONGO_DB\" }]});";
mongo --eval "db = db.getSiblingDB(\"$MONGO_DB\"); db.createCollection(\"uniq\"); db.uniq.insertOne({'firstname': 'Sarah', 'lastname': 'Smith'});";