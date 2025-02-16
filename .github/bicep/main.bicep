param resourceGroup string
param clusterName string = 'myAKSCluster'
param dnsPrefix string = 'aks-dns'

module aks './aks.bicep' = {
  name: 'aksDeployment'
  params: {
    clusterName: clusterName
    dnsPrefix: dnsPrefix
    resourceGroup: resourceGroup
  }
}
