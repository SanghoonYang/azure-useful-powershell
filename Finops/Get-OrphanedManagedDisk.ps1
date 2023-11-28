param(
$OutFile = ".\OrphanedDisk.html"
)
$AllDisk = @()
$OrphanedDisk = @()


if(-not (Get-AzContext)){
Login-AzAccount
}

$Subs = Get-AzSubscription #-SubscriptionName Sumesh
$SubsCount = $Subs.Count
Write-Host "Found $SubsCount Subscriptions"

$i = 0
$Subs | %{
$sub = $PSItem
$i++

Write-Host "Enumerating Subscription [$i/$SubsCount]: $($sub.name)"
Set-AzContext -Subscription $sub

$AllDisk = Get-Azdisk
#$OrphanedDisks += ($Alldisk | ? { $_.managedby -eq $null })


($Alldisk | ? { $_.managedby -eq $null }) |%{
$prop = [ordered] @{

Subscription = $Sub.Name
Name = $PSItem.Name
ResourceGroup = $PSItem.ResourceGroupName
Sku = $PSItem.Sku.Name
Location = $PSItem.Location
DiskState = $PSItem.DiskState
DiskSizeGB = $PSItem.DiskSizeGB
OsType = $PSItem.OsType
TimeCreated = $PSItem.TimeCreated
Type = $PSItem.Type
ManagedBy = $PSItem.ManagedBy
}
$DISKobj = New-Object -TypeName psobject -Property $prop

$OrphanedDisk += $DISKobj
}
}

$OrphanedDisk| ft

function Out-HTMLTable{
Param(
$RawCSVData = "NO DATA",
$OutFile = "$env:TEMP\Out.html",
$Heading = "Result Table"
)

$style = "
<style>BODY{font-family: Calibri; font-size: 11pt;}
TABLE{border: 1px solid black; border-collapse: collapse;}
TH{border: 1px solid black; background: #dddddd; padding: 5px; }
TD{border: 1px solid black;  padding: 5px; }
tr:nth-child(odd){ background:#e9e9ff; }
tr:nth-child(even){ background:#B2CCFF; }
</style>"

$postcontent = [Text.Encoding]::Unicode.GetString([Convert]::FromBase64String("PABoADMAPgBQAHIAbwB2AGkAZABlAGQAIABhAHMAIABwAGEAcgB0ACAAbwBmACAAJwBBAHoAdQByAGUAIABDAG8AcwB0ACAATwBwAHQAaQBtAGkAegBhAHQAaQBvAG4AIABDAG8AdQByAHMAZQAnADwALwBoADMAPgANAAoATABlAGEAcgBuACAAbQBvAHIAZQAgAHcAYQB5AHMAIAB0AG8AIABpAGQAZQBuAHQAaQBmAHkAIABvAHIAcABoAGEAbgBlAGQAIAByAGUAcwBvAHUAcgBjAGUAcwAgAGEAbgBkACAAbwBwAHQAaQBtAGkAegBlACAAQQB6AHUAcgBlACAAQwBvAHMAdABzACAAQAA6ADwALwBiAHIAPgANAAoAPABhACAAaAByAGUAZgA9ACIAaAB0AHQAcABzADoALwAvAHcAdwB3AC4AdQBkAGUAbQB5AC4AYwBvAG0ALwBjAG8AdQByAHMAZQAvAGEAegB1AHIAZQAtAGMAbwBzAHQALQBvAHAAdABpAG0AaQB6AGEAdABpAG8AbgAvAD8AcgBlAGYAZQByAHIAYQBsAEMAbwBkAGUAPQA5ADgAMQAwAEQAQwAyAEYAQgBEADgAQgAzADQAMQA0ADYANgA2ADYAIgA+AGgAdAB0AHAAcwA6AC8ALwB3AHcAdwAuAHUAZABlAG0AeQAuAGMAbwBtAC8AYwBvAHUAcgBzAGUALwBhAHoAdQByAGUALQBjAG8AcwB0AC0AbwBwAHQAaQBtAGkAegBhAHQAaQBvAG4ALwA/AHIAZQBmAGUAcgByAGEAbABDAG8AZABlAD0AOQA4ADEAMABEAEMAMgBGAEIARAA4AEIAMwA0ADEANAA2ADYANgA2ADwALwBhAD4A"))

$HTMLContent = $RawCSVData | ConvertFrom-Csv | ConvertTo-Html -Head $style -PostContent $postcontent -PreContent "<h2>$heading</h2>" #-as List
$HTMLContent | Out-File $OutFile

}

$csvdata = $OrphanedDisk | ConvertTo-csv -NoTypeInformation # | Out-File -FilePath $OutFile
Out-HTMLTable -RawCSVData $csvdata -OutFile $outfile -Heading "Orphaned Disks (Managed) Report"

& $OutFile

