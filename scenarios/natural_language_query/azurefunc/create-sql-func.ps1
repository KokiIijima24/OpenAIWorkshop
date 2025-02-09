# Create a single database and configure a firewall rule

#param($location,$resourceGroup,$server,$database,$login,$password,$subscription,$tenantid,$storageaccountname,$functionname)
$location="eastus"
$resourceGroup="natural_language_sql_handson9874"
$server="sample2424"
$database="sample_db2424"
$login="sample_user"
$password="Test@123"
$subscription="4a638e79-e52d-4f0e-ba58-e6cc63b85ee3"
$tenantid="cc7dee35-16af-4e40-a4d4-2619d7c0024f"
$storageaccountname="samplestorage2424"
$functionname="samplefuncApp2424"


$tag="create-and-configure-database"
# Specify appropriate IP address values for your environment
# to limit access to the SQL Database server
$startIp="0.0.0.0"
$endIp="255.255.255.255"


az account set -s $subscription
echo "Using resource group $resourceGroup with login: $login, password: $password..."
echo "Creating $resourceGroup in $location..."

az group create --name $resourceGroup --location $location --tags $tag
echo "Creating $server in $location..."
az sql server create --name $server --resource-group $resourceGroup --location $location --admin-user $login --admin-password $password
echo "Configuring firewall..."
az sql server firewall-rule create --resource-group $resourceGroup --server $server -n AllowYourIp --start-ip-address $startIp --end-ip-address $endIp
echo "Creating $database on $server..."
az sql db create --resource-group $resourceGroup --server $server --name $database --sample-name AdventureWorksLT --edition Basic --family Gen5 --capacity 2 --zone-redundant false # zone redundancy is only supported on premium and business critical service tiers


az storage account create --name $storageaccountname --location $location --resource-group $resourceGroup --sku "Standard_LRS"  
echo "Creating function : $functionname"
az functionapp create --name $functionname --storage-account $storageaccountname --consumption-plan-location $location --resource-group $resourceGroup --os-type Linux --runtime python --runtime-version 3.9 --functions-version 4

az webapp cors add --resource-group $resourceGroup --name $functionname --allowed-origins 'https://ms.portal.azure.com'

echo "Deploying function : $functionname"

Start-Sleep -Seconds 50  
func azure functionapp publish $functionname --force --python

