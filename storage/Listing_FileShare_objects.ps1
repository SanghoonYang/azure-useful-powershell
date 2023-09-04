## Input Parameters  
$resourceGroupName="Your-RG"  
$storageAccName="Your-SA"  
$fileShareName="Your-FileShare"  
 
## Connect to Azure Account  
Connect-AzAccount   
 
## Function to Lists directories and files  
Function GetFiles  
{  
    Write-Host -ForegroundColor Green "Lists directories and files.."    
    ## Get the storage account context  
    $ctx=(Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccName).Context  
    ## List directories  
    $directories=Get-AZStorageFile -Context $ctx -ShareName $fileShareName  
    ## Loop through directories  
    foreach($directory in $directories)  
    {  
        if ($directory.gettype().name -eq "AzureStorageFileDirectory")
        {
            write-host -ForegroundColor Magenta " Directory Name: " $directory.Name  
            $files=Get-AZStorageFile -Context $ctx -ShareName $fileShareName -Path $directory.Name | Get-AZStorageFile  
            ## Loop through all files and display  
            foreach ($file in $files)  
            {  
                write-host -ForegroundColor Yellow $file.Name  
            }  
        }
        else 
        {
            write-host -ForegroundColor Blue " Under the share files direct : " $directory.Name
        }
    }  
}  
  
GetFiles   
