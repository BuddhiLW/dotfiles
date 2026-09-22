# Troubleshooting Talos Connectivity Issues

## Problem: kubectl/talosctl Can't Reach Cluster

When `kubectl get nodes` or `talosctl` commands timeout, the issue is usually one of:

1. **Tailscale not running on nodes** - nodes show "offline" in `tailscale status`
2. **Network misconfiguration** - nodes on different subnet than expected
3. **Tailscale auth key expired** - nodes can't authenticate to Tailscale

### Diagnostic Steps

```bash
# 1. Check Tailscale status from your machine
tailscale status

# Look for your nodes - "offline" means they can't reach Tailscale network
# 100.64.173.122   talos-no1-0gw-1  offline, last seen 18h ago  <-- Problem!
# 100.82.76.120    talos-18t-abp    offline, last seen 18h ago  <-- Problem!
```

### Solution: Connect via Local Network

If Tailscale is down on the nodes, you need to reach them via local LAN IP.

```bash
# 1. Find your local IP to determine your network
ip addr show | grep "inet "

# 2. If you can't reach nodes, you might be on different subnets
#    Your PC: 192.168.100.x
#    Talos nodes: 192.168.15.x  <-- Different network!

# 3. Connect to the same network as the nodes (wifi/ethernet)
#    Then verify connectivity
ping 192.168.15.3  # Control plane local IP

# 4. Check Tailscale logs on the node
talosctl --talosconfig ~/dotfiles/talos/base/talosconfig \
         --endpoints 192.168.15.3 --nodes 192.168.15.3 \
         logs ext-tailscale
```

### Common Error: Tailscale Auth Key Expired

If you see this in the logs:
```
invalid key: API key does not exist
health(warnable=login-state): error: You are logged out
```

**Fix:**
1. Generate new auth key at https://login.tailscale.com/admin/settings/keys
   - Make it **Reusable**
   - Make it **Pre-authorized**

2. Update the patch file:
```yaml
# ~/dotfiles/talos/base/tailscale.patch.yaml
---
apiVersion: v1alpha1
kind: ExtensionServiceConfig
name: tailscale
environment:
  - TS_AUTHKEY=tskey-auth-NEWKEY-HERE
```

3. Apply to each node:
```bash
# Control plane
talosctl --endpoints 192.168.15.3 --nodes 192.168.15.3 \
         apply-config -f ~/dotfiles/talos/base/controlplane.yaml \
         -p @~/dotfiles/talos/base/tailscale.patch.yaml

# Worker (find its local IP from kubectl get nodes -o wide or router DHCP)
talosctl --endpoints 192.168.15.4 --nodes 192.168.15.4 \
         apply-config -f ~/dotfiles/talos/base/worker.yaml \
         -p @~/dotfiles/talos/base/tailscale.patch.yaml
```

## Network Topology Discovery (2025-12-30)

### The Setup

```
VIVOFIBRA (Huawei router) ─── wifi ──→ TP-Link (Repeater mode)
     │                                        │
     │ DHCP: 192.168.15.x                     │ DHCP: 192.168.100.x
     │                                        │
     └── Talos nodes get 192.168.15.x    Your PC gets 192.168.100.x
         (via TP-Link bridge)
```

### The Problem

- TP-Link router is in **Repeater mode**, bridging VIVOFIBRA wifi
- Both TP-Link and Huawei (VIVOFIBRA) run DHCP servers
- Talos nodes got IPs from Huawei (192.168.15.x)
- Your PC got IP from TP-Link (192.168.100.x)
- **Different subnets = can't communicate directly**

### Quick Fix

Connect to VIVOFIBRA wifi to get on the same 192.168.15.x network as the Talos nodes.

### Proper Fix

Disable DHCP on one of the routers so all devices get IPs from the same DHCP server.

## Node Local IPs (as of 2025-12-30)

| Node | Tailscale IP | Local IP | Role |
|------|--------------|----------|------|
| talos-no1-0gw | 100.64.173.122 | 192.168.15.3 | Control Plane |
| talos-18t-abp | 100.82.76.120 | 192.168.15.4 | Worker |

These local IPs may change if DHCP leases renew. Check `kubectl get nodes -o wide` or router DHCP table.
