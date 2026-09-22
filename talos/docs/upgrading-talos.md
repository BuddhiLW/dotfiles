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
