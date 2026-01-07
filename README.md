# phx — Simple PHP Version Manager

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-blue)
![PHP](https://img.shields.io/badge/php-apt%20managed-purple)

`phx` is a **simple, fast, and compilation-free** PHP version manager, inspired by tools such as `nvm` and `pyenv`.

It works **exclusively with PHP versions already installed on the system**
(`apt`, `brew`, etc.), using *shims* to switch versions automatically
by project or globally.

---

## ✨ Key Features

- ⚡ **Instant version switching**
- 📁 **Version per project** with `.phx-version`
- 🌍 **Global version**
- 🔄 **Automatic switching when entering/leaving directories**
- 🧩 **Compatible with PHP installed via apt**
- 🧼 **Simple implementation in Bash**

---

## 📖 Table of Contents

- [How it works](#-how-it-works)
- [Installation](#-installation)
- [Usage](#-usage)
- [Optional configuration](#️-optional-configuration)
- [Contribution](#-how-to-contribute)
- [License](#-license)

---

## 🤔 How it works

`phx` uses the concept of **shims**:

1. It creates the directory `~/.phx/shims`
2. This directory is added to the beginning of `PATH`
3. Shims are **symbolic links** (`php`, `phpize`, etc.)
4. When changing versions, `phx` only updates these links

The active version is determined by priority:

1. `.phx-version` file in the directory (or above)
2. Global version (`phx global`)
3. System PHP

All of this happens **automatically at each shell prompt**.

---

## 🚀 Installation

### 1️⃣ Clone the repository

```bash
https://github.com/NicolasTeles-Dev/PHX-PHP-version-manager.git
cd PHX
```

### 2️⃣ Clone the repository

```bash
chmod +x phx
sudo cp phx /usr/local/bin/phx
```

#### Check:

```bash
phx --help
```

### 3️⃣ Enable PHX in the shell

#### Run once:

```bash
eval “$(phx init -)”
```

#### Then add this same line to your shell:

```bash
Zsh → ~/.zshrc
Bash → ~/.bashrc
```

#### Add this line:
```bash
eval “$(phx init -)”
```

#### Restart the terminal or run:
```bash
exec zsh
# or
exec bash
```

### ✅ Done

#### PHX is now active.

##### Confirm:

```bash
phx list
```

### 💻 Usage

#### List available versions

```bash
phx list
```

#### Set global version

```bash
phx global 8.3
php -v
```

#### Set version per project

```bash
cd my-project
phx local 8.4
php -v
```

#### This creates a file in the directory.
```bash
phx-version 
``` 

#### View active version

```bash
phx current
```

#### View which PHP is being used

```bash
phx which
```

### ⚙️ Optional configuration

#### By default, phx searches for PHP versions in:

```bash
/usr/bin
```

#### If you use other paths (e.g., Homebrew), set them before init:

```bash
export PHX_BIN_PATHS_DEFAULT="/usr/bin /opt/homebrew/bin"
```

#### You can use multiple paths separated by spaces.

### 🤝 How to contribute

#### Contributions are welcome 🚀
#### 1. Fork the repository
#### 2. Create a branch
```bash
    feature/my-feature
```
#### 3. Commit your changes
#### 4. Open a Pull Request

##### Suggestions and bugs can be submitted via Issues.

### 📜 License

##### MIT License

##### Copyright (c) 2025
#### Nicolas Teles

