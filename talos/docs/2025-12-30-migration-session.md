# Control Plane Migration Session - 2025-12-30

## Summary

Migrated control plane from `talos-no1-0gw` to laptop `talos-qg2-dku`. The original cluster had etcd issues after the laptop became the new control plane. Recovery was successful but the GPU worker (talos-18t-abp) had containerd issues due to nvidia runtime configuration without the nvidia extensions installed.

## Current Cluster State

| Node | Role | Tailscale IP | Status | Notes |
|------|------|--------------|--------|-------|
| talos-qg2-dku | control-plane | 100.97.252.31 | Ready | New laptop CP, etcd healthy |
| talos-18t-abp | worker (GPU) | 100.82.76.120 | Ready | GPU support pending schematic upgrade |
| talos-no1-0gw | worker | 100.64.173.122 | Ready | Converted from CP to worker |

## New Control Plane Endpoint

All configs updated to use: `https://100.97.252.31:6443`

Updated files:
- `talos/base/controlplane-laptop.yaml`
- `talos/base/controlplane.yaml`
- `talos/base/worker.yaml`
- `talos/base/worker-gpu.yaml`
- `talos/base/kubeconfig`

## Issues Encountered and Fixes

### 1. Laptop didn't install to disk (first apply)
- **Problem**: Used `wipe: false`, laptop booted back to USB
- **Fix**: Changed to `wipe: true` in controlplane-laptop.yaml

### 2. etcd lost quorum on old CP
- **Problem**: Old CP's etcd couldn't reach old member
- **Fix**: Bootstrapped new CP from backup using `talosctl bootstrap --recover-from=<snapshot>`
- **Backup used**: `etcd-backup-pre-migration-20251230-155727.snapshot`

### 3. GPU worker nvidia runtime error
- **Problem**: containerd CRI plugin failed with "unknown service runtime.v1.RuntimeService"
- **Root cause**: nvidia runtime config set but nvidia-container-runtime not installed
- **Reason**: GPU schematic not applied, node has base schematic:
  - Current: `4a0d65c669d46663f377e7161e50cfd570c401f26fd9e7bda34a0216b6f1922b` (no NVIDIA)
  - Needed: `6d75b5c799b863517722adceccbb64c97d4b0309c31ad5dbfeabc729a76b9fc1` (with NVIDIA)
- **Temporary fix**: Removed nvidia runtime config from worker-gpu.yaml
- **Permanent fix needed**: Upgrade GPU worker to GPU schematic

### 4. Kubeconfig wrong server
- **Fix**: `sed -i 's|old-ip|new-ip|g' kubeconfig`

### 5. Cilium k8sServiceHost pointing to old CP
- **Problem**: Cilium pods stuck in Init:0/5, trying to reach old API server
- **Root cause**: Helm release had `k8sServiceHost: 100.64.173.122`
- **Fix**: Helm upgrade with new endpoint:
```bash
helm upgrade cilium cilium/cilium --version 1.18.1 --namespace kube-system \
  --set k8sServiceHost=100.97.252.31 --set k8sServicePort=6443 \
  -f /tmp/cilium-upgrade-values.yaml
kubectl rollout restart daemonset cilium -n kube-system
```

### 6. GHCR ImagePullBackOff (403 Forbidden)
- **Problem**: Pods failing to pull images from ghcr.io
- **Root cause**: GitHub PAT expired
- **Fix**:
  1. Generate new PAT at https://github.com/settings/tokens (read:packages scope)
  2. Update password store: `pass edit Github/BuddhiLW/ghp/all`
  3. Regenerate secrets for all namespaces:
```bash
cd ~/PP/funeraria/k8s-a3f
./scripts/generate-ghcr-secret.sh funeraria-francana-staging
./scripts/generate-ghcr-secret.sh funeraria-francana-dev
./scripts/generate-ghcr-secret.sh funeraria-francana-v2-a3f
./scripts/generate-ghcr-secret.sh funeraria-francana-v2-a3f-dev
./scripts/generate-ghcr-secret.sh funeraria-francana-v2-a3f-staging
```

## Migration Complete

All immediate issues resolved:
- 3 nodes Ready (1 CP + 2 workers)
- ~125 pods running
- Website accessible
- ArgoCD, Keycloak, databases operational

## Remaining Tasks

### GPU Support (Later)
1. Upgrade GPU worker to GPU schematic:
```bash
talosctl upgrade \
  --image factory.talos.dev/installer/6d75b5c799b863517722adceccbb64c97d4b0309c31ad5dbfeabc729a76b9fc1:v1.12.0 \
  -e 100.97.252.31 -n 100.82.76.120
```

2. Re-add nvidia containerd configuration to worker-gpu.yaml

### For AMD GPU (old CP as worker)
- Create AMD GPU schematic at factory.talos.dev
- Upgrade talos-no1-0gw with AMD GPU schematic

## Website Status
- https://www.funerariafrancana.com.br/ is **UP** (HTTP 200)
- Cloudflared pods rescheduled successfully
- Config at: `~/PP/funeraria/k8s-a3f/`

## Commands Reference

```bash
# Check node status
kubectl get nodes -o wide

# Check pods
kubectl get pods -A | head -50

# Check machine status on Talos node
talosctl -e <node-ip> -n <node-ip> get machinestatus

# Restart kubelet
talosctl -e <node-ip> -n <node-ip> service kubelet restart

# Apply worker config to old CP
talosctl apply-config -f base/worker.yaml -p @base/tailscale.patch.yaml \
  -e 100.64.173.122 -n 100.64.173.122 --mode reboot

# Create etcd backup
talosctl -n 100.97.252.31 etcd snapshot db.snapshot/etcd-backup-$(date +%Y%m%d-%H%M%S).snapshot
```

## Critical Files

- New CP config: `/home/lages/dotfiles/talos/base/controlplane-laptop.yaml`
- Worker config: `/home/lages/dotfiles/talos/base/worker.yaml`
- GPU worker config: `/home/lages/dotfiles/talos/base/worker-gpu.yaml` (nvidia config removed)
- Kubeconfig: `/home/lages/dotfiles/talos/base/kubeconfig`
- etcd backup: `/home/lages/dotfiles/talos/db.snapshot/etcd-backup-pre-migration-20251230-155727.snapshot`

## k8s-a3f Changes Required

The control plane IP change from `100.64.173.122` to `100.97.252.31` required updates to:

### Functional Config (Applied)
- `monitoring/base/network-policy.yaml` - Updated toCIDR rule for Kubernetes API access
  - Changed: `100.64.173.122/32` → `100.97.252.31/32`
  - **Why**: Prometheus needs explicit CIDR rules to reach the Kubernetes API for service discovery

### Documentation Updates (Applied)
- `CLAUDE.md` - Added Cluster Info section with new CP endpoint
- `CLAUDE.md` - Updated toCIDR reference in Cilium CNP fixes section
- `docs/FIX_NAMESPACE_COLLISION.md` - Updated cluster endpoint reference

### No Changes Needed
- ArgoCD, Envoy, Cloudflare configs don't hardcode the CP IP (they use DNS/service discovery)
- Application manifests don't reference the CP IP directly
