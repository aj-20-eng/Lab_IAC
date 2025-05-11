param location string
param vnetName string
param subnetName string
param addressPrefix string = '10.0.0.0/8'
param subnetPrefix string = '10.240.0.0/16'

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [addressPrefix]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnets[0].id
