# zsh-mod

## 🚀 Installation

### Option 1: Quick Install (Recommended)

Install and configure everything with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/bhardwaj-23/ZSH-MOD/main/zsh-mod.sh | sudo bash
```

### Option 2: Manual Install

Download this script:

```bash
wget https://raw.githubusercontent.com/bhardwaj-23/zsh-mod/refs/heads/main/zsh-mod.sh
```

Make it executable:

```Bash
chmod +x zsh-mod.sh
```

Run it:

```Bash
sudo ./zsh-mod.sh
```

## Why Create ZSH-MOD?

I've always admired the look of Chris Titus's terminal, specifically his `starship.toml` configuration. However, existing installation scripts were "too much" for my needs. They often installed tools I don't use (like Neovim or Zoxide) and were written for Bash, whereas I prefer **ZSH**.

I created `ZSH-MOD` to solve this. It is a lightweight wrapper

- Shell Specificity: Chris’s script (**mybash**) is indeed optimized for Bash. While it can be tweaked, it isn't native to ZSH.
- **Minimalism (No Bloat):** The original script installs a full suite of tools (Neovim, Zoxide, Autojump, custom aliases, etc.). `ZSH-MOD` focuses strictly on **aesthetics**. It installs the Starship theme, Nerd Fonts, and Fastfetch—nothing else. It does not force a specific workflow or editor upon you.
- **Respects your existing config:** It creates backups and only appends to your `.zshrc` rather than overwriting it.
  

### Credits & Acknowledgments

This project stands on the shoulders of giants. A huge thanks to the creators of the tools used in this script:

[Starship](https://github.com/starship/starship): For the cross-shell prompt.

[Fastfetch](https://github.com/fastfetch-cli/fastfetch): For the system information display.

[Chris Titus Tech](https://github.com/ChrisTitusTech/mybash): The `starship.toml` configuration used in this setup is sourced directly from his mybash repository. While his script focuses on Bash, this project adapts that beautiful configuration for a pure ZSH environment without the additional overhead of other tools.

---
