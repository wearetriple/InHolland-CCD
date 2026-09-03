# Student Bicep starter (2026)

Azure **Container App** (quickstart image) plus a **Storage** account with a private `images` blob container.

Pass your suffix as `namePrefix` (same as the labs, for example `mh26`):

```powershell
$env:SUFFIX = "mh26"
az deployment group create `
  -g "inh-ccd-lab2-$($env:SUFFIX)" `
  -f basic.bicep `
  --parameters "namePrefix=$($env:SUFFIX)"
```

| Resource | Name |
| --- | --- |
| Container App | `inh-ccd-app-<suffix>` |
| Container Apps environment | `inh-ccd-env-<suffix>` |
| Log Analytics workspace | `inh-ccd-law-<suffix>` |
| Storage account | `inhccd<suffix>stg` |
| Blob container | `images` (private) |

The Container App has a **system-assigned managed identity**. Grant it a Storage data-plane role (for example Storage Blob Data Contributor) when the app should read or write blobs — do not put account keys in Bicep or Git.
