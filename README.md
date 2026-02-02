# Mac Bootstrap

A one-command setup script to configure a fresh macOS machine: install Homebrew, core CLI tools, apps, Zsh + Oh My Zsh (plugins and Spaceship theme), and optional dev environments.

## What it does

- **Homebrew** — Installs Homebrew if missing and adds it to your PATH
- **Brewfile** — Installs packages and casks (git, zsh, vim, wget, jq, yq, python, awscli, kubectl, helm, k9s, Chrome, Warp, Cursor, Raycast, iTerm2, Spotify, Zoom, Shottr, Fira Code, etc.; Notion, Sublime, Docker and others are commented out)
- **Zsh + Oh My Zsh** — If zsh is installed (via Brewfile), installs Oh My Zsh, then:
  - **Plugins:** [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
  - **Theme:** [Spaceship Prompt](https://github.com/spaceship-prompt/spaceship-prompt)
  - **Config:** Copies `dotfiles/.zshrc` to `~/.zshrc` and applies [Scott Spence–style](https://scottspence.com/posts/my-updated-zsh-config-2025#adding-plugins-and-themes) settings (autosuggest, spaceship). If zsh is not installed, prints a message to add `brew "zsh"` to the Brewfile.
- **macOS defaults** — Optional script (commented out by default): Dark Mode, no auto light/dark switch, reduce transparency, Finder (show hidden files), fast key repeat, auto-remove Trash after 30 days, Dock autohide; restarts Dock, Finder, SystemUIServer
- **Dev environments** — Optional Python, Node, and AWS tooling (scripts are commented out by default)
- **Dotfiles** — `.zshrc` is applied during the Zsh setup above; `.gitconfig` copy is optional (commented out in `bootstrap.sh`)
- **Logs** — Each run is logged under `logs/` in the repo; older logs are pruned (keeps last 10)

## Requirements

- macOS
- Internet connection
- Git (Xcode Command Line Tools: `xcode-select --install` if needed)

## Getting started

**1. Clone the repository**

```bash
git clone https://github.com/YOUR_USERNAME/mac-bootstrap.git ~/mac-bootstrap
cd ~/mac-bootstrap
```

(Replace `YOUR_USERNAME` with your GitHub username, or use SSH: `git clone git@github.com:YOUR_USERNAME/mac-bootstrap.git`)

**2. Make the bootstrap script executable**

```bash
chmod +x bootstrap.sh
```

**3. Run the bootstrap**

```bash
./bootstrap.sh
```

The script uses `set -e` and logs every command. If something fails, check the latest log in the repo’s `logs/` folder (e.g. `~/mac-bootstrap/logs/` when cloned there).

## Project layout

| Path | Description |
|------|-------------|
| `bootstrap.sh` | Main entry point; runs all setup steps (Homebrew, Brewfile, Zsh + Oh My Zsh + plugins/theme, optional steps) |
| `Brewfile` | Homebrew formulae and casks; includes `zsh` (edit to add/remove packages) |
| `validate.sh` | Quick check that key tools are installed |
| `macos/defaults.sh` | macOS UI & system preferences (Dark Mode, Finder, keyboard, storage, Dock) — optional |
| `dev/python.sh` | Python/pyenv setup (optional) |
| `dev/node.sh` | Node/nvm setup (optional) |
| `dev/aws.sh` | AWS CLI extras (e.g. session-manager-plugin) — optional |
| `dotfiles/` | `.zshrc` is copied to `~/.zshrc` during Zsh setup; `.gitconfig`, `.vimrc` optional |
| `mas-apps.txt` | Placeholder for Mac App Store app list (e.g. for `mas`) |
| `logs/` | Bootstrap run logs (auto-created in repo, old ones trimmed) |

## Customization

1. **Packages** — Edit `Brewfile`: uncomment or add `brew` / `cask` lines, then run `./bootstrap.sh` again or `brew bundle --file=./Brewfile`.
2. **macOS defaults** — Uncomment the `macos/defaults.sh` line in `bootstrap.sh` if you want those settings applied.
3. **Dev setup** — Uncomment the `dev/*.sh` lines in `bootstrap.sh` for Python, Node, and AWS tooling.
4. **Dotfiles** — `~/.zshrc` is set from `dotfiles/.zshrc` during Zsh + Oh My Zsh setup. To copy `.gitconfig`, uncomment the `cp "$SCRIPT_DIR/dotfiles/.gitconfig"` line in the “Optional steps” section of `bootstrap.sh`.

## Validation

After bootstrap (or anytime):

```bash
./validate.sh
```

This checks that `git`, `brew`, `zsh`, `python`, `kubectl`, and `aws` (awscli) are installed, and reports whether Oh My Zsh is present. Adjust `validate.sh` if you add or remove tools from the Brewfile.

## Notes

- Homebrew is installed to `/opt/homebrew` on Apple Silicon and `/usr/local` on Intel; the script detects this and configures your shell.
- The script works from any directory (paths are based on the script’s location). Logs go to `logs/` inside the repo.
- Log files are named `bootstrap-YYYY-MM-DD_HH-MM-SS.log`; only the 10 most recent are kept.
- After Zsh setup, run `source ~/.zshrc` or open a new terminal; to set zsh as default: `chsh -s $(which zsh)`.
