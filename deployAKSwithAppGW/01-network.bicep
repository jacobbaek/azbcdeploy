/*
------------------------
parameters
------------------------
*/
param prefix string
param vnetcidr string
param akssubnetaddr string
param appgwsubnetaddr string

var vnet_name = '${prefix}-vnet'
var vnet_prefix = vnetcidr
var appgw_subnet_name = '${prefix}-appgw-subnet'
var appgw_subnet_address = appgwsubnetaddr
var aks_subnet_name = '${prefix}-aks-subnet'
var aks_subnet_address = akssubnetaddr
var pip_name = '${prefix}-pip'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnet_name
  location: resourceGroup().location
  properties: {
    addressSpace:{
      addressPrefixes:[
        vnet_prefix
      ]
    }
    subnets:[
      // application gateway
      {
        name: appgw_subnet_name
        properties:{
          addressPrefix: appgw_subnet_address
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      // api management
      {
        name: aks_subnet_name
        properties:{
          addressPrefix: aks_subnet_address
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }  
    ]   
  }
}

@description('appgw public IP')
resource publicIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: pip_name
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

/*
------------------------
outputs
------------------------
*/

output appgwsubnetid string = virtualNetwork.properties.subnets[0].id
output akssubnetid string = virtualNetwork.properties.subnets[1].id
output appgwpipid string = publicIP.id
