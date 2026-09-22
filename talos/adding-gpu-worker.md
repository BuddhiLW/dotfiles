# Adding New GPU Worker Node to blw Cluster

**Date:** 2025-12-30
**New Node Schematic:** `6d75b5c799b863517722adceccbb64c97d4b0309c31ad5dbfeabc729a76b9fc1`

## Prerequisites

- [x] Talos USB created with NVIDIA extensions
- [x] Tailscale auth key updated (expires Mar 30, 2026)
- [x] `worker-gpu.yaml` config created
- [x] `nvidia.patch.yaml` created
- [ ] New machine connected to same network as existing nodes

## Extensions Included

- nonfree-kmod-nvidia-lts (580.105.08)
- nvidia-container-toolkit-lts
- nvidia-fabricmanager-lts
- i915, intel-ucode
- realtek-firmware
- tailscale
- iscsi-tools, fuse3, zfs
- nvme-cli, util-linux-tools

---

## Part 1: Boot New Node from USB

### Step 1: Physical Setup

1. Connect ethernet cable from modem to new machine
2. Insert Talos USB
3. Boot from USB (may need to change BIOS boot order)
4. Wait for Talos to boot to maintenance mode

### Step 2: Find the New Node

From your laptop (connected to same wifi):

```bash
# Scan local network for Talos nodes
# The new node will get a DHCP IP like 192.168.15.x
nmap -sn 192.168.15.0/24

# Or check your router's DHCP leases
# Or wait for it to appear in Tailscale (if auth key works)
```

### Step 3: Verify Node is Reachable

```bash
# Replace NEW_IP with the discovered IP
talosctl -e <NEW_IP> -n <NEW_IP> disks
talosctl -e <NEW_IP> -n <NEW_IP> get members
```

### Step 4: Check Install Disk

```bash
# List available disks
talosctl -e <NEW_IP> -n <NEW_IP> disks

# Note the disk to install to (e.g., /dev/sda, /dev/nvme0n1)
```

---

## Part 2: Apply Configuration

### Step 5: Update Config with Correct Disk (if needed)

If the install disk is not `/dev/sda`, edit `worker-gpu.yaml`:

```yaml
machine:
  install:
    disk: /dev/nvme0n1  # or whatever disk you found
```

### Step 6: Apply Config to New Node

```bash
# Apply worker config with tailscale patch
talosctl apply-config \
  -f ~/dotfiles/talos/base/worker-gpu.yaml \
  -p @~/dotfiles/talos/base/tailscale.patch.yaml \
  -e <NEW_IP> \
  -n <NEW_IP> \
  --insecure
```

The `--insecure` flag is needed for first-time config application.

### Step 7: Wait for Installation

The node will:
1. Write config to disk
2. Install Talos to the target disk
3. Reboot automatically

Monitor progress:
```bash
talosctl -e <NEW_IP> -n <NEW_IP> dmesg -f
```

---

## Part 3: Post-Installation

### Step 8: Verify Tailscale Connection

After reboot, check if node joined Tailscale:

```bash
tailscale status
```

Look for a new node like `talos-xxx-yyy`.

### Step 9: Get the Tailscale IP

Note the Tailscale IP (100.x.x.x) for the new node.

### Step 10: Update certSANs (Optional but Recommended)

Edit `worker-gpu.yaml` to add the IPs:

```yaml
machine:
  certSANs:
    - <TAILSCALE_IP>
    - <LOCAL_IP>
```

Then re-apply:
```bash
talosctl apply-config \
  -f ~/dotfiles/talos/base/worker-gpu.yaml \
  -p @~/dotfiles/talos/base/tailscale.patch.yaml \
  -e 100.64.173.122 \
  -n <NEW_TAILSCALE_IP>
```

### Step 11: Verify Node Joined Cluster

```bash
# Check from control plane
kubectl get nodes

# Should show 3 nodes now:
# - talos-no1-0gw (control plane)
# - talos-18t-abp (worker)
# - talos-xxx-yyy (new GPU worker)
```

### Step 12: Verify NVIDIA Modules Loaded

```bash
talosctl -n <NEW_TAILSCALE_IP> read /proc/modules | grep nvidia
```

Should show: `nvidia`, `nvidia_uvm`, `nvidia_drm`, `nvidia_modeset`

---

## Part 4: Enable NVIDIA in Kubernetes

### Step 13: Deploy NVIDIA Device Plugin

```bash
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.5/nvidia-device-plugin.yml
```

### Step 14: Verify GPU is Visible

```bash
kubectl get nodes -o json | jq '.items[] | {name: .metadata.name, gpu: .status.capacity["nvidia.com/gpu"]}'
```

The new node should show `"gpu": "1"` (or however many GPUs it has).

### Step 15: Test GPU Workload

```bash
kubectl run gpu-test --rm -it --restart=Never \
  --image=nvidia/cuda:12.0-base \
  --overrides='{"spec":{"containers":[{"name":"gpu-test","image":"nvidia/cuda:12.0-base","command":["nvidia-smi"],"resources":{"limits":{"nvidia.com/gpu":"1"}}}]}}' \
  -- nvidia-smi
```

---

## Part 5: Update Documentation

### Step 16: Update CLAUDE.md

Add the new node to the node table in `~/dotfiles/talos/CLAUDE.md`:

```markdown
| Node | Role | Tailscale IP | Local IP (DHCP) | GPU |
|------|------|--------------|-----------------|-----|
| talos-no1-0gw | Control Plane | 100.64.173.122 | 192.168.15.3 | AMD (unused) |
| talos-18t-abp | Worker | 100.82.76.120 | 192.168.15.4 | NVIDIA (unused) |
| talos-xxx-yyy | Worker (GPU) | 100.x.x.x | 192.168.15.x | NVIDIA (enabled) |
```

---

## Troubleshooting

### Node not appearing on network
- Check ethernet cable connection
- Verify BIOS is set to boot from USB
- Try different USB port

### Config apply fails with certificate error
- Use `--insecure` flag for first-time apply
- After Tailscale connects, use Tailscale IP instead

### Node boots but doesn't join cluster
- Check control plane is reachable: `ping 100.64.173.122`
- Verify cluster token matches in config
- Check `talosctl -n <IP> dmesg` for errors

### NVIDIA modules not loading
- Verify schematic includes `nonfree-kmod-nvidia-lts`
- Check `talosctl -n <IP> logs ext-nvidia` for errors
- Ensure kernel modules are in config

### GPU not visible in Kubernetes
- Wait for nvidia-device-plugin pods to be running
- Check plugin logs: `kubectl logs -n kube-system -l name=nvidia-device-plugin-ds`

---

## Quick Reference Commands

```bash
# Apply config to new node (first time)
talosctl apply-config -f base/worker-gpu.yaml -p @base/tailscale.patch.yaml -e <IP> -n <IP> --insecure

# Apply config to new node (after Tailscale)
talosctl apply-config -f base/worker-gpu.yaml -p @base/tailscale.patch.yaml -e 100.64.173.122 -n <TAILSCALE_IP>

# Check node status
talosctl -n <IP> health

# View logs
talosctl -n <IP> dmesg -f

# Check NVIDIA
talosctl -n <IP> read /proc/modules | grep nvidia

# Kubernetes nodes
kubectl get nodes -o wide
```

---

## Optional: Upgrade Existing Worker (talos-18t-abp)

If you also want NVIDIA on the existing worker:

```bash
# Apply NVIDIA config
talosctl apply-config \
  -f ~/dotfiles/talos/base/worker.yaml \
  -p @~/dotfiles/talos/base/tailscale.patch.yaml \
  -p @~/dotfiles/talos/base/nvidia.patch.yaml \
  -e 100.64.173.122 \
  -n 100.82.76.120

# Upgrade to new image
talosctl --nodes 100.82.76.120 upgrade \
  --image factory.talos.dev/installer/6d75b5c799b863517722adceccbb64c97d4b0309c31ad5dbfeabc729a76b9fc1:v1.12.0 \
  -m powercycle
```
