# Extension and how to apply it

Control Panel = 100.82.76.120
Worker = 100.82.76.120

```
talosctl upgrade --image factory.talos.dev/metal-installer/4a0d65c669d46663f377e7161e50cfd570c401f26fd9e7bda34a0216b6f1922b:v1.11.1 -m powercycle -f
talosctl apply-config -f controlplane.yaml -p @tailscale.patch.yaml -e 100.64.173.122 -n 100.64.173.122
talosctl apply-config -f worker.yaml -p @tailscale.patch.yaml -e 100.64.173.122 -n 100.82.76.120
```
