# Wireguard server on Azure 
Quick deployment of a wireguard server on Azure with QR Code based setup of your mobile device. 
## Deployment Options 

### Azure Portal
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fderdanu%2Fazure-wireguard%2Fmaster%2Fazuredeploy.json)

### CLI
#### Create a server
    
    resourceGroupName=wireguardserver
    location=westeurope

    az group create -n $resourceGroupName -l $location
    az deployment group create --name wireguarddeployment --resource-group $resourceGroupName --template-file azuredeploy.json

#### Tear down the enviroment
    az group delete -n $resourceGroupName 

### Client Config.
Point your browser to http://<FQDN>:4711 and it will show an onetime QR code for mobile client setup.  

