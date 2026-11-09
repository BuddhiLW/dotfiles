# Upgrading Talos Linux

## Current Cluster Info

- **Cluster name:** blw
- **Schematic ID:** `4a0d65c669d46663f377e7161e50cfd570c401f26fd9e7bda34a0216b6f1922b`
- **Extensions:** tailscale only
- **Factory image format:** `factory.talos.dev/installer/<SCHEMATIC_ID>:<VERSION>`

## Pre-Upgrade Checklist

### 1. Check Current Version

```bash
talosctl --nodes 100.64.173.122 version
```

### 2. Check etcd Health

```bash
talosctl --nodes 100.64.173.122 etcd status
talosctl --nodes 100.64.173.122 etcd members
```

### 3. Create etcd Backup

```bash
talosctl --nodes 100.64.173.122 etcd snapshot \
  ~/dotfiles/talos/db.snapshot/etcd-backup-$(date +%Y%m%d-%H%M%S).snapshot
```

## Upgrade Process

### Upgrade Control Plane First

```bash
talosctl --nodes 100.64.173.122 upgrade \
  --image factory.talos.dev/installer/4a0d65c669d46663f377e7161e50cfd570c401f26fd9e7bda34a0216b6f1922b:v1.12.0 \
  -m powercycle
```

**Wait for control plane to come back:**
```bash
kubectl get nodes
talosctl --nodes 100.64.173.122 version
```

### Upgrade Worker Node

```bash
talosctl --nodes 100.82.76.120 upgrade \
  --image factory.talos.dev/installer/4a0d65c669d46663f377e7161e50cfd570c401f26fd9e7bda34a0216b6f1922b:v1.12.0 \
  -m powercycle
```

## Rollback (If Something Goes Wrong)

Talos keeps the previous image. To rollback:

```bash
talosctl --nodes <node-ip> rollback
```

## Creating Custom Factory Images

If you need different extensions per node, generate a new schematic:

1. Go to https://factory.talos.dev/
2. Select Talos version
3. Select platform: `metal`
4. Add extensions (e.g., `tailscale`, `nvidia-container-toolkit`)
5. Copy the new schematic ID
6. Use: `factory.talos.dev/installer/<NEW_SCHEMATIC_ID>:<VERSION>`

## Version History

| Date | Version | Notes |
|------|---------|-------|
| 2025-09-18 | v1.11.1 | Initial cluster setup |
| 2025-12-30 | v1.12.0 | Upgraded both nodes, kernel 6.18.1 |

## Important Notes

- **Upgrade order:** Always control plane first, then workers
- **Non-destructive:** Configs, etcd data, and volumes are preserved
- **Extensions:** Both nodes currently use the same schematic (tailscale only)
- **powercycle mode:** Use `-m powercycle` for more reliable upgrades on bare metal

## Automated weekly updates (added 2026-09-23)

Two halves: the workstation **tells you** a release exists (A), and tuppr in the
cluster **applies** it once you merge a Renovate PR (B).

### A. Weekly check on the workstation (read-only)

- Script: `base/talos-version-check.sh`. Units: `base/systemd/talos-version-check.{service,timer}`,
  symlinked into `~/.config/systemd/user/` by `scripts/install/haproxy-k8s-lb`.
- Runs **Saturday 10:00** (`Persistent=true`, so a missed run fires at next boot).
- For each node: running version vs. newest stable patch of its minor, plus a
  newer minor if one exists; reads each node's **own** schematic live and prints
  the exact `talosctl upgrade --image` per node. Never upgrades anything.
- Notifies via `notify-send`, and ntfy when `NTFY_URL=https://ntfy.sh/<topic>` is set in
  `~/.config/talos-version-check.env`.
- Ops: `systemctl --user start talos-version-check.service`;
  `journalctl --user -u talos-version-check -o cat`.
- Off-LAN it goes through the tailnet subnet router (`hive-subnet-router`). That path
  has been DERP-relayed and flaky, so a node may show `UNREACHABLE`; that is a network
  finding, not a Talos one.

### B. tuppr + Renovate (applies upgrades)

Flow: Renovate (Saturday 06:00) opens a PR bumping `spec.talos.version` in
`k8s-a3f/infrastructure/tuppr/talosupgrade.yaml` → you merge → ArgoCD syncs →
tuppr rolls nodes **one at a time** in the **Sunday 03:00–07:00** window.
Patch releases get PRs directly. Minor releases wait for approval on the Renovate
dependency-dashboard issue, and you should step one minor at a time.

What protects the cluster:
- **Per-node schematic:** tuppr version-swaps each node's `.machine.install.image`,
  and refuses a node whose install image does not contain its runtime schematic.
- **etcd:** checked by tuppr before each CP (`force: false`, never change it).
- **Longhorn:** a health check blocks the next node until every attached volume is
  `healthy` again, and `waitForVolumeDetach` avoids Multi-Attach errors.
- **Reboots use `powercycle`**, as every manual upgrade here did.
- HAProxy needs no drain: its `/readyz` check fails the T320 over to the backups on its own.

Files (`~/PP/funeraria/k8s-a3f`): `infrastructure/tuppr/`, `infrastructure/renovate/`,
`renovate.json`. Talos side: `base/talos-api-access.patch.yaml`.

**One-time setup, in this order:**

1. **Pre-flight:** every node's install image must carry the schematic it is running.
   ```bash
   for ip in 192.168.100.{137,133,134,9,136}; do echo "== $ip"
     talosctl -n $ip -e $ip get extensions -o yaml | grep -A2 'name: schematic' | grep version
     talosctl -n $ip -e $ip get mc -o yaml | grep 'image: factory.talos.dev'
     talosctl -n $ip -e $ip get machinestatus -o yaml | grep 'stage:'   # must be running
   done
   ```
   If a node's schematic and image differ, patch `.machine.install.image` first (strategic merge).

   **Pre-flight result 2026-09-23 — BLOCKER on both mini PCs.** `.133` and `.134` still
   carry `install.image: factory.talos.dev/installer/68c3b8b9…:v1.12.0` — the *superseded
   nut-client* schematic — while running `49459f16…` (v1.13.7). tuppr would refuse them
   (good), but any install-from-config (e.g. `upgrade --stage`) would bring nut-client
   back and with it the ~71-min CP reboot loop. Fix before enabling tuppr:
   ```bash
   for ip in 192.168.100.133 192.168.100.134; do
     talosctl -n $ip -e $ip patch mc --patch '{"machine":{"install":{"image":"factory.talos.dev/installer/49459f16fba71e8a9c8c7455e224a911186fad775ace332781f9929d41b96c4c:v1.13.7"}}}'
   done
   ```
   `.137` (650e4bea…) and `.9` (138ba6fe…) match. `.136` was unreachable over the
   subnet router — still to check.
2. **Talos API access on all 5 nodes** (no reboot):
   `talosctl patch mc -n <ip> -e <ip> --patch @base/talos-api-access.patch.yaml`
3. **ArgoCD (`k8s-a3f/argocd/`)**. Claude left these for a human to apply:
   - `appprojects.yaml`, project `platform`: add `ghcr.io/home-operations/charts` and
     `http://gitea.gitea.svc.cluster.local:3000/Assistencia-Familiar-Francana/k8s-a3f.git`
     to `sourceRepos`; add the destinations `system-upgrade` and `renovate`.
   - An OCI repository Secret (`argocd.argoproj.io/secret-type: repository`, `type: helm`,
     `name: home-operations`, `url: ghcr.io/home-operations/charts`, `enableOCI: "true"`,
     public, so no credentials), listed in `argocd/kustomization.yaml`.
   - `argocd/apps/tuppr.yaml`: multi-source Application. Chart `tuppr` @ `0.5.7` from
     `ghcr.io/home-operations/charts`, plus path `infrastructure/tuppr` from the Gitea
     repoURL. Destination namespace `system-upgrade`. Add `ignoreDifferences` on the
     webhook configurations' `caBundle` with `RespectIgnoreDifferences=true`.
   - `argocd/apps/renovate.yaml`: path `infrastructure/renovate`, same Gitea repoURL.
4. **Renovate token:** create a Gitea bot token, then seal it as
   `infrastructure/renovate/token-sealed.yaml` (command in `cronjob.yaml`'s header)
   and uncomment it in the kustomization.
5. The plan starts at `v1.13.7` (what's running), so the first sync upgrades nothing.
   The first Renovate run will open the `v1.13.10` PR.

Watch a roll: `kubectl get talosupgrade -w`, `kubectl describe talosupgrade cluster`.
Pause: `kubectl annotate talosupgrade cluster tuppr.home-operations.com/suspend="true"`;
resume: `kubectl annotate talosupgrade cluster tuppr.home-operations.com/suspend-`.
