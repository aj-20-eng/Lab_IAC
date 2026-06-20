using './main.bicep'

param location = 'centralindia'
param vnetName = 'vnet-spoke-lab-cin-01'
param addressPrefixes = [ '10.20.0.0/16' ]

param subnets = [
  // General workloads
  {
    name: 'snet-app'
    addressPrefix: '10.20.1.0/24'
  }
  // AKS node pool subnet
  {
    name: 'snet-aks'
    addressPrefix: '10.20.16.0/22'   // /22 = ~1024 IPs, node scaling ke liye
  }
  // Private Endpoints — PE ke liye network policies Disabled rakhna padta hai
  {
    name: 'snet-pe'
    addressPrefix: '10.20.2.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
  // PostgreSQL Flexible Server — delegated subnet (ab string!)
  {
    name: 'snet-pg'
    addressPrefix: '10.20.3.0/24'
    delegation: 'Microsoft.DBforPostgreSQL/flexibleServers'
  }
]

param tags = {
  environment: 'lab'
  topology: 'spoke'
  managedBy: 'bicep-avm'
  owner: 'ami'
}