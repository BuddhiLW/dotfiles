# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for Ubuntu-based systems with XMonad tiling window manager. Managed by BuddhiLW (Pedro Branquinho). Uses direct symlinks (not GNU Stow) for configuration management.

## Installation Commands

```bash
# Full system installation (fresh Ubuntu)
sudo apt-get install -y git && \
git clone https://github.com/BuddhiLW/dotfiles.git && \
cd dotfiles && DOTFILES=$(pwd) bash ./main.sh

# Individual tool installations (from dotfiles directory)
bash ./scripts/install/<tool-name>   # e.g., vim, emacs, docker, go

# After vim install, run inside vim:
:PlugInstall

# After emacs install:
doom install && doom sync
```

## Build/Compile Commands

```bash
# XMonad (Haskell window manager)
cd ~/.config/xmonad && stack build

# XMonad documentation generation
bash ./build-xmonad-docs.sh  # generates PDF from markdown

# Rebuild XMonad after config changes
xmonad --recompile
```

## Architecture

### Script Organization

```
scripts/
├── setup/           # Run first: symlinks, backups, environment setup
│   ├── bk-dots      # Backup existing configs
│   ├── init         # Initialize environment
│   ├── link-config  # Create config symlinks
│   └── xmonad       # XMonad-specific setup
└── install/         # Individual tool installers (137+ scripts)
    ├── main         # Core package installation orchestrator
    └── <tool>       # Each tool has its own installer
```

### Configuration Layout

- `.bashrc` - Main shell config (20KB) with extensive environment variables
- `.doom.d/` - Doom Emacs config (literate config in `Emacs.org`)
- `.config/xmonad/xmonad.hs` - XMonad config (795 lines Haskell)
- `.vim/` - Vim config with autoload/colors/spell
- `arara.yaml` - Dependency manifest (planned Bonzai migration)

### Key Environment Variables

Set in `.bashrc` and used throughout:
- `DOTFILES` - Root of this repository
- `DOOMDIR` - Doom Emacs config directory
- `GOPATH`, `GOBIN` - Go workspace
- `ANDROID_HOME` - Android SDK location

### Git Submodules

The repository uses submodules for:
- XMonad source: `.config/xmonad/xmonad`, `.config/xmonad/xmonad-contrib`
- Doom modules: `doom/ob-julia`, `doom/julia-vterm.el`
- Suckless tools: `gitthings/dwm-primcol`, `gitthings/picom`, `gitthings/dmenu`

## XMonad Keybindings Reference

- `M-d` opens the keybinding PDF reference
- Documentation: `.config/documentation/xmonad-bindings-tables.{md,pdf}`
- Modify and rebuild: `vim $DOTFILES/.config/documentation/xmonad-bindings-tables.md && dotdoc-compile`

## Cursor/AI Rules (CLARITY Framework)

The `.cursor/rules/` directory contains 44+ rule files, centered around the **CLARITY** framework for Go systems with DDD/SOLID/GoF patterns:

- `00_clarity_master.mdc` - Master principles
- `01_clarity_subrules.mdc` - 12 actionable patterns
- `02_clarity_llm_contract.mdc` - AI operating mode
- `03_clarity_lessons_learned.mdc` - Real case study

CLARITY acronym:
- **C**omposition over modification (OCP via Decorator/Strategy/Builder)
- **L**ayers stay pure (DDD boundaries with Adapters)
- **A**rchitectural performance (cache/index strategies)
- **R**epresented intent (Parameter/Value Objects)
- **I**nputs are guarded (validation at boundaries)
- **T**elemetry first (metrics, timeouts, logs)
- **Y**ield safe failure (graceful degradation)

## Domain-Specific Rules

Additional Cursor rules cover:
- Kubernetes patterns (`declarative-kubernetes.mdc`, anti-patterns, resource management)
- Testing (`tdd-principles.mdc`, `testing-doubles.mdc`)
- Project-specific (`project-rules-funeraria-francana.mdc` - funeral home system)
- Infrastructure (ArgoCD, Cloudflare, Kustomize, Docker)

## Additional Directories

- `keg/` - Personal Knowledge Exchange Graph (rwxrob-style documentation)
- `talos/` - Talos Kubernetes cluster configuration (has its own CLAUDE.md)
- `chanelio/` - Guix Scheme definitions for custom builds
- `.cursor/plans/` - Project planning documents
