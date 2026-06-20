targetScope = 'resourceGroup'

param location string = resourceGroup().location
param vnetName string
param addressPrefixes array
param subnets array
param tags object = {}
param dnsServers array = []

module vnet 'br/public:avm/res/network/virtual-network:0.9.0' = {
  name: 'deploy-${vnetName}'
  params: {
    name: vnetName
    location: location
    addressPrefixes: addressPrefixes
    subnets: subnets
    tags: tags
    dnsServers: dnsServers
    enableTelemetry: false
  }
}

output vnetResourceId string = vnet.outputs.resourceId
output subnetResourceIds array = vnet.outputs.subnetResourceIds
output subnetNames array = vnet.outputs.subnetNames