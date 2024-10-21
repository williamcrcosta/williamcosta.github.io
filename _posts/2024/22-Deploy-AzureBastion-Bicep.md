---
layout: post
title: 'Deploy Azure Bastion (Bicep)'
date: 2024-10-17 08:30:00 -0300
categories: [Network]
tags: [Azure, Network, Bastion, Bicep]
slug: 'Deploy-Bastion-Bicep'
#image:
#  path: assets/img/01/image.gif
---

```bicep
// Definir parâmetros
param location string = 'eastus'
param resourceGroupName string = 'BastionResourceGroup'
param vnetName string = 'BastionVNet'
param subnetName string = 'AzureBastionSubnet'
param bastionHostName string = 'BastionHost'
param publicIpName string = 'BastionPublicIP'
```

```bicep
// Criar grupo de recursos
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}
```

```bicep
// Criar endereço IP público com múltiplas zonas
resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

```bicep
// Criar rede virtual
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}
```

```bicep
// Criar Azure Bastion
resource bastionHost 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}
```