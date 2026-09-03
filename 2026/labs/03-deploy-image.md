# Lab 3 — Deploy image

This lab continues **Lab 2**. Same suffix and resource group. `basic.bicep` must already be deployed.

Starter files: [`../student-material/`](../student-material/).  
API: [`../demos/src/Demos/DemoImagesApi`](../demos/src/Demos/DemoImagesApi) (`GET /images`).

## Before you start

- [Lab 2](02-bicep.md) complete (resource group, Container App, storage)
- Azure CLI logged in: `az login`
- Docker running

Reuse the Lab 2 variables:

```powershell
$env:SUFFIX = "mh26"
$env:LOCATION = "westeurope"
$env:RG = "inh-ccd-lab2-$($env:SUFFIX)"
```

| What | Example |
| --- | --- |
| Container Registry | `inhccdlab2acrmh26` |
| Image | `inhccdlab2acrmh26.azurecr.io/api:latest` |

Run Bicep commands from `2026/student-material` (or pass full `-f` paths).

## Create the registry

Admin user stays **off**. You push with `az acr login` (your Azure identity), not a registry password.

```powershell
az deployment group create `
  -g $env:RG `
  -f registry.bicep `
  --parameters "namePrefix=$($env:SUFFIX)"
```

## Build and push the demo API

Build context must be the **DemoImagesApi** folder (the Dockerfile copies `DemoImagesApi.csproj` from `.`).

```powershell
$acr = "inhccdlab2acr$($env:SUFFIX)"
$loginServer = "$acr.azurecr.io"

az acr login -n $acr

Set-Location <path-to-workshop>/2026/demos/src/Demos/DemoImagesApi
docker build -t "$loginServer/api:latest" .
docker push "$loginServer/api:latest"
```

Contributor on the resource group is enough to push in this lab. **AcrPull** for the Container App is created in the next step.

## Point the Container App at the image

.NET listens on port **8080** (the quickstart image used 80). This template also sets `STORAGE_ACCOUNT_NAME` / `BLOB_CONTAINER_NAME` and assigns **AcrPull** plus **Storage Blob Data Reader**.

```powershell
Set-Location <path-to-workshop>/2026/student-material

az deployment group create `
  -g $env:RG `
  -f container-app-image.bicep `
  --parameters "namePrefix=$($env:SUFFIX)" imageRepository=api imageTag=latest targetPort=8080
```

If a role assignment already exists from `basic.bicep`, that is fine.

## Check the API

Wait about a minute for RBAC, then open Application Url + `/images`, or use [`../demos/http/3-images-api.http`](../demos/http/3-images-api.http).

You should get a JSON array of SAS URLs. `[]` means the app works but the `images` container is empty — upload a blob in the portal (same as Lab 1).

The GitHub **build** workflow only compiles the project. It does not push the image or run these deploys.

## Troubleshooting

| Problem | What to try |
| --- | --- |
| Image pull failed | Confirm `docker push` succeeded; name is `api:latest`; wait for AcrPull |
| `/images` 500 or auth error | Wait for Storage Blob Data Reader; confirm `STORAGE_ACCOUNT_NAME` |
| Still the quickstart welcome page | `container-app-image.bicep` not applied, or target port still 80 |
| `docker push` denied | `az login` / `az acr login`; you need push rights on the RG |

## Cleanup

Same as Lab 2: delete resource group `inh-ccd-lab2-<suffix>` when you are finished with both labs.
