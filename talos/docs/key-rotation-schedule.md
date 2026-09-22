# Key Rotation Schedule

This document tracks all credentials, tokens, and secrets that require periodic rotation.

## Credential Inventory

| Credential | Location | Expiration | Rotation Interval | Last Rotated | Next Due |
|------------|----------|------------|-------------------|--------------|----------|
| **Tailscale Auth Key** | `talos/base/tailscale.patch.yaml` | 90 days | 90 days | ? | ? |
| **GHCR PAT** | `pass Github/BuddhiLW/ghp/all` | User-defined | 90 days | 2025-12-30 | ~2026-03-30 |
| **MCP Viewer Token** | `~/.kube/mcp-viewer.kubeconfig` | 30 days | 30 days | ? | ? |
| **ArgoCD Auth Token** | `pass ArgoCD/funerariafrancana/blw-auth-token` | 24 hours | On-demand | 2025-12-30 | ~2025-12-31 |

---

## Tailscale Auth Key (90 days)

**Impact**: Talos nodes lose Tailscale connectivity, cluster becomes unreachable via Tailscale IPs.

**Files to update**:
- `talos/base/tailscale.patch.yaml` (single source)

**Rotation procedure**:
```bash
# 1. Generate new key at https://login.tailscale.com/admin/settings/keys
#    - Check "Reusable"
#    - Check "Pre-approved" (optional)

# 2. Update the patch file
vim ~/dotfiles/talos/base/tailscale.patch.yaml
# Replace TS_AUTHKEY value

# 3. Apply to all nodes
talosctl apply-config -f base/controlplane-laptop.yaml -p @base/tailscale.patch.yaml \
  -e 100.97.252.31 -n 100.97.252.31

talosctl apply-config -f base/worker-gpu.yaml -p @base/tailscale.patch.yaml \
  -e 100.97.252.31 -n 100.82.76.120

talosctl apply-config -f base/worker.yaml -p @base/tailscale.patch.yaml \
  -e 100.97.252.31 -n 100.64.173.122
```

**Verification**:
```bash
tailscale status  # Check all nodes appear online
```

---

## GitHub Container Registry PAT (GHCR) (90 days)

**Impact**:
- Kubernetes pods fail with `ImagePullBackOff` when pulling private images from ghcr.io
- GitHub Actions workflows fail to push/pull images

**Files/Locations**:
- Password store: `Github/BuddhiLW/ghp/all`
- Kubernetes secrets: `ghcr-secret` in multiple namespaces
- GitHub Actions secrets: `CR_PAT` in all org repos

**Rotation procedure**:
```bash
# 1. Generate new PAT at https://github.com/settings/tokens
#    Scopes needed: read:packages, write:packages
#    Expiration: 90 days

# 2. Update password store
pass edit Github/BuddhiLW/ghp/all
# Paste the new token

# 3. Update Kubernetes secrets (all namespaces)
cd ~/PP/funeraria/k8s-a3f
./scripts/generate-ghcr-secret.sh funeraria-francana-staging
./scripts/generate-ghcr-secret.sh funeraria-francana-dev
./scripts/generate-ghcr-secret.sh funeraria-francana-v2-a3f
./scripts/generate-ghcr-secret.sh funeraria-francana-v2-a3f-dev
./scripts/generate-ghcr-secret.sh funeraria-francana-v2-a3f-staging

# 4. Update GitHub Actions secrets (all 38 repos)
./scripts/update-github-secrets.sh CR_PAT

# 5. Restart any pods stuck in ImagePullBackOff
kubectl get pods -A | grep ImagePull | awk '{print $1,$2}' | \
  while read ns pod; do kubectl delete pod $pod -n $ns; done
```

**Verification**:
```bash
kubectl get pods -A | grep -E "ImagePull|ErrImage"  # Should be empty
```

---

## MCP Viewer Kubernetes Token (30 days)

**Impact**: Claude Code's kubernetes-mcp-server loses cluster access.

**Files**:
- `~/.kube/mcp-viewer.kubeconfig`

**Rotation procedure**:
```bash
# Generate new 30-day token
TOKEN="$(kubectl create token mcp-viewer --duration=720h -n mcp)"

# Update kubeconfig with new token
kubectl config --kubeconfig="$HOME/.kube/mcp-viewer.kubeconfig" \
  set-credentials mcp-viewer --token="$TOKEN"
```

**Verification**:
```bash
kubectl --kubeconfig="$HOME/.kube/mcp-viewer.kubeconfig" auth whoami
claude mcp list  # Should show kubernetes-mcp-server: Connected
```

---

## ArgoCD Auth Token (24 hours)

**Impact**: GitHub Actions can't trigger ArgoCD syncs after deploy.

**Files/Locations**:
- Password store: `ArgoCD/funerariafrancana/blw-auth-token`
- GitHub Actions secrets: `ARGOCD_FF_AUTH_TOKEN` in all org repos

**Rotation procedure**:
```bash
# 1. Generate new token in ArgoCD UI or CLI
argocd account generate-token --account blw

# 2. Update password store
pass edit ArgoCD/funerariafrancana/blw-auth-token
# Paste the new token

# 3. Update GitHub Actions secrets (all repos)
cd ~/PP/funeraria/k8s-a3f
./scripts/update-github-secrets.sh ARGOCD_FF_AUTH_TOKEN
```

**Note**: ArgoCD tokens expire in 24 hours by default. Consider creating a longer-lived token or using CI/CD service accounts.

---

## Talos Certificates (1 year - Talos managed)

**Impact**: Node communication fails, etcd fails.

**Note**: Talos automatically rotates certificates before expiration. Monitor with:
```bash
talosctl -e 100.97.252.31 -n 100.97.252.31 get certificates
```

---

## Kubernetes Certificates (1 year - Talos managed)

**Impact**: API server, kubelet, etcd communication fails.

**Note**: Talos manages these automatically. Check expiration:
```bash
talosctl -e 100.97.252.31 -n 100.97.252.31 get kubernetesendpoint
```

---

## etcd Backups (Recommended: weekly)

**Not a rotation, but critical maintenance**:
```bash
talosctl -n 100.97.252.31 etcd snapshot \
  ~/dotfiles/talos/db.snapshot/etcd-backup-$(date +%Y%m%d-%H%M%S).snapshot
```

---

## Calendar Reminders

Set these reminders:

| When | What |
|------|------|
| Every 85 days | Rotate Tailscale auth key |
| Every 85 days | Rotate GHCR PAT |
| Every 25 days | Rotate MCP viewer token |
| Every Sunday | Create etcd backup |

**Tip**: Use `pass` expiration tracking or a calendar app.

---

## Troubleshooting

### "Tailscale node offline"
- Auth key expired
- Follow Tailscale rotation procedure above
- If can't reach via Tailscale, connect via local network (192.168.15.x)

### "ImagePullBackOff" errors
- GHCR PAT expired
- Follow GHCR rotation procedure above

### "MCP kubernetes-mcp-server: Failed to connect"
- MCP viewer token expired
- Follow MCP token rotation procedure above

---

## Quick Reference Commands

```bash
# Check Tailscale status
tailscale status

# Check for image pull errors
kubectl get pods -A | grep ImagePull

# Check MCP connection
claude mcp list

# Backup etcd now
talosctl -n 100.97.252.31 etcd snapshot ~/dotfiles/talos/db.snapshot/etcd-backup-$(date +%Y%m%d-%H%M%S).snapshot

# Check Talos certificate expiration
talosctl -e 100.97.252.31 -n 100.97.252.31 get certificates
```
