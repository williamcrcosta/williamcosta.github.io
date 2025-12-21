# 🛠️ Guia de Desenvolvimento - Cloud Insights

Este documento contém informações técnicas para desenvolvimento e manutenção do site.

---

## 📦 Instalação Detalhada

### Windows

1. **Instalar Ruby:**
   - Baixe o [RubyInstaller](https://rubyinstaller.org/downloads/) (versão com DevKit)
   - Durante a instalação, marque "Add Ruby executables to your PATH"
   - Execute `ridk install` ao final da instalação

2. **Verificar instalação:**
   ```powershell
   ruby --version
   gem --version
   ```

3. **Instalar Bundler:**
   ```powershell
   gem install bundler
   ```

4. **Clonar repositório e instalar dependências:**
   ```powershell
   git clone https://github.com/williamcrcosta/williamcosta.github.io.git
   cd williamcosta.github.io
   bundle install
   ```

### Linux/macOS

```bash
# Instalar Ruby (usando rbenv ou rvm recomendado)
# Ubuntu/Debian:
sudo apt-get install ruby-full build-essential zlib1g-dev

# macOS (com Homebrew):
brew install ruby

# Instalar Bundler
gem install bundler

# Clonar e instalar
git clone https://github.com/williamcrcosta/williamcosta.github.io.git
cd williamcosta.github.io
bundle install
```

---

## 🚀 Comandos de Desenvolvimento

### Servidor Local

```bash
# Servidor básico
bundle exec jekyll serve

# Com live reload (recarrega automaticamente no navegador)
bundle exec jekyll serve --livereload

# Com rascunhos (posts em _drafts/)
bundle exec jekyll serve --drafts

# Modo incremental (build mais rápido)
bundle exec jekyll serve --incremental

# Com host específico (útil para testar em outros dispositivos na rede)
bundle exec jekyll serve --host 0.0.0.0

# Porta customizada
bundle exec jekyll serve --port 4001
```

### Build

```bash
# Build padrão (desenvolvimento)
bundle exec jekyll build

# Build de produção
JEKYLL_ENV=production bundle exec jekyll build

# Limpar arquivos gerados
bundle exec jekyll clean
```

### Gems e Dependências

```bash
# Atualizar gems
bundle update

# Atualizar gem específica
bundle update jekyll-theme-chirpy

# Verificar gems desatualizadas
bundle outdated

# Instalar gems (após modificar Gemfile)
bundle install
```

---

## 📁 Estrutura Detalhada

```
williamcosta.github.io/
│
├── _config.yml                 # ⚙️ Configurações principais do Jekyll
│   └── Define: título, URL, tema, plugins, SEO, analytics
│
├── _data/                      # 📊 Dados estruturados (YAML)
│   ├── authors.yml            # Informações de autores
│   ├── contact.yml            # Links de contato/redes sociais
│   ├── share.yml              # Configuração de botões de compartilhamento
│   └── locales/               # Traduções (i18n)
│       └── en.yml
│
├── _plugins/                   # 🔌 Plugins Ruby personalizados
│   └── posts-lastmod-hook.rb  # Hook para última modificação de posts
│
├── _posts/                     # 📝 Artigos do blog
│   ├── 2024/                  # Organizados por ano
│   │   └── YYYY-MM-DD-titulo.md
│   └── 2025/
│       └── YYYY-MM-DD-titulo.md
│
├── _tabs/                      # 📑 Páginas estáticas (navegação)
│   ├── about.md               # Página "Sobre"
│   ├── archives.md            # Arquivo de posts
│   ├── categories.md          # Lista de categorias
│   ├── tags.md                # Lista de tags
│   └── [outras páginas]
│
├── _site/                      # 🏗️ Site gerado (não versionar)
│   └── [arquivos HTML/CSS/JS compilados]
│
├── assets/                     # 🎨 Assets estáticos
│   ├── img/                   # Imagens
│   │   ├── profile.png       # Avatar do perfil
│   │   └── [outras imagens]
│   ├── css/                   # CSS customizado (se houver)
│   └── js/                    # JavaScript customizado (se houver)
│
├── docs/                       # 📚 Documentação interna
│   └── planejamento/          # Planejamento de posts futuros
│
├── scripts/                    # 🔧 Scripts auxiliares
│   └── powershell/            # Scripts PowerShell
│
├── .github/                    # 🤖 GitHub Actions e configurações
│   └── workflows/
│       ├── pages-deploy.yml   # CI/CD para deploy automático
│       └── test-dev-qa.yml    # Testes para branch dev-qa
│
├── _backup/                    # 🗄️ Backups locais (não versionado)
│
├── .gitignore                  # 🚫 Arquivos ignorados pelo Git
├── Gemfile                     # 💎 Dependências Ruby
├── Gemfile.lock               # 🔒 Lock de versões de gems
├── README.md                   # 📖 Documentação principal
└── DEVELOPMENT.md             # 🛠️ Este arquivo
```

---

## 🎨 Tema Chirpy

### Estrutura de Layout

- `post` - Layout padrão para posts
- `page` - Layout para páginas estáticas
- `home` - Layout da página inicial
- `archives` - Lista de posts
- `categories` - Categorias
- `tags` - Tags

### Customizações Comuns

#### Modificar Avatar

Substitua o arquivo: `assets/img/profile.png`

#### Adicionar Favicon

Coloque os favicons em: `assets/img/favicons/`

Arquivos necessários:
- `favicon.ico`
- `favicon-16x16.png`
- `favicon-32x32.png`
- `apple-touch-icon.png`
- `android-chrome-192x192.png`
- `android-chrome-512x512.png`

#### Customizar Cores

Crie/edite: `assets/css/main.scss`

```scss
---
---
@import "main";

// Sobrescreva variáveis aqui
:root {
  --link-color: #007bff;
  --heading-color: #2c3e50;
}
```

---

## 📝 Front Matter Completo

### Para Posts

```yaml
---
layout: post                          # Layout (sempre 'post')
title: 'Título do Post'              # Título principal
date: 2025-01-20 10:00:00 -0300      # Data e timezone
categories: [Categoria, Subcategoria] # Categorias (máx 2 níveis)
tags: [tag1, tag2, tag3]             # Tags (ilimitadas)
slug: 'titulo-do-post'               # Slug personalizado (opcional)
author: nome_autor                    # Autor (de _data/authors.yml)
pin: true                             # Fixar post no topo
math: true                            # Habilitar MathJax
mermaid: true                         # Habilitar diagramas Mermaid
image:                                # Imagem de capa
  path: /assets/img/pasta/imagem.png
  alt: Descrição da imagem
  width: 800
  height: 500
toc: true                             # Tabela de conteúdos
comments: true                        # Habilitar comentários
---
```

### Para Páginas

```yaml
---
layout: page
title: Título da Página
icon: fas fa-info-circle  # Ícone FontAwesome
order: 1                   # Ordem na navegação
---
```

---

## 🐛 Troubleshooting

### Erro: "Could not find gem 'jekyll'"

```bash
bundle install
```

### Erro: "Permission denied"

```bash
# Linux/macOS - use sudo ou instale Ruby via rbenv/rvm
# Windows - execute terminal como Administrador
```

### Porta 4000 já em uso

```bash
# Encontrar processo (Windows)
netstat -ano | findstr :4000
taskkill /PID [número_do_pid] /F

# Ou use outra porta
bundle exec jekyll serve --port 4001
```

### Build muito lento

```bash
# Use incremental build
bundle exec jekyll serve --incremental

# Ou desabilite plugins temporariamente no _config.yml
```

### Alterações não aparecem

```bash
# Limpe o cache
bundle exec jekyll clean

# Verifique se o arquivo não está em .gitignore
# Verifique o front matter (YAML válido?)
```

---

## 🧪 Testes

### Verificar Links Quebrados

```bash
# Após o build
bundle exec htmlproofer ./_site --disable-external
```

### Validar HTML

Use [W3C Validator](https://validator.w3.org/)

---

## 📊 Performance

### Otimizar Imagens

- Use WebP quando possível
- Comprima imagens antes de fazer upload
- Tamanho recomendado para posts: 800-1200px largura

### Ferramentas Úteis

- [TinyPNG](https://tinypng.com/) - Compressão de imagens
- [Squoosh](https://squoosh.app/) - Compressão e conversão
- [Google PageSpeed Insights](https://pagespeed.web.dev/) - Análise de performance

---

## 🔄 Workflow de Branches

```
main (produção)
  ↑
dev-qa (homologação)
  ↑
feature/nome-da-feature (desenvolvimento)
```

### Comandos Git

```bash
# Criar feature branch
git checkout dev-qa
git pull origin dev-qa
git checkout -b feature/nova-funcionalidade

# Desenvolver...

# Fazer merge em dev-qa
git checkout dev-qa
git merge feature/nova-funcionalidade

# Testar em dev-qa...

# Fazer merge em main
git checkout main
git merge dev-qa
git push origin main
```

---

## 📚 Recursos Úteis

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [Chirpy Theme Docs](https://github.com/cotes2020/jekyll-theme-chirpy/wiki)
- [Markdown Guide](https://www.markdownguide.org/)
- [Liquid Template Language](https://shopify.github.io/liquid/)
- [GitHub Pages Docs](https://docs.github.com/en/pages)

---

## 💡 Dicas

1. **Use `--livereload`** para ver mudanças em tempo real
2. **Organize posts por ano** em subpastas
3. **Otimize imagens** antes de commitar
4. **Teste localmente** antes de fazer push
5. **Use branches** para features/experimentos
6. **Documente mudanças** nos commits

---

**Última atualização:** Dezembro 2025
