---
layout: post
title: 'Acessando VMs Linux e Windows com Azure Bastion'
description: 'Aprenda a acessar VMs Linux e Windows com Azure Bastion, sem expor RDP ou SSH publicamente.'
date: 2024-10-15 08:30:00 -0300
categories: [Network]
tags: [Azure, Bastion]
slug: 'Access-VMs-AzureBastion'
image:
  path: /assets/img/covers/access-vms-azurebastion.webp
  alt: 'VM Linux acessada pelo Azure Bastion'
---

Fala galera!👋

**Bem-vindo ao Blog Cloud Insights!** ☁️

No post anterior fizemos o deploy do Azure Bastion. Hoje vamos explorar como acessar VMs Linux e Windows com o Azure Bastion de forma segura. Veja como fazer isso:

### Acessando VMs Linux

### Passo 1: Acesse o Portal do Azure e Localize sua VM Linux.

1. Já logado no [Portal do Azure](https://portal.azure.com/).
2. Navegue até o **Grupo de Recursos** onde está sua VM Linux.

![Localização da VM Linux no portal do Azure](/assets/img/Lab01-Bastion/11-LocalizandoVMLnx.png){: .shadow .rounded-10}

### Passo 2: Conecte-se via Bastion

1. Clique na sua máquina virtual Linux para abrir a página de detalhes.
2. No painel de navegação da VM, clique em **Connect**.
3. Selecione **Connect via Bastion**.
4. Uma nova tela será exibida. Insira as credenciais de login da sua VM (nome de usuário e senha).
5. Clique em **Connect**.

![Tela de conexão da VM Linux via Azure Bastion](/assets/img/Lab01-Bastion/05-LogandoVMLinux.png){: .shadow .rounded-10}


![Credenciais de acesso da VM Linux no Azure Bastion](/assets/img/Lab01-Bastion/06-InserindoCredenciaseacessando.png){: .shadow .rounded-10}

### Passo 3: Acesso à VM

Após alguns segundos, uma nova janela será aberta, permitindo que você interaja com a linha de comando da sua VM Linux.

![VM Linux conectada pelo Azure Bastion](/assets/img/Lab01-Bastion/07-VMLinuxLogadaviabastion.png){: .shadow .rounded-10}

---

### Acessando VMs Windows

### Passo 1: Localize sua VM Windows

Repita as etapas 1 e 2 do [Passo 1](https://cloudinsights.com.br/posts/Access-VMs-AzureBastion/#passo-1-acesse-o-portal-do-azure-e-localize-sua-vm-linux) para localizar sua VM Windows.

![Localização da VM Windows no portal do Azure](/assets/img/Lab01-Bastion/10-LocalizandoVMWind.png){: .shadow .rounded-10}

### Passo 2: Conecte-se via Bastion

1. Clique na sua máquina virtual Windows para abrir a página de detalhes.
2. No painel de navegação da VM, clique em **Connect**.
3. Selecione **Connect via Bastion**.

![Credenciais de acesso da VM Windows no Azure Bastion](/assets/img/Lab01-Bastion/12-LogandoVMWind.png){: .shadow .rounded-10}

Repita as etapas 4 e 5 do [Passo 2](https://cloudinsights.com.br/posts/Access-VMs-AzureBastion/#passo-2-conecte-se-via-bastion) para sua VM Windows. Autentique-se com suas credenciais do Windows.

### Passo 3: Acesso à VM

Após alguns segundos, a conexão será estabelecida, e você verá a área de trabalho da sua VM Windows.

![VM Windows conectada pelo Azure Bastion](/assets/img/Lab01-Bastion/08-VMWindowsLogadaviabastion.png){: .shadow .rounded-10}

## Conclusão

Agora você sabe como acessar suas VMs Linux e Windows utilizando o Azure Bastion. Este método proporciona um acesso seguro e fácil, sem a necessidade de expor suas VMs à Internet.

Até a próxima!! 😉

![Logo do Cloud Insights](/assets/img/02/cloudinsights3.png){: .shadow .rounded-10}

#CloudInsights #PartiuNuvem #Azure #Tech #Cloud #Security

---

[![Build and Deploy](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml/badge.svg)](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml)