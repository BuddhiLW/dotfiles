if not contains "$HOME/.local/share/../bin" $PATH
    # Prepending path in case a system-installed binary needs to be overridden
    set -x PATH "$HOME/.local/share/../bin" $PATH
end
