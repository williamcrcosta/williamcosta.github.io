---
layout: post
title: 'Deploy Azure Bastion (Portal Azure)'
date: 2024-10-14 21:43:00 -0300
categories: [Network]
tags: [Azure, Network, Bastion]
slug: 'Network'
#image:
#  path: assets/img/01/image.gif
---

Fala galera!👋

**Bem-vindo ao Blog Cloud Insights!** ☁️

Em nosso primeiro post, vamos explorar como implantar e utilizar o Azure Bastion via Portal.

### Azure Bastion

**O que é**:
Azure Bastion é um serviço gerenciado do Azure que permite acesso seguro a máquinas virtuais (VMs) via RDP e SSH, diretamente do portal do Azure, sem a necessidade de endereços IP públicos.

## Por Que Usar o Azure Bastion?

O Azure Bastion elimina a necessidade de endereços IP públicos em suas VMs, reduzindo a superfície de ataque. Ele também facilita o acesso às VMs diretamente pelo portal do Azure, sem necessidade de configurar VPNs ou outros métodos de acesso remoto.

**Para que serve**:
- **Acesso Seguro**: Conexões seguras sem expor as VMs à Internet.
- **Simplicidade**: Conexão direta pelo portal do Azure, sem configuração complexa de rede.
- **Gerenciamento Centralizado**: Facilita o acesso a múltiplas VMs sem comprometer a segurança.

### Cenários de Uso
- **Ambientes de Produção**: Para acesso seguro a VMs críticas.
- **Desenvolvimento e Teste**: Para equipes que precisam acessar VMs de forma rápida e segura.
- **Acesso Remoto Temporário**: Para colaboradores externos sem complicações de rede.


## Pré-requisitos

Antes de fazermos o deploy do Azure Bastion, verifique se você possui:

- Uma conta do Azure com uma assinatura/subscription ativa.

## Implantação do Azure Bastion pelo Portal do Azure

### Passo 1: Acesse o Portal do Azure

1. Faça login no [Portal do Azure](https://portal.azure.com/).

<br>

### Passo 2: Deploy dos recursos Base

<br>

1. Crie um novo resource-group

<br>

<div style="text-align: center;">
            Obs.: Vocês vão notar que no meu caso o Resource-Group já existe.
</div>

<div style="text-align: center;">
    <img src="../../assets/img/Lab01-Bastion/001-ResourceGroup.png" alt="Imagem 1" style="width: 50%;"/>
</div>

<br>
<br>

2. Crie uma nova Virtual Network + AzureBastionSubnet



<div style="display: flex; justify-content: center; align-items: center; align-items: center; margin: 38px;">
<img src="../../assets/img/Lab01-Bastion/02-VirtualNetwork.png" alt="Imagem 1" style="display:inline-block; width:35%; margin-right: 5px;"/>
<img src="../../assets/img/Lab01-Bastion/03-AzureBastionSubnet.png" alt="Imagem 2" style="display:inline-block; width:70%; margin-right: 5px;"/>
</div>


### Passo 3: Deploy do Azure Bastion

1. Na barra de pesquisa, digite **Bastion** e selecione **Bastion** nos resultados.
2. Clique em **Criar**.


<div style="text-align: center;">
    <img src="../../assets/img/Lab01-Bastion/09-CreateaResource.png" alt="Imagem 1" style="width: 50%;"/>
</div>

<br>

### Passo 4: Configurar o Bastion

1. **Configurações Básicas**:
   - **Subscription**: Escolha sua Subscription.
   - **Resource-Group**: Selecione o Resource-Group que criamos (ci-bastion)
   - **Nome do Resource**: Forneça um nome para seu host Bastion.
   - **Região**: Escolha a mesma região da sua VNet (East US2).
   - **Availability Zone**: Deixe em none.
   - **Tier**: Selecione Basic. Segue quiser mais explorar mais detalhes sobre os Tiers do Azure Bastion, voce pode conferir [aqui](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview).

        - *Ao escolhermos o tier Basic, ficam pré-definidas 2 instances*.

   - **Virtual Network**: Selecione a virtual network criada (ci-bastion-vnet). Voce vai notar que ele vai identificar automaticamente a subnet do AzureBastion.
   - **Public-IP**: Crie um novo IP-Público. Você pode criar um com o nome: "ci-bastion-pip"

<br>

<div style="text-align: center;">
    <img src="../../assets/img/Lab01-Bastion/09-CreateaResource2.png" alt="Imagem 1" style="width: 50%;"/>
</div>

<div style="text-align: center;">
            Avance para a aba Advanced (Avançado)
</div>

<br>

   - **Kerberos Authentication**: Selecione a unica opção disponivel e clique em Review + Create.

<br>

<div style="text-align: center;">
    <img src="../../assets/img/Lab01-Bastion/04-DeployAzureBastion02.png" alt="Imagem 1" style="width: 50%;"/>
</div>

<br>
<br>

2. **Revisar e Criar**:
   - Revise suas configurações e clique em **Criar**.

<br>
<br>
<div style="text-align: center;">
    <img src="../../assets/img/Lab01-Bastion/04-DeployAzureBastion.png" alt="Imagem 1" style="width: 50%;"/>
</div>

<br>

## Conclusão

Agora você sabe como realizar o deploy do Azure Bastion no Microsoft Azure.

Até a próxima!! 😉


<div style="text-align: center;">
    <img src="../../assets/img/02/cloudinsights3.png" alt="Imagem 1" style="width: 50%;"/>
</div>

#CloudInsights #PartiuNuvem #Azure #Tech #Cloud #Security #Network

---

[![Build and Deploy](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml/badge.svg)](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml)

Até a próxima!! 😉
