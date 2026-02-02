#!/bin/bash

echo "Validating installation..."

# Core (Brewfile)
command -v git    >/dev/null 2>&1 && echo "  git:    $(git --version | head -1)"    || { echo "  git:    missing"; exit 1; }
command -v brew   >/dev/null 2>&1 && echo "  brew:   ok"                           || { echo "  brew:   missing"; exit 1; }
command -v zsh    >/dev/null 2>&1 && echo "  zsh:    $(zsh --version | head -1)"   || { echo "  zsh:    missing"; exit 1; }
command -v python >/dev/null 2>&1 && echo "  python: $(python --version 2>&1)"     || { echo "  python: missing"; exit 1; }
command -v kubectl >/dev/null 2>&1 && echo "  kubectl: ok" || { echo "  kubectl: missing"; exit 1; }
command -v aws    >/dev/null 2>&1 && echo "  aws:    $(aws --version 2>&1)"         || { echo "  aws:    missing"; exit 1; }

# Oh My Zsh (when zsh is installed)
if command -v zsh &>/dev/null && [[ -d "$HOME/.oh-my-zsh" ]]; then
  echo "  oh-my-zsh: installed at ~/.oh-my-zsh"
else
  echo "  oh-my-zsh: not installed (optional; run bootstrap with zsh in Brewfile)"
fi

echo ""
echo "Validation complete."
