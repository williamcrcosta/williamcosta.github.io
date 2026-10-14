# ☁️ Cloud Insights

![Build and Deploy](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml/badge.svg)

> Blog técnico sobre Cloud Computing, Azure, DevOps, Terraform e tecnologias de infraestrutura como código.

🌐 **Site:** [https://cloudinsights.com.br](https://cloudinsights.com.br)

---

## 📖 Sobre o Projeto

**Cloud Insights** é um blog pessoal criado para compartilhar conhecimentos, tutoriais práticos e insights sobre soluções em nuvem, com foco em Microsoft Azure, Infrastructure as Code (IaC), e boas práticas de DevOps.

### 🎯 Objetivo

- Compartilhar conhecimento técnico de forma prática e acessível
- Documentar laboratórios e cenários reais
- Ajudar profissionais em sua jornada de aprendizado em Cloud

---

## 🛠️ Tecnologias Utilizadas

- **[Jekyll](https://jekyllrb.com/)** - Gerador de sites estáticos
- **[Chirpy Theme](https://github.com/cotes2020/jekyll-theme-chirpy)** - Tema Jekyll responsivo e moderno
- **[GitHub Pages](https://pages.github.com/)** - Hospedagem do site
- **[GitHub Actions](https://github.com/features/actions)** - CI/CD para deploy automático
- **[Giscus](https://giscus.app/)** - Sistema de comentários baseado em GitHub Discussions
- **[Google Analytics](https://analytics.google.com/)** - Análise de tráfego

---

## 📁 Estrutura do Projeto

```
williamcosta.github.io/
├── _config.yml              # Configurações principais do Jekyll
├── _data/                   # Dados estruturados (autores, contatos, etc.)
│   ├── authors.yml
│   ├── contact.yml
│   └── share.yml
├── _plugins/                # Plugins personalizados do Jekyll
├── _posts/                  # Artigos do blog organizados por ano
│   ├── 2024/
│   └── 2025/
├── _tabs/                   # Páginas estáticas (About, Archives, etc.)
├── assets/                  # Assets estáticos (imagens, CSS, JS)
│   └── img/
├── docs/                    # Documentação interna e planejamento
├── scripts/                 # Scripts auxiliares (PowerShell, etc.)
├── .github/workflows/       # GitHub Actions para CI/CD
├── Gemfile                  # Dependências Ruby/Jekyll
└── README.md               # Este arquivo
```

---

## 🚀 Como Rodar Localmente

### Pré-requisitos

- **Ruby** (versão 3.0 ou superior)
- **Bundler** (gerenciador de gems Ruby)
- **Git**

### Instalação

1. **Clone o repositório:**

```bash
git clone https://github.com/williamcrcosta/williamcosta.github.io.git
cd williamcosta.github.io
```

2. **Instale as dependências:**

```bash
bundle install
```

3. **Execute o servidor local:**

```bash
bundle exec jekyll serve
```

4. **Acesse no navegador:**

```
http://localhost:4000
```

### Comandos Úteis

```bash
# Limpar cache e arquivos gerados
bundle exec jekyll clean

# Build do site (sem servir)
bundle exec jekyll build

# Servir com live reload
bundle exec jekyll serve --livereload

# Servir com rascunhos
bundle exec jekyll serve --drafts

# Build para produção
JEKYLL_ENV=production bundle exec jekyll build
```

---

## ✍️ Como Criar um Novo Post

1. **Crie um arquivo na pasta `_posts/YYYY/`** com o formato:
   ```
   YYYY-MM-DD-titulo-do-post.md
   ```

2. **Adicione o Front Matter no início do arquivo:**

```yaml
---
layout: post
title: 'Título do Post'
date: YYYY-MM-DD HH:MM:SS -0300
categories: [Categoria Principal]
tags: [tag1, tag2, tag3]
slug: 'titulo-do-post'
image:
  path: /assets/img/pasta/imagem.png
  alt: Descrição da imagem
---
```

3. **Escreva o conteúdo em Markdown**

4. **Teste localmente antes de publicar:**
   ```bash
   bundle exec jekyll serve --drafts
   ```

5. **Faça commit e push:**
   ```bash
   git add _posts/YYYY/YYYY-MM-DD-titulo-do-post.md
   git commit -m "feat: adiciona post sobre [assunto]"
   git push origin main
   ```

---

## 🎨 Personalização

### Modificar Informações do Site

Edite o arquivo `_config.yml` para alterar:
- Título e descrição do site
- Informações do autor
- Links de redes sociais
- Configurações de SEO
- Google Analytics ID
- Sistema de comentários

### Adicionar Nova Página

1. Crie um arquivo `.md` na pasta `_tabs/`
2. Adicione o Front Matter com `layout: page`
3. A página será automaticamente adicionada à navegação

---

## 🌍 Deploy

O site é automaticamente deployado no GitHub Pages através do GitHub Actions sempre que há push na branch `main`.

### Workflow de Deploy

1. Push para `main` → GitHub Actions é acionado
2. Build do Jekyll com ambiente de produção
3. Deploy automático no GitHub Pages
4. Site atualizado em: [https://cloudinsights.com.br](https://cloudinsights.com.br)

---

## 🤝 Contribuindo

Encontrou um erro ou tem sugestões? Fique à vontade para:

1. Abrir uma [Issue](https://github.com/williamcrcosta/williamcosta.github.io/issues)
2. Criar um Pull Request com melhorias
3. Entrar em contato pelas redes sociais

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 📬 Contato

- **LinkedIn:** [williamcrpc](https://www.linkedin.com/in/williamcrpc/)
- **GitHub:** [williamcrcosta](https://github.com/williamcrcosta)
- **Site:** [cloudinsights.com.br](https://cloudinsights.com.br)

---

<div align="center">

**Feito com ☁️ e 💙 por William Costa**

⭐ Se este projeto te ajudou, considere dar uma estrela!

</div>