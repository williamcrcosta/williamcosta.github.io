---
layout: post
title: 'Deploy Azure Bastion (Az CLI)'
date: 2024-10-16 08:00:00 -0300
categories: [Network]
tags: [Azure, Network, Bastion, AzCLI]
slug: 'Network'
#image:
#  path: assets/img/01/image.gif
---

Fala galera!👋

**Bem-vindo ao Blog Cloud Insights!** ☁️

Neste post, vamos explorar como implantar o Azure Bastion via Az CLI (Software Instalado em seu notebook) ou Cloud Shell (Interface disponivel no Portal Azure).

## Pré-requisitos

Antes de fazermos o deploy do Azure Bastion via Az CLI, verifique se você possui:

- Uma conta do Azure com uma assinatura/subscription ativa.
- Uma VM Linux ou Windows criada em sua subscription.

## Implantação do Azure Bastion pelo Az CLI

### Passo 1: Acesse o Portal do Azure

1. Faça login no [Portal do Azure](https://portal.azure.com/).

### Passo 2: Deploy dos recursos Base

1. Crie um novo resource-group

> Obs.: Vocês vão notar que no meu caso o Resource-Group já existe.
{:.prompt-info}

![resource-group](/assets/img/Lab01-Bastion/001-ResourceGroup.png){: .shadow .rounded-10}

2. Crie uma nova Virtual Network + AzureBastionSubnet

> Obs.: Se você tiver já tiver uma VNET criada, você pode criar sua AzureBastionSubnet nela.
{:.prompt-info}

| ![azure-automation-account](/assets/img/Lab01-Bastion/02-VirtualNetwork.png){: .shadow .rounded-10 } | ![azure-automation-account](/assets/img/Lab01-Bastion/03-AzureBastionSubnet.png){: .shadow .rounded-10 } |

### Passo 3: Deploy do Azure Bastion

1. Na barra de pesquisa, digite **Bastion** e selecione **Bastion** nos resultados.
2. Clique em **Criar**.

![resource-group](/assets/img/Lab01-Bastion/09-CreateaResource.png){: .shadow .rounded-10}

### Passo 4: Configurar o Bastion

1. **Configurações Básicas**:
   - **Subscription**: Escolha sua Subscription.
   - **Resource-Group**: Selecione o Resource-Group que criamos (ci-bastion)
   - **Nome do Resource**: Forneça um nome para seu host Bastion.
   - **Região**: Escolha a mesma região da sua VNet (East US2).
   - **Availability Zone**: Deixe em none.
   - **Tier**: Selecione Basic. Segue quiser mais explorar mais detalhes sobre os Tiers do Azure Bastion, você pode conferir <a href="https://docs.microsoft.com/en-us/azure/bastion/bastion-overview" target="_blank">aqui</a>.

        - *Ao escolhermos o tier Basic, ficam pré-definidas 2 instances*.

   - **Virtual Network**: Selecione a virtual network criada (ci-bastion-vnet). Voce vai notar que ele vai identificar automaticamente a subnet do AzureBastion.
   - **Public-IP**: Crie um novo IP-Público. Você pode criar um com o nome: "ci-bastion-pip"

![resource-group](/assets/img/Lab01-Bastion/09-CreateaResource2.png){: .shadow .rounded-10}

> Avance para a aba Advanced (Avançado).
{:.prompt-info}


   - **Kerberos Authentication**: Selecione a unica opção disponivel e clique em Review + Create.


![resource-group](/assets/img/Lab01-Bastion/04-DeployAzureBastion02.png){: .shadow .rounded-10}

2. **Revisar e Criar**:
   - Revise suas configurações e clique em **Criar**.

![resource-group](/assets/img/Lab01-Bastion/04-DeployAzureBastion.png){: .shadow .rounded-10}

## Conclusão

Agora você sabe como realizar o deploy do Azure Bastion no Microsoft Azure.

Até a próxima!! 😉

![resource-group](/assets/img/02/cloudinsights3.png){: .shadow .rounded-10}

#CloudInsights #PartiuNuvem #Azure #Tech #Cloud #Security #Network

---

[![Build and Deploy](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml/badge.svg)](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml)

