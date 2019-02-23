
```sh
use admin
db.createUser( { user: "admin", pwd: "aabbccdd", roles: [ { role: "root", db: "admin" } ] } )
use yapi
db.createUser( { user: "yapi", pwd: "aabb11", roles: [ { role: "readWrite", db: "yapi" }, { role: "clusterMonitor", db: "admin" } ] } )
```