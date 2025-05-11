param location string = resourceGroup().location
param aksClusterName string
param dnsPrefix string
param agentCount int = 2
param agentVMSize string = 'Standard_DS2_v2'
param vnetName string = 'aksVnet'
param subnetName string = 'aksSubnet'

module network 'modules/network/network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    vnetName: vnetName
    subnetName: subnetName
  }
}

module aks 'modules/aks/aks.bicep' = {
  name: 'aksDeployment'
  params: {
    location: location
    aksClusterName: aksClusterName
    dnsPrefix: dnsPrefix
    agentCount: agentCount
    agentVMSize: agentVMSize
    subnetId: network.outputs.subnetId
  }
}
