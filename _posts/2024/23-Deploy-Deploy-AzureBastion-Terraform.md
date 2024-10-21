---
layout: post
title: 'Deploy Azure Bastion (Terraform)'
date: 2024-10-17 08:30:00 -0300
categories: [Network]
tags: [Azure, Network, Bastion, Terraform]
slug: 'Deploy-Bastion-Terraform'
#image:
#  path: assets/img/01/image.gif
---

# Como Fazer o Deploy do Azure Bastion através do Terraform Enterprise (TFE)

Olá, pessoal! 👋 Hoje vamos aprender como realizar o deploy do Azure Bastion usando Terraform Enterprise (TFE). Este guia vai te guiar passo a passo desde a criação dos recursos até a configuração completa do Azure Bastion.

## 1. Configurar o Workspace no TFE

Primeiro, crie um novo workspace no Terraform Enterprise para organizar sua infraestrutura.

## 2. Inicializar o Terraform

No diretório onde está seu arquivo de configuração do Terraform (`main.tf`), inicialize o Terraform:

```sh
terraform init
```

```hcl
resource "azurerm_resource_group" "example" {
  name     = "MyResourceGroup"
  location = "East US"
}
```

```hcl
resource "azurerm_resource_group" "example" {
  name     = "MyResourceGroup"
  location = "East US"
}
```