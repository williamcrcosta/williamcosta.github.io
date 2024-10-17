---
layout: post
title: 'Deploy Azure Bastion (Az CLI)'
date: 2024-10-17 01:00:00 -0300
categories: [Network]
tags: [Azure, Network, Bastion, AzCLI]
slug: 'Deploy-Bastion-AzCLI'
#image:
#  path: assets/img/01/image.gif
---

Fala galera!👋

**Bem-vindo ao Blog Cloud Insights!** ☁️

Neste post, vamos explorar como realizar o Deploy do Azure Bastion via Azure CLI (Software Instalado em sua máquina).

### Pré-requisitos

Antes de fazermos o deploy do Azure Bastion via Az CLI, verifique se você possui:

- Uma conta do Azure com uma assinatura/subscription ativa.

> Caso você não tenha uma subscription, você pode criar uma Trial. Mais informações consulte <a href="https://azure.microsoft.com/en-us/" target="_blank">aqui</a>.
{: .prompt-tip }

#### Passo 1: Instalar o Azure CLI
Primeiro, caso você não tenha Azure CLI instalado, aqui estão os links com a documentação oficial para diferentes sistemas operacionais:

- <a href="https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows" target="_blank">Windows</a>
- <a href="https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-macos" target="_blank">macOS</a>
- <a href="https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux" target="_blank">Linux</a>

#### Passo 2: Verificar a Instalação

- Após a instalação, verifique se o Azure CLI está funcionando corretamente. Abra o powershell em sua máquina e execute o comando abaixo:
```sh
az --version
```

![resource-group](/assets/img/Lab01-Bastion/Bastion-azcli/new/01-az%20--version.png){: .shadow .rounded-10}

- Se você precisar atualizar a versão do Az-CLI, você pode executar o comando a seguir:
```sh
az upgrade
```

![resource-group](/assets/img/Lab01-Bastion/Bastion-azcli/new/02-az%20upgrade.png){: .shadow .rounded-10}

-  Verifique se atualizou para versão mais recente:

```sh
az --version
```

![resource-group](/assets/img/Lab01-Bastion/Bastion-azcli/new/03-versaoatualizadaazcli.png){: .shadow .rounded-10}


#### Passo 3: Faça login com Az CLI

- Com o powershell aberto execute o comando a seguir para logar no Azure.

```sh
az login --use-device-code
```

![resource-group](/assets/img/Lab01-Bastion/Bastion-azcli/new/04-AzLogin.png){: .shadow .rounded-10}

- Abra link e copie o código para logar com suas credenciais.

![resource-group](/assets/img/Lab01-Bastion/Bastion-azcli/new/05-login2.png){: .shadow .rounded-10}

- Depois de ter logado você vai notar no terminal que vai aparecer as subscriptions que você tem acesso.

> Obs.: Se você tiver mais de uma subscription, você pode digitar o comando a seguir para selecionar a subscription desejada.
{:.prompt-info}

```sh
az account set --subscription "<subscription ID or name>"
```

- Depois disso você digita o comando a seguir para validar se realmente a subscription escolhida foi selecionada.

```sh
az account show
```

![resource-group](/assets/img/Lab01-Bastion/Bastion-azcli/new/06-SetandoumaSubscription.png){: .shadow .rounded-10}

> Para mais informações sobre os métodos de login com o Azure CLI, consulte <a href="https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli" target="_blank">aqui</a>.
{: .prompt-tip }

---

#### Passo 4: Deploy dos recursos Base

- Crie um novo resource-group com o comando a seguir.

```sh
az group create --name RG-BastionCLI --location eastus2
```
![resource-group](/assets/img/Lab01-Bastion/Bastion-azcli/new/07-azgroupcreate.png){: .shadow .rounded-10}

  - Explicação dos Parametros:

         az group create: Comando para criar um novo Resource-Group no Azure.

         --name RG-BastionCLI: Define o nome do Resource-Group como "RG-BastionCLI".

         --location eastus2: Define a localização do Resource-Group como "East US 2".


- Crie uma nova Virtual Network + AzureBastionSubnet

> Obs.: Se você tiver já tiver uma VNET criada, você pode criar sua AzureBastionSubnet nela.
{:.prompt-info}

```sh
az network vnet create --name BastionCLIVNet --resource-group RG-BastionCLI --location eastus2 --address-prefix 10.110.0.0/16
```
![azure-automation-account](/assets/img/Lab01-Bastion/Bastion-azcli/new/071-vnet%20criada.png){: .shadow .rounded-20 }

```sh
az network vnet subnet create --resource-group RG-BastionCLI --vnet-name BastionCLIVNet --name AzureBastionSubnet --address-prefix 10.110.20.0/26
```

![azure-automation-account](/assets/img/Lab01-Bastion/Bastion-azcli/new/08-AzureBastionSubnet.png){: .shadow .rounded-20 }

  - Explicação dos Parametros:

         az network vnet create: Comando para criar uma Virtual Network (VNet).

         --name BastionCLIVNet: Define o nome da Virtual Network como "BastionCLIVNet".

         --resource-group RG-BastionCLI: Define o Resource-Group onde a Virtual Network será criada.

         --location eastus2: Define a localização da Virtual Network como "East US 2".

         --address-prefix 10.110.0.0/16: Define o Address-Space da Virtual Network.


         az network vnet subnet create: Comando para criar uma subnet dentro de uma Virtual Network.

         --resource-group RG-BastionCLI: Define o Resource-Group onde a subnet será criada.

         --name AzureBastionSubnet: Define o nome da subnet como "AzureBastionSubnet".

         --address-prefix 10.110.20.0/24: Define o Address-Space da Subnet.

#### Passo 5: Deploy do Azure Bastion

Para que seja possivel fazer o deploy do Azure Bastion, necessitamos ter um Public-IP. Veja abaixo como fazer a criação dele.

```sh
az network public-ip create --resource-group RG-BastionCLI --name BastionCLI-PIP --sku Standard --zone 1 2 3 --location eastus2
```
![azure-automation-account](/assets/img/Lab01-Bastion/Bastion-azcli/new/09-DeployPublicIP.png){: .shadow .rounded-20 }

  - Explicação dos Parametros:

         az network public-ip create: Comando para criar um Public-IP.

         --resource-group RG-BastionCLI: Define o Resource-Group onde o Public-IP será criado.

         --name BastionCLI-PIP: Define o nome do Public-IP como "BastionCLI-PIP".

         --sku Standard: Define o SKU do Public-IP como "Standard", necessário para suporte a zonas de disponibilidade (Availability Zones).

         --zone 1 2 3: Define as Availability Zones (1, 2 e 3) para o Public-IP.

         --location eastus2: Define a localização do Public-IP como "East US2".

> Se quiser saber mais sobre o Public IP, para entender sua Limitações, Preços e SKU, consulte <a href="https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses" target="_blank">aqui</a>.
{: .prompt-tip }

- Agora vamos fazer o Deploy do Azure Bastion utilizando os recursos base que criamos acima.

```sh
az network bastion create --name BastionHost-CLI --resource-group RG-BastionCLI --vnet-name BastionCLIVNet --public-ip-address BastionCLI-PIP --location eastus2 --sku Basic
```

![azure-automation-account](/assets/img/Lab01-Bastion/Bastion-azcli/new/10-DeployBastionAZCLI.png){: .shadow .rounded-20 }

  - Explicação dos Parametros:

         az network bastion create: Comando para criar um Bastion Host na Virtual Network.

         --name BastionHost-CLI: Define o nome do Bastion Host como "BastionHostCLI".

         --resource-group RG-BastionCLI: Define o Resource-Group onde o Bastion será criado.

         --vnet-name BastionCLIVNet: Define o nome da Virtual Network onde o Bastion será implantado.

         --public-ip-address BastionCLI-PIP: Define o Public-IP criado nas etapas anteriores.

         --location eastus2: Define a localização do Bastion como "East US2"

         --sku: Define o SKU do Bastion como "Basic". Nesse caso sem suporte a Availability Zones.

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

