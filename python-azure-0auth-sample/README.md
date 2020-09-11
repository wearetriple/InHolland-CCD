# Sample

build using python 3.8

## local development

for local development create a .env file in the root

```
TENANT=<tenant-id>
CLIENT_ID=<client-id>
REDIRECT_URL=http://localhost:5001/show-token
```

## parameters.json

the following need to be overriden

```
"subscriptionId": {
    "value": ""
},
"name": {
    "value": ""
},

"hostingPlanName": {
    "value": ""
},
"serverFarmResourceGroup": {
    "value": ""
},
```