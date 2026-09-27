#!/usr/bin/bash
export DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "${RESTORE:-0}" = 1 ]; then
  bash "$DOTFILES/scripts/backup/secrets-restore" || exit 1
  bash "$DOTFILES/scripts/backup/home-restore" || exit 1
fi

ln -sf $DOTFILES/.bashrc $HOME/.bashrc
if compgen -G "$DOTFILES/gitthings/*/build/*/bin/monero-storage" >/dev/null; then
  echo "keeping $DOTFILES/gitthings: it holds monero-storage (wallets)"
else
  rm -rf "$DOTFILES/gitthings"
fi
SC="$DOTFILES/scripts/"
cd $SC
bash ./setup/bk-dots
bash ./setup/init
bash ./setup/link-config

source $HOME/.bashrc

bash ./install/main
# make newly installed fonts available
fc-cache -vf

# Install the window manager
bash ./setup/xmonad
bash ./install/xmonad

# Clojure tooling (bb, official CLI) -- no sudo, into ~/.local
bash ./install/babashka
bash ./install/clojure

# Local embeddings for hive-mcp (qwen3-embedding:4b)
bash ./install/ollama || echo "!! ollama setup failed; re-run scripts/install/ollama"

# Containers: rootless docker for this user (hive-mcp services, k8s LB)
bash ./install/docker
bash ./install/docker-ce-rootless

# Cluster access: kubectl -> 127.0.0.1:16443 LB -> CPs (LAN) or ClusterIP (tailnet).
# Each script is idempotent; a failure here should not abort the rest.
bash ./install/kubectl  || echo "!! kubectl install failed"
bash ./install/talosctl || echo "!! talosctl install failed"
bash ./install/tailscale || echo "!! tailscale not up; off-LAN kubectl needs it (prints a login URL)"

if [ "${RESTORE:-0}" = 1 ]; then
  bash "$DOTFILES/scripts/backup/docker-volumes" restore || echo "!! docker volume restore failed; re-run it later"
fi

bash ./install/haproxy-k8s-lb \
  || echo "!! haproxy-k8s-lb did not start; check: systemctl --user status haproxy-k8s-lb"

# tea through Cloudflare Access: local proxy unit + default tea login. Host and
# token come from pass (infra/gitea-access), never from this public repo.
# Prints a NEXT line when the pass entry or the browser login is still missing.
bash "$DOTFILES/scripts/install/gitea-access" || echo "!! gitea-access failed; re-run scripts/install/gitea-access"

echo "Congrats. If everything went well, you have the newest Buddhi WM installed."
echo "New step, you can logout from your current Ubuntu session, and chose XMonad,"
echo "instead of GNOME Window Manager. This choice is generally done at the login"
echo "interface."
