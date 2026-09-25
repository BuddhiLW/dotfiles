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

if [ "${RESTORE:-0}" = 1 ]; then
  if ! systemctl --user cat docker.service >/dev/null 2>&1; then
    bash "$DOTFILES/scripts/install/docker"
    bash "$DOTFILES/scripts/install/docker-ce-rootless"
  fi
  command -v kubectl >/dev/null || bash "$DOTFILES/scripts/install/kubectl"
  command -v talosctl >/dev/null || bash "$DOTFILES/scripts/install/talosctl"
  bash "$DOTFILES/scripts/backup/docker-volumes" restore || echo "!! docker volume restore failed; re-run it later"
  mkdir -p "$HOME/.config/systemd/user"
  for u in "$DOTFILES"/talos/base/systemd/*; do ln -sfn "$u" "$HOME/.config/systemd/user/${u##*/}"; done
  systemctl --user daemon-reload
  systemctl --user enable --now haproxy-k8s-lb.service haproxy-k8s-lb-healthcheck.timer \
    || echo "!! haproxy-k8s-lb did not start; check: systemctl --user status haproxy-k8s-lb"
fi

# tea through Cloudflare Access: local proxy unit + default tea login. Host and
# token come from pass (infra/gitea-access), never from this public repo.
# Prints a NEXT line when the pass entry or the browser login is still missing.
bash "$DOTFILES/scripts/install/gitea-access" || echo "!! gitea-access failed; re-run scripts/install/gitea-access"

echo "Congrats. If everything went well, you have the newest Buddhi WM installed."
echo "New step, you can logout from your current Ubuntu session, and chose XMonad,"
echo "instead of GNOME Window Manager. This choice is generally done at the login"
echo "interface."
