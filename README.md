## InHolland-Cloud Computing Development

Examples, demos and snippets.

## Links

### Example bicep file

https://github.com/wearetriple/InHolland-CCD/blob/master/2024/student-material/basic.bicep

### Tools

- https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16#download-ssms
- https://learn.microsoft.com/en-us/azure-data-studio/download-azure-data-studio
- https://azure.microsoft.com/en-us/products/storage/storage-explorer/
- https://visualstudio.microsoft.com/vs/community/
- https://visualstudio.microsoft.com/downloads/
- https://learn.microsoft.com/en-us/cli/azure/

### Emulators

- https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-develop-emulator
- https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite
- https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/sql-server-express-localdb

### Emulators in containers

#### Storage

```
docker run --restart unless-stopped -d -p 10000:10000 -p 10001:10001 -p 10002:10002 -v C:/Users/{user}/AppData/Local/Temp/Azurite:/data mcr.microsoft.com/azure-storage/azurite azurite -l /data -d /data/debug.log --blobPort 10000 --blobHost 0.0.0.0 --queuePort 10001 --queueHost 0.0.0.0 --tablePort 10002 --tableHost 0.0.0.0 --disableProductStyleUrl
```

#### Cosmos

```
docker run --restart unless-stopped --publish 8081:8081 --publish 10250-10255:10250-10255 --interactive --tty mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest
```
#### SQL

```
docker run --restart unless-stopped -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=<R34LL1C0mplicated!1231!>' -p 1433:1433 -v sqlvolume:/var/opt/mssql -d mcr.microsoft.com/mssql/server:2022-latest
```
