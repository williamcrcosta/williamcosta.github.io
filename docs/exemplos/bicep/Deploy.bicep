// Definir parâmetros
param location string = 'eastus'
param resourceGroupName string = 'BastionResourceGroup'
param vnetName string = 'BastionVNet'
param subnetAppName string = 'AppSubnet'
param subnetBastionName string = 'AzureBastionSubnet'
param bastionHostName string = 'BastionHost'
param publicIpName string = 'BastionPublicIP'
param vmName string = 'LinuxVM'
param adminUsername string
@secure()
param adminPassword string

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

// Criar Virtual Network com subnets
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: subnetAppName
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
      {
        name: subnetBastionName
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

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
            id: virtualNetwork.properties.subnets[1].id
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}

// Criar Network Interface para VM
resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// Criar VM Linux 24.04
resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '24_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
