$resourceGroup = "BlackMagicCGNVM"
$vmName = "mdvm1"
$scriptName = "NewDisk"
$fileName = "NewDisk.ps1"
$location = "northeurope"
$storageAccountName = "blackmagicscripts"
$containerName = "scripts"
$localFile = "C:\Users\tillm\OneDrive\Vorträge\Azure Black Magic\BlackMagicWorkshop\BlackMagicWorkshop\NewDisk.ps1"

$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup `
                                            -Name $storageAccountName `
                                            -ErrorAction SilentlyContinue

if(!$storageAccount)
{
    $storageAccount = New-AzureRmStorageAccount -ResourceGroupName $resourceGroup `
                          -Name $storageAccountName `
                          -SkuName Standard_LRS `
                          -Location $location `
                          -Kind Storage;
}

$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroup `
                                                  -Name $storageAccountName).Value[0];

$context = New-AzureStorageContext -StorageAccountName $storageAccountName `
                                   -StorageAccountKey $storageAccountKey

$container = New-AzureStorageContainer -Name $containerName `
                                       -Context $context

Set-AzureStorageBlobContent -File $localFile `
                            -Container $containerName `
                            -Blob $fileName `
                            -Context $context `
                            -Force

Set-AzureRmVMCustomScriptExtension -ResourceGroupName $resourceGroup `
                                   -Location $location `
                                   -VMName $vmName `
                                   -StorageAccountName $storageAccountName `
                                   -StorageAccountKey $storageAccountKey `
                                   -ContainerName $containerName `
                                   -Name $scriptName `
                                   -FileName $fileName `
                                   -Run $fileName
