# phx — Simple PHP Version Manager

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-blue)
![PHP](https://img.shields.io/badge/php-apt%20managed-purple)

`phx` é um gerenciador de versões do PHP **simples, rápido e sem compilação**, inspirado em ferramentas como `nvm` e `pyenv`.

Ele funciona **exclusivamente com versões do PHP já instaladas no sistema**
(`apt`, `brew`, etc.), usando *shims* para alternar versões de forma automática
por projeto ou globalmente.

> Sem builds.  
> Sem downloads.  
> Sem gambiarra no PATH.

---

## ✨ Principais Características

- ⚡ **Troca instantânea de versão**
- 📁 **Versão por projeto** com `.phx-version`
- 🌍 **Versão global**
- 🔄 **Troca automática ao entrar/sair de diretórios**
- 🧩 **Compatível com PHP instalado via apt**
- 🧼 **Implementação simples em Bash**

---

## 📖 Índice

- [Como funciona](#-como-funciona)
- [Instalação](#-instalação)
- [Uso](#-uso)
- [Configuração opcional](#️-configuração-opcional)
- [Contribuição](#-como-contribuir)
- [Licença](#-licença)

---

## 🤔 Como funciona

O `phx` usa o conceito de **shims**:

1. Ele cria o diretório `~/.phx/shims`
2. Esse diretório é adicionado ao início do `PATH`
3. Os shims são **links simbólicos** (`php`, `phpize`, etc.)
4. Ao trocar a versão, o `phx` apenas atualiza esses links

A versão ativa é determinada por prioridade:

1. Arquivo `.phx-version` no diretório (ou acima)
2. Versão global (`phx global`)
3. PHP do sistema

Tudo isso acontece **automaticamente a cada prompt do shell**.

---

## 🚀 Instalação

### 1️⃣ Clonar o repositório

```bash
https://github.com/NicolasTeles-Dev/PHX-PHP-version-manager.git
cd PHX
```

### 2️⃣ Clonar o repositório

```bash
chmod +x phx
sudo cp phx /usr/local/bin/phx
```

#### Verifique:

```bash
phx --help
```

### 3️⃣ Ativar o PHX no shell

#### Execute uma vez:

```bash
eval "$(phx init -)"
```

#### Depois, adicione essa mesma linha ao seu shell:

```bash
Zsh → ~/.zshrc
Bash → ~/.bashrc
```

#### Adicione essa linha:
```bash
eval "$(phx init -)"
```

#### Reinicie o terminal ou execute:
```bash
exec zsh
# ou
exec bash
```

### ✅ Pronto

#### O phx agora está ativo.

##### Confirme:

```bash
phx list
```

### 💻 Uso

#### Listar versões disponíveis

```bash
phx list
```

#### Definir versão global

```bash
phx global 8.3
php -v
```

#### Definir versão por projeto

```bash
cd meu-projeto
phx local 8.4
php -v
```

#### Isso cria um arquivo no diretório.
```bash
phx-version 
``` 

#### Ver versão ativa

```bash
phx current
```

#### Ver qual PHP está sendo usado

```bash
phx which
```

### ⚙️ Configuração opcional

#### Por padrão, o phx procura versões do PHP em:

```bash
/usr/bin
```

#### Se você usa outros caminhos (ex: Homebrew), defina antes do init:

```bash
export PHX_BIN_PATHS_DEFAULT="/usr/bin /opt/homebrew/bin"
```

#### Você pode usar múltiplos caminhos separados por espaço.

### 🤝 Como contribuir

#### Contribuições são bem-vindas 🚀
#### 1.Faça um fork
#### 2.Crie uma branch
```bash
    feature/minha-feature
```
#### 3.Commit suas alterações
#### 4.Abra um Pull Request

##### Sugestões e bugs podem ser enviados via Issues.

### 📜 Licença

##### Licença MIT

##### Copyright (c) 2025
#### Nicolas Teles
