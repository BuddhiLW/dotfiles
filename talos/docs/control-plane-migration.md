# Control Plane Migration: Laptop as New Control Plane

**Goal:** Make laptop (talos-ic5-px4) the control plane, demote current CP (talos-no1-0gw) to worker.

## Current State

| Node | Role | Tailscale IP | Notes |
|------|------|--------------|-------|
| talos-no1-0gw | Control Plane | 100.64.173.122 | Current CP |
| talos-18t-abp | Worker (GPU) | 100.82.76.120 | RTX 3050 OEM enabled |
| talos-ic5-px4 | Worker | 100.72.172.29 | Laptop (GPU broken due to Optimus) |

## Target State

| Node | Role | Tailscale IP | Notes |
|------|------|--------------|-------|
| talos-ic5-px4 | Control Plane | 100.72.172.29 | Laptop (CPU-only CP) |
| talos-18t-abp | Worker (GPU) | 100.82.76.120 | RTX 3050 OEM |
| talos-no1-0gw | Worker | 100.64.173.122 | Former CP as worker |

## Migration Steps

### Step 1: Backup etcd (CRITICAL)

```bash
talosctl --nodes 100.64.173.122 etcd snapshot \
  ~/dotfiles/talos/db.snapshot/etcd-backup-pre-migration-$(date +%Y%m%d-%H%M%S).snapshot
```

### Step 2: Remove laptop from cluster as worker

```bash
# Drain the node
kubectl drain talos-ic5-px4 --ignore-daemonsets --delete-emptydir-data

# Delete the node from Kubernetes
kubectl delete node talos-ic5-px4

# Reset the Talos node (wipes config and data)
talosctl -n 100.72.172.29 reset --graceful=false --reboot
```

### Step 3: Wait for laptop to reboot into maintenance mode

After reset, the node will boot into maintenance mode. Wait for it to be reachable:

```bash
# Check if reachable (may need local IP if Tailscale is down after reset)
talosctl -n 100.72.172.29 -e 100.72.172.29 version --insecure
```

### Step 4: Apply control plane config to laptop

```bash
talosctl apply-config \
  -f ~/dotfiles/talos/base/controlplane-laptop.yaml \
  -p @~/dotfiles/talos/base/tailscale.patch.yaml \
  -e 100.64.173.122 \
  -n 100.72.172.29 \
  --insecure
```

Wait for the laptop to join as a second control plane member.

### Step 5: Verify two-node control plane

```bash
# Check etcd members
talosctl -n 100.64.173.122 etcd members

# Check Kubernetes nodes
kubectl get nodes

# Verify both control planes are healthy
talosctl -n 100.64.173.122 health
talosctl -n 100.72.172.29 health
```

### Step 6: Update control plane endpoint

Once laptop is stable, update all configs to use laptop's IP as endpoint:

In `controlplane.yaml`, `controlplane-laptop.yaml`, `worker.yaml`, `worker-gpu.yaml`:
```yaml
cluster:
    controlPlane:
        endpoint: https://100.72.172.29:6443  # Changed from 100.64.173.122
```

Apply updated configs to all nodes.

### Step 7: Remove old control plane from etcd

```bash
# Get the member ID of old control plane
talosctl -n 100.72.172.29 etcd members

# Remove the old control plane from etcd
# WARNING: This is destructive! Only do this after verifying new CP is working
talosctl -n 100.72.172.29 etcd remove-member <OLD_MEMBER_ID>
```

### Step 8: Reset old control plane

```bash
# Reset the old control plane
talosctl -n 100.64.173.122 reset --graceful=false --reboot
```

### Step 9: Join old control plane as worker

After reset, apply worker config:

```bash
talosctl apply-config \
  -f ~/dotfiles/talos/base/worker.yaml \
  -p @~/dotfiles/talos/base/tailscale.patch.yaml \
  -e 100.72.172.29 \
  -n 100.64.173.122 \
  --insecure
```

## Rollback Plan

If something goes wrong, restore from etcd backup:

```bash
# On a fresh control plane node
talosctl -n <NEW_IP> bootstrap --recover-from=/path/to/etcd-backup.snapshot
```

## Important Notes

- The laptop doesn't need GPU support as control plane
- Keep both control planes running initially until you verify stability
- Control plane endpoint update is critical - all nodes must know where to find the API server
- Etcd is the most critical component - always backup before making changes
