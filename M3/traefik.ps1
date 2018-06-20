param(
   [string] [Parameter(Mandatory = $true)] $ClusterName,
   [string] [Parameter(Mandatory = $true)] $Thumbprint
)

. "$PSScriptRoot\..\Common.ps1"

$TypeName = "TraefikType"
$Path = "$PSScriptRoot\..\Traefik"
$Endpoint = "$ClusterName.westeurope.cloudapp.azure.com:19000"

Write-Host "connecting to cluster $Endpoint using cert thumbprint $Thumbprint..."
Connect-ServiceFabricCluster -ConnectionEndpoint $Endpoint `
    -X509Credential `
    -ServerCertThumbprint $Thumbprint `
    -FindType FindByThumbprint -FindValue $Thumbprint `
    -StoreLocation CurrentUser -StoreName My

Write-Host "uploading Traefik binary to the cluster..."
Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $Path -ApplicationPackagePathInImageStore $TypeName -TimeoutSec 1800 -ShowProgress

Write-Host "registering application..."
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $TypeName

Write-Host "creating application..."
New-ServiceFabricApplication -ApplicationName "fabric:/$TypeName" -ApplicationTypeName $TypeName -ApplicationTypeVersion "1.0.0"