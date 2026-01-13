# phx — Simple PHP Version Manager

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-blue)
![PHP](https://img.shields.io/badge/php-apt%20managed-purple)

`phx` is a **simple, fast, and compilation-free** PHP version manager, inspired by tools such as `nvm` and `pyenv`.

It works **exclusively with PHP versions already installed on your system** (`apt`, `brew`, etc.), using *shims* to automatically switch versions by project or globally.

---

## ✨ Key Features

- ⚡ **Instant version switching**
- 📁 **Per-project version** with `.phx-version` files
- 🌍 **Global version**
- 🔄 **Automatic switching when entering/leaving directories**
- 🧩 **Compatible with PHP installed via `apt`**
- 🧼 **Simple and clean implementation in Bash**

---

## 📖 Table of Contents

- [How it Works](#-how-it-works)
- [Installation](#-installation)
- [Usage](#-usage)
- [Optional Configuration](#️-optional-configuration)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🤔 How it Works

`phx` uses the concept of **shims**:

1.  It creates a `~/.phx/shims` directory.
2.  This directory is added to the beginning of your `PATH`.
3.  The shims are **symbolic links** (e.g., `php`, `phpize`) to the actual PHP binaries.
4.  When you switch versions, `phx` simply updates these symbolic links.

The active version is determined by this priority:

1.  `.phx-version` file in the current directory (or any parent directory).
2.  Global version set with `phx global`.
3.  System's default PHP.

This check and switch happen **automatically at each new shell prompt**.

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/NicolasTeles-Dev/PHX-PHP-version-manager.git
cd PHX-PHP-version-manager
```

### 2. Install the `phx` Command

This will make the `phx` command available system-wide.

```bash
chmod +x phx.sh
sudo mv phx.sh /usr/local/bin/phx
```

Verify the installation by running:

```bash
phx --help
```

### 3. Enable `phx` in Your Shell

Add the following line to your shell's configuration file (`~/.bashrc`, `~/.zshrc`, etc.). This will enable the automatic version switcher.

```bash
eval "$(phx init -)"
```

After adding the line, restart your terminal or reload the configuration with `exec bash` or `exec zsh`.

### ✅ Done!

`phx` is now active. You can confirm by listing the available PHP versions:

```bash
phx list
```

---

## 💻 Usage

#### List Available Versions

```bash
phx list
```

#### Set the Global Version

This version will be used by default in any directory without a specific version set.

```bash
phx global 8.3
php -v
```

#### Set a Local (Per-Project) Version

This creates a `.phx-version` file in the current directory, which overrides the global setting.

```bash
cd my-project/
phx local 8.2
php -v
```

`phx` will automatically use the version specified in `.phx-version` whenever you are in this directory or any of its subdirectories.

#### Check the Current Active Version

```bash
phx current
```

#### See Which PHP Binary is Being Used

```bash
phx which
```

#### Display the `phx` Version

```bash
phx version
```

---

## ⚙️ Optional Configuration

By default, `phx` searches for PHP executables in `/usr/bin`. If you have PHP versions installed in other locations (e.g., Homebrew, custom directories), you can add them by setting the `PHX_BIN_PATHS_DEFAULT` environment variable.

Set it **before** the `phx init` line in your shell configuration file (`.bashrc` or `.zshrc`).

```bash
# Example for Homebrew on macOS
export PHX_BIN_PATHS_DEFAULT="/usr/bin /opt/homebrew/bin"

# Example for multiple custom paths
export PHX_BIN_PATHS_DEFAULT="/usr/bin /usr/local/bin /path/to/php/versions"

eval "$(phx init -)"
```

You can include multiple paths separated by spaces.

---

## 🤝 Contributing

Contributions are welcome! 🚀

1.  **Fork** the repository.
2.  **Create a branch** for your feature (`feature/my-feature`).
3.  **Commit** your changes.
4.  **Open a Pull Request**.

Suggestions and bug reports can be submitted via the [Issues](https://github.com/NicolasTeles-Dev/PHX-PHP-version-manager/issues) page.

---

## 📜 License

This project is licensed under the MIT License.

**Copyright (c) 2024 Nicolas Teles**
