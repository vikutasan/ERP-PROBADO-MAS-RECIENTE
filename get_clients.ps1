$r = Invoke-RestMethod -Uri 'http://192.168.1.117:5001/api/v1/grandeza/clients' -Method GET
foreach($c in $r) {
    Write-Output "$($c.id)|$($c.name)|$($c.business_name)|$($c.phone)|$($c.address)|$($c.google_maps_url)"
}
