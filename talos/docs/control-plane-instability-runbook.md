# Control-plane instability treatment — talosctl runbook (2026-08-01)
#
# Symptom chain: talos-l1m-v82 (T320, .137) flaps NotReady → etcd loses member →
# apiserver stalls (KubePrism localhost:7445 timeouts) → cilium-operator
# "Leader election lost" suicides (255 restarts/5d) + agent restart waves.
# Same root as 2026-06-01 incident (memory 20260601152044-108f07f0).
#
# REQUIRES: talos API reachable (LAN only — talosctl from dirichlet needs the
#   host plugged into 192.168.100.0/24 ethernet; tailscale IPs refuse :50000).

TC=~/dotfiles/talos/talosconfig.cp
CP1=192.168.100.133   # talos-dxm-gok  (minipc, NVMe)
CP2=192.168.100.134   # talos-k2l-0hh  (minipc2, NVMe)
CP3=192.168.100.137   # talos-l1m-v82  (T320, PERC RAID1 SATA — flapping)

# 1. Evidence
talosctl --talosconfig $TC -e $CP1 -n $CP1 etcd status
talosctl --talosconfig $TC -e $CP1 -n $CP1 etcd alarm list
talosctl --talosconfig $TC -e $CP3 -n $CP3 dmesg | tail -50   # bnx2/link/power events
talosctl --talosconfig $TC -e $CP3 -n $CP3 get links          # NIC state
talosctl --talosconfig $TC -e $CP3 -n $CP3 disks              # PERC vs direct SATA

# 2. If T320 keeps flapping: remove it from etcd (2 stable members beat a
#    flapping third). NOTE: 2-node etcd = no fault tolerance — re-add a stable
#    member ASAP (kanban 20260602162809-3b9f19d4).
# talosctl --talosconfig $TC -e $CP1 -n $CP1 etcd remove-member talos-l1m-v82
# Then decide: repair T320 (dmesg evidence) or demote to worker (taint it off CP).

# 3. Defrag if status shows big DB / fragmentation:
# talosctl --talosconfig $TC -e $CP1 -n $CP1 etcd defrag
# talosctl --talosconfig $TC -e $CP2 -n $CP2 etcd defrag
# talosctl --talosconfig $TC -e $CP3 -n $CP3 etcd defrag   # member by member, never parallel

# 4. NIC rename fix (worker no1-0gw): fill MAC in base/worker-nic-fix.patch.yaml
# talosctl --talosconfig $TC -e 192.168.100.136 -n 192.168.100.136 get links
# talosctl --talosconfig $TC -e 192.168.100.136 -n 192.168.100.136 patch mc --patch @base/worker-nic-fix.patch.yaml

# 5. Cilium symptom relief (already staged in k8s-a3f repo):
#    infrastructure/cilium/values.yaml — leaderElection 60/30/10 + LB-IPAM false
#    + prometheus metrics. Apply when apiserver calm:
#    helm upgrade cilium cilium/cilium -n kube-system -f infrastructure/cilium/values.yaml --version 1.18.6
