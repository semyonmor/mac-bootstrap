#!/bin/bash
# Exit the script immediately if any command fails
set -e
# Log every executed command (disable for less verbose: comment out set -x)
# set -x

# --- Paths (script works from any current directory) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bootstrap-$(date +%Y-%m-%d_%H-%M-%S).log"

# --- Logging setup ---
exec > >(tee "$LOG_FILE") 2>&1
trap 'echo ""; echo "[ERROR] Bootstrap failed at line $LINENO. Check log: $LOG_FILE"; exit 1' ERR

log_step() {
  echo ""
  echo "========== $1 =========="
}

# --- Log header ---
echo "=============================================="
echo "  Mac Bootstrap — $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Script: $SCRIPT_DIR/bootstrap.sh"
echo "  Log:   $LOG_FILE"
echo "=============================================="

log_step "Bootstrap started at $(date)"
log_step "Starting Mac bootstrap..."

# ------------------------------------------------------------------------------
# Homebrew
# ------------------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
  log_step "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    BREW_BIN="/opt/homebrew/bin/brew"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    BREW_BIN="/usr/local/bin/brew"
  else
    echo "Homebrew not found in expected locations"
    exit 1
  fi

  eval "$($BREW_BIN shellenv)"
  BREW_SHELLENV_LINE="eval \"\$($BREW_BIN shellenv)\""

  if ! grep -qs "brew shellenv" ~/.zprofile 2>/dev/null; then
    echo "$BREW_SHELLENV_LINE" >> ~/.zprofile
    echo "Added Homebrew to PATH in ~/.zprofile"
  else
    echo "Homebrew PATH already in ~/.zprofile"
  fi
fi

log_step "Updating Homebrew..."
brew update

log_step "Checking system health (brew doctor)..."
brew doctor || { echo "[WARN] brew doctor reported issues; continuing anyway."; }

log_step "Installing packages from Brewfile..."
brew bundle --file="$SCRIPT_DIR/Brewfile"

log_step "Cleaning up old downloads and versions..."
brew cleanup

# ------------------------------------------------------------------------------
# Zsh + Oh My Zsh + plugins & theme (Scott Spence style)
# https://sourabhbajaj.com/mac-setup/iTerm/zsh.html
# https://scottspence.com/posts/my-updated-zsh-config-2025#adding-plugins-and-themes
# ------------------------------------------------------------------------------
log_step "Checking zsh and Oh My Zsh..."

if command -v zsh &>/dev/null; then
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "Oh My Zsh is already installed at ~/.oh-my-zsh"
  else
    echo "Installing Oh My Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    echo "Oh My Zsh installed. Run 'source ~/.zshrc' or open a new terminal. To set zsh as default: chsh -s \$(which zsh)"
  fi

  # Install plugins and Spaceship theme (Scott Spence config)
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    log_step "Oh My Zsh: plugins and theme (Scott Spence style)..."

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
      echo "Installing zsh-autosuggestions..."
      git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    else
      echo "zsh-autosuggestions already installed"
    fi

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
      echo "Installing zsh-syntax-highlighting..."
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    else
      echo "zsh-syntax-highlighting already installed"
    fi

    if [[ ! -f "$ZSH_CUSTOM/themes/spaceship.zsh-theme" ]]; then
      echo "Installing Spaceship prompt theme..."
      git clone --depth=1 https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
      ln -sf "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
    else
      echo "Spaceship theme already installed"
    fi

    # Use repo .zshrc before patching (so changes apply on top of dotfiles config)
    if [[ -f "$SCRIPT_DIR/dotfiles/.zshrc" ]]; then
      cp "$SCRIPT_DIR/dotfiles/.zshrc" ~/.zshrc
      echo "Copied dotfiles/.zshrc to ~/.zshrc"
    fi

    # Patch ~/.zshrc: theme, plugins, and Scott Spence autosuggest/spaceship settings
    if [[ -f "$HOME/.zshrc" ]]; then
      echo "Applying Scott Spence style (theme, plugins, autosuggest & spaceship settings) to ~/.zshrc..."
      sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="spaceship"/' "$HOME/.zshrc"
      sed -i.bak 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
      # Remove backup only if sed created one (macOS sed -i.bak creates backup)
      rm -f "$HOME/.zshrc.bak" 2>/dev/null || true

      # Append autosuggest and spaceship settings if not already present
      if ! grep -qs "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" "$HOME/.zshrc"; then
        cat >> "$HOME/.zshrc" << 'ZSH_EXTRA'

# Scott Spence style: autosuggest & spaceship (https://scottspence.com/posts/my-updated-zsh-config-2025)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#663399,standout"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1
SPACESHIP_PROMPT_ASYNC=true
SPACESHIP_PROMPT_ADD_NEWLINE=true
SPACESHIP_CHAR_SYMBOL="⚡"
SPACESHIP_PROMPT_ORDER=(time user dir git line_sep char)
ZSH_EXTRA
        echo "Appended autosuggest and spaceship settings to ~/.zshrc"
      fi
    fi
  fi
else
  echo "[WARN] zsh is not installed. Oh My Zsh was skipped."
  echo "       Add 'brew \"zsh\"' to the Brewfile and run bootstrap again, or install manually: brew install zsh"
fi


log_step "Checking go installtion and updating zshrc..."


if ! grep -qs 'GOPATH="$HOME/go"' ~/.zshrc; then
  cat <<'EOF' >> ~/.zshrc

# Go environment
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
EOF
fi


# ------------------------------------------------------------------------------
# Optional: macOS defaults, dev environments, dotfiles
# ------------------------------------------------------------------------------
log_step "Optional steps (uncomment in bootstrap.sh to enable)"

# macOS system preferences (Finder, keyboard, Dock)
log_step "Applying macOS system preferences..."
bash "$SCRIPT_DIR/macos/defaults.sh"

# Dev environments (Python, Node, AWS)
# bash "$SCRIPT_DIR/dev/python.sh"
# bash "$SCRIPT_DIR/dev/node.sh"
# bash "$SCRIPT_DIR/dev/aws.sh"

# Dotfiles (.zshrc is copied earlier in the Zsh + Oh My Zsh section)
# cp "$SCRIPT_DIR/dotfiles/.gitconfig" ~/.gitconfig
# Vim
cp "$SCRIPT_DIR/dotfiles/.vimrc" ~/.vimrc

# ------------------------------------------------------------------------------
# Finish
# ------------------------------------------------------------------------------
log_step "Bootstrap completed successfully!"
echo ""
echo "  Log file: $LOG_FILE"
echo "  Run ./validate.sh to verify installed tools."
echo ""

log_step "Cleaning old log files (keep last 10)"
# Safe: no-op when <11 logs; pipeline hides ls exit code when no files match
(cd "$LOG_DIR" && ls -t bootstrap-*.log 2>/dev/null) | tail -n +11 | while IFS= read -r f; do rm -f "$LOG_DIR/$f"; done
