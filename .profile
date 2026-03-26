#!/usr/bin/env sh

if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# Rust/Cargo
[ -f "$HOME/.local/share/cargo/env" ] && . "$HOME/.local/share/cargo/env"

# Deno
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# Qt OpenGL fix
export QT_XCB_GL_INTEGRATION=xcb_glx

# Display scaling (Qt/GTK)
[ -f "$HOME/.config/display-scale.env" ] && . "$HOME/.config/display-scale.env"
. "/home/leibniz/.local/share/cargo/env"
