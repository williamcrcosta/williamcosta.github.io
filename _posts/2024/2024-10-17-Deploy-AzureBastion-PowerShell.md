---
layout: post
title: 'Deploy Azure Bastion (PowerShell)'
date: 2024-10-17 08:30:00 -0300
categories: [Network]
tags: [Azure, Network, Bastion, PowerShell]
slug: 'Deploy-Bastion-PowerShell'
#image:
#  path: assets/img/01/image.gif
---

Fala galera!👋

**Bem-vindo ao Blog Cloud Insights!** ☁️

Neste post, vamos explorar como realizar o Deploy do Azure Bastion via PowerShell.

### Pré-requisitos

Antes de começarmos nosso laboratório, verifique se você possui:

- Uma conta do Azure com uma assinatura/subscription ativa.

> Caso você não tenha uma subscription, você pode criar uma Trial. Mais informações consulte <a href="https://azure.microsoft.com/en-us/" target="_blank">aqui</a>.
{: .prompt-tip }

#### Passo 1: Instalar o PowerShell 7

Primeiro, caso você não tenha PowerShell 7 instalado, aqui estão os links com a documentação oficial para diferentes sistemas operacionais:

- <a href="https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4" target="_blank">Windows</a>
- <a href="https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos?view=powershell-7.4" target="_blank">macOS</a>
- <a href="https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.4" target="_blank">Linux</a>

No meu laboratório vou simular a instalação do Powershell no Windows 10.

- Verifique as versões disponiveis com o comando a seguir:

```powershell
winget search Microsoft.PowerShell
```

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/Verifique%20a%20versao%20do%20Powershell7.png){: .shadow .rounded-10}

- Instale o Powershell

```powershell
winget install --id Microsoft.PowerShell --source winget
```

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/02-Instando%20Powershell7%20na%20versao%20mais%20recente.png){: .shadow .rounded-10}

- Instale também o Azure PowerShell

> Para instalar o Azure PowerShell siga o passo-a-passo disponivel <a href="https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-12.4.0&tabs=powershell&pivots=windows-msi" target="_blank">aqui</a>.
{: .prompt-tip }

#### Passo 2: Verificar a Instalação

- Após a instalação, verifique se o Powershell 7 está funcionando corretamente. Abra o powershell em sua máquina e execute o comando abaixo:

```powershell
$PSVersionTable.PSVersion
```

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/07VersaoPowershell.png){: .shadow .rounded-10}

> Obs.: Talvez seja necessário reiniciar sua máquina.
{:.prompt-info}

#### Passo 3: Faça login com Azure PowerShell

> Dica: Se você tiver acesso em mais de uma subscription, você pode executar o comando a seguir para determinar qual subscription você pretende deixar como default para toda vez que fizer login no Azure. Clique <a href="https://learn.microsoft.com/en-us/powershell/module/az.accounts/?view=azps-12.4.0&form=MG0AV3" target="_blank">aqui</a> para validar mais parametros que você pode utilizar.
{:.prompt-info}

```powershell
Update-AzConfig -DefaultSubscriptionForLogin subscription ID
```
![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/05-SetandoSubscriptionDefault.png){: .shadow .rounded-10}

- Com o powershell aberto execute o comando a seguir para logar no Azure.

```powershell
Connect-AzAccount -DeviceCode
```

- Abra link e copie o código para logar com suas credenciais.

    - *Depois de ter logado você vai notar no powershell que vai aparecer a subscription default que você associou.*

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/06-Connect-AzAccount%20DeviceCode.png){: .shadow .rounded-10}

> Para mais informações sobre os métodos de login com o Azure Powershell, consulte <a href="https://learn.microsoft.com/en-us/powershell/azure/authenticate-azureps?view=azps-12.4.0&form=MG0AV3" target="_blank">aqui</a>.
{: .prompt-tip }

---

#### Passo 4: Deploy dos recursos Base

- Crie um novo resource-group com o comando a seguir.

```powershell
New-AzResourceGroup -Name RG-BastionPS -Location eastus2
```

- Crie uma nova Virtual Network + AzureBastionSubnet

```powershell
$subApp = New-AzVirtualNetworkSubnetConfig -Name subApp -AddressPrefix "10.110.10.0/24" # Cria uma variavel da subApp

$virtualNetwork = New-AzVirtualNetwork -ResourceGroupName RG-BastionPS -Location eastus2 -Name BastionPSVNet -AddressPrefix 10.110.0.0/16 -Subnet $subApp # Faz o deploy da BastionPSVNet e cria uma variavel dela associando a subnet subApp

Add-AzVirtualNetworkSubnetConfig -Name AzureBastionSubnet -VirtualNetwork $virtualNetwork -AddressPrefix "10.110.30.0/26" # Cria a AzureBastionSubnet

$virtualNetwork | Set-AzVirtualNetwork # Associa a AzureBastionSubnet na VNet BastionPSVNet
```
![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/10-DeployVNET+Subnets.png){: .shadow .rounded-10}

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/101VNet%20criada.png){: .shadow .rounded-10}

#### Passo 5: Deploy do Azure Bastion

Para que seja possivel fazer o deploy do Azure Bastion, necessitamos ter um Public-IP. Veja abaixo como fazer a criação dele.

```powershell
$publicIp = New-AzPublicIpAddress -ResourceGroupName RG-BastionPS -Location eastus2 -Name BastionPS-PIP -AllocationMethod Static -Sku Standard -Zone 1,2,3
```

> Se quiser saber mais sobre o Public IP, para entender sua Limitações, Preços e SKU, consulte <a href="https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses" target="_blank">aqui</a>.
{: .prompt-tip }

- Agora vamos fazer o Deploy do Azure Bastion utilizando os recursos base que criamos acima.

```powershell
New-AzBastion -ResourceGroupName RG-BastionPS -Name BastionHostPS -PublicIpAddressId $publicIp.Id -VirtualNetworkId $virtualNetwork.Id -Location eastus2 -Sku Basic
```

![azure-automation-account](/assets/img/Lab01-Bastion/Bastion-azcli/new/10-DeployBastionAZCLI.png){: .shadow .rounded-20 }

- Com o Deploy do Bastion finalizado, agora podemos fazer o login em uma VM Windows para validar a funcionalidade do recurso.

#### Passo 6: Acessando VMs com o Azure Bastion

- Neste <a href="https://cloudinsights.com.br/posts/Access-VMs-AzureBastion/" target="_blank">link</a>, tem um post apresentando o passo a passo para acessar uma VM Linux ou Windows com o Azure Bastion.

## Documentação Adicional

Para mais detalhes, você pode consultar a documentação oficial no Microsoft Learn:

<a href="https://learn.microsoft.com/en-us/azure/bastion/create-host-cli" target="_blank">Deploy Bastion using Azure CLI</a>

<a href="https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli" target="_blank">Opções de Autenticação com a CLI do Azure</a>



## Conclusão

Agora você sabe como realizar o deploy do Azure Bastion através do Azure CLI.

Até a próxima!! 😉

![resource-group](/assets/img/02/cloudinsights3.png){: .shadow .rounded-10}

#CloudInsights #PartiuNuvem #Azure #Tech #Cloud #Security #Network #AzCLI

---

[![Build and Deploy](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml/badge.svg)](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml)

