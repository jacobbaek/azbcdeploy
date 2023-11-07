
@description('akscluster settings')
param k8sversion string = '1.26.6'
param prefix string = 'aksbicep'

@description('network settings')
param akssubnetcidr string = '172.20.4.0/22'
param appgwsubnetcidr string = '172.20.0.0/24'
param vnetcidr string = '172.20.0.0/16'

param newOrExisting string = 'new'
/*
------------------------------------------------
AKS CLUSTER
------------------------------------------------
*/
module network './01-network.bicep' = if (newOrExisting == 'new') {
  name: 'network'
  params: {
    prefix: prefix 
    vnetcidr: vnetcidr
    akssubnetaddr: akssubnetcidr
    appgwsubnetaddr: appgwsubnetcidr
  }
}

/*
------------------------------------------------
AKS CLUSTER
------------------------------------------------
*/
module aks './02-aksCluster.bicep' = if (newOrExisting == 'new') {
  name: 'akscluster'
  params: {
    clusterdnsdomain: '${prefix}domain'
    clustername: '${prefix}-aks'
    k8sversion: k8sversion
    subnetid: network.outputs.akssubnetid
  }
}


/*
------------------------------------------------
APP GATEWAY
------------------------------------------------
*/
module appgw './03-appGW.bicep' = {
  name: 'appgw'
  params: {
    prefix: prefix
    appgwname: '${prefix}-appgw'
    appgwsubnetid: network.outputs.appgwsubnetid
    appgwpipid: network.outputs.appgwpipid
  }
}
