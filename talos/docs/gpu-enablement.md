# GPU Enablement — blw cluster

**Status of this document:** rewritten 2026-08-07 from *measured* cluster state (every table below
comes from a command run against the live nodes, not from vendor docs). The previous version of this
file was stale — it called `talos-no1-0gw` a control plane and claimed the NVIDIA GPU was not enabled.
Both were wrong.

---

## 1. Answer up front

| Node | GPU present | Exposed to Kubernetes? | Verdict |
|------|-------------|------------------------|---------|
| `talos-18t-abp` (worker) | **RTX 3050 OEM, 8 GB, cc 8.6** | ✅ **already enabled** — `nvidia.com/gpu: 1` allocatable | Nothing to enable. It is **100 % idle**. The work is to *use* it. |
| `talos-no1-0gw` (worker) | **RX 580, 4 GB, polaris10 (gfx803)** | ❌ driver loaded, `/dev/dri` present, but no device plugin | **Enable** — worth it for VA-API transcode + Vulkan/OpenCL compute. Do **not** expect ROCm. |
| `talos-dxm-gok` (CP, MPC1) | **UHD 630 (Gen9.5)** | ❌ i915 loaded, `/dev/dri` present, no plugin | **Technically works** (proven, see §3). Politically inadvisable — it is an etcd voter. |
| `talos-k2l-0hh` (CP, MPC2) | **UHD 630 (Gen9.5)** | ❌ same | Same. Recommend leaving clean. |
| `talos-l1m-v82` (CP, T320) | **Matrox G200eR2 only** | n/a — no `/dev/dri` at all | **No GPU is possible** without buying hardware, and it should not get one. See §6. |

The single biggest surprise: **the GPU that is already enabled has never run a single GPU workload.**
`nvidia-smi` reports 0 % utilisation, 1 MiB of 8192 MiB used, no processes. Before adding any GPU
anywhere, the highest-value action is to put a workload on the RTX 3050.

---

## 2. Measured inventory

### PCI display devices (`talosctl get pcidevices`)

```
.137  T320   Matrox Electronics Systems Ltd. | G200eR2                        <- BMC video only
.133  MPC1   Intel Corporation | CometLake-S GT2 [UHD Graphics 630]
.134  MPC2   Intel Corporation | CometLake-S GT2 [UHD Graphics 630]
.9    GPU-W  NVIDIA Corporation | GA106 [GeForce RTX 3050 OEM]
.136  AMD-W  AMD/ATI | Ellesmere [Radeon RX 470/480/570/580/590]
```

T320's Xeon E5-2450L (Sandy Bridge-EN) has **no integrated graphics**, and the G200eR2 is an iDRAC
console chip with no compute path — `talosctl ls /dev/dri` on `.137` returns
`no such file or directory`. That is a hardware fact, not a configuration gap.

### Extensions actually installed (not what the configs claim)

| Node | GPU-relevant extensions |
|------|-------------------------|
| `.9` GPU worker | `nonfree-kmod-nvidia-lts 580.173.02-v1.13.7`, `nvidia-container-toolkit-lts 580.173.02-v1.19.1`, `i915`, `fuse3`, `nvme-cli` |
| `.136` AMD worker | `amdgpu 20260622-v1.13.7` |
| `.133`/`.134` CPs | `i915 20260622-v1.13.7`, `mei` |
| `.137` T320 | none |

### Node headroom (`kubectl describe nodes`, *requests*)

| Node | CPU requested | Memory requested |
|------|---------------|------------------|
| `talos-18t-abp` (has the NVIDIA GPU) | **15244m / 16 cores — 95 %** | 61 % |
| `talos-no1-0gw` (has the AMD GPU) | **11409m / 12 cores — 95 %** | 51 % |
| `talos-dxm-gok` (CP) | 810m — 6 % | 11 % |
| `talos-k2l-0hh` (CP) | 811m — 6 % | 11 % |
| `talos-l1m-v82` (CP) | 710m — 4 % | 11 % |

**This is the real constraint, and it is not a GPU constraint.** Both GPU-bearing workers are at 95 %
of *schedulable CPU requests*. A new GPU pod will be rejected by the scheduler for lack of CPU long
before it is rejected for lack of GPU. The requests are almost certainly inflated — the bulk is ~100
identical `100m` boilerplate requests — but the scheduler bills requests, not usage. (The metrics API
is not installed, so actual usage could not be measured: `kubectl top nodes` → *Metrics API not
available*. Installing metrics-server would let this be right-sized with evidence.)

The idle capacity in this cluster is on the control planes. The GPUs are on the saturated workers.

---

## 3. What each GPU can actually do — measured, not assumed

All three were probed with a real pod on the real node.

### RTX 3050 OEM — `talos-18t-abp` ✅ full CUDA, working end to end

```
$ kubectl run … --overrides '{"runtimeClassName":"nvidia", …, "limits":{"nvidia.com/gpu":1}}' -- nvidia-smi
NVIDIA-SMI 580.173.02   Driver Version: 580.173.02   CUDA Version: 13.0
NVIDIA GeForce RTX 3050 OEM   |   1MiB / 8192MiB   |   0%   |   57C   |   11W / 120W
name, memory.total, compute_cap  ->  NVIDIA GeForce RTX 3050 OEM, 8192 MiB, 8.6
```

- `RuntimeClass nvidia` exists (220 d old) and the kubelet advertises the `nvidia` runtime handler.
- `nvidia-device-plugin-daemonset` (v0.14.5) is healthy: 1/1 Running, and it **self-heals** — the pod
  was deliberately deleted during this study and was recreated and Ready in 22 s.
- ⚠️ **`runtimeClassName: nvidia` is mandatory.** A pod that requests `nvidia.com/gpu: 1` without it
  starts and then fails with `exec: "nvidia-smi": executable file not found` — the toolkit hook never
  runs, so no driver libraries are injected. This is the #1 trap on Talos and cost the first probe.
- Ampere, cc 8.6 → FP16/BF16 tensor cores, CUDA 13, 8 GB. This is a *real* inference GPU for models
  up to ~7-8B at 4-bit, or Whisper large-v3 at fp16 with room to spare.

### RX 580 — `talos-no1-0gw` ✅ Vulkan + OpenCL + full VA-API; ❌ ROCm

VRAM is **4 GB** (`mem_info_vram_total = 4294967296`), i.e. the 4 GB RX 580 variant, not 8 GB.

```
=== Vulkan ===   driverID = DRIVER_ID_MESA_RADV, driverName = radv, Mesa 22.3.6   (+ llvmpipe fallback)
=== OpenCL ===   Platform #0: Clover  -> AMD Radeon RX 580 Series (polaris10, LLVM 15.0.6, DRM 3.64, 6.18.39-talos)
                 Platform #1: rusticl
=== VA-API ===   Mesa Gallium driver 22.3.6 for AMD Radeon RX 580 Series (polaris10)
    H264 Main/High/CBaseline : VLD + EncSlice     <- decode AND encode
    HEVC Main                : VLD + EncSlice     <- decode AND encode
    HEVC Main10              : VLD
    MPEG2, VC1, JPEG         : VLD
    VAProfileNone            : VideoProc          <- scaling / deinterlace / colour convert
```

`/dev/kfd` **is** present, so the kernel compute path exists — but ROCm userspace dropped gfx803
(Polaris) years ago. Treat ROCm as unavailable and do not plan around it. The usable compute paths
are **Vulkan (RADV)** — which is what `llama.cpp` / `whisper.cpp` use for AMD these days — and
**OpenCL (Clover/rusticl)**, which is slow and quirky. HEVC *encode* on Polaris was a genuine
surprise; it makes this card a legitimate transcode engine.

Note `/dev/dri/renderD128` is mode `crw-rw-rw-` on both AMD and Intel nodes, so once the container's
device cgroup permits the node, no special UID/GID handling is needed.

### UHD 630 (both mini-PC CPs) ✅ VA-API + OpenCL/NEO

Probed on `talos-dxm-gok` with a control-plane toleration:

```
=== VA-API === Intel iHD driver for Intel(R) Gen Graphics - 23.1.1
    H264 Main/High/CBaseline : VLD + EncSlice + EncSliceLP + FEI
    MPEG2 / VC1 / VP8 / JPEG : VLD (+ MPEG2, VP8, JPEG encode)
    VAProfileNone            : VideoProc + Stats
=== OpenCL === Platform #0: Intel(R) OpenCL HD Graphics
               `-- Device #0: Intel(R) UHD Graphics 630 [0x9bc8]
```

OpenCL through the Intel NEO runtime works, which means **OpenVINO's GPU plugin would work** — that
is the interesting path (whisper.cpp has an OpenVINO encoder backend worth ~2-4× over CPU on Gen9.5).
Raw compute is tiny (24 EUs, ~0.4 TFLOPS FP32); the real value of these chips is the *fixed-function*
video engine, which costs almost no CPU.

---

## 4. Fit against the services you named

| Workload | Best target | Honest assessment |
|----------|-------------|-------------------|
| **vtranslate — ASR (whisper)** | **RTX 3050** | The clear win. `whisper large-v3-turbo` (~1.6 GB fp16) or `large-v3` (~3.1 GB) fit in 8 GB with room for batching. ASR is, by vtranslate's own design notes, *"the only stage that costs minutes"* — everything else is API calls or pure Clojure. |
| **vtranslate — translation (MT)** | stays external | Currently Venice `gemma-4-uncensored` via an OpenAI-compatible API. An 8 GB local model would be a quality downgrade for translation. Keep the API; GPU-host it only if cost or privacy forces it. |
| **vtranslate — ffmpeg audio extraction** | AMD RX 580 / Intel iGPU | Decode offload only. Audio extraction is cheap; matters only if you start compositing/burning-in subtitles (`:composer :hard`), where the AMD card's H.264/HEVC **encode** is a genuine offload. |
| **OSM — raster tiles (mapnik / renderd)** | **none** | Mapnik is CPU + I/O bound with no GPU path. A GPU will not help. Don't plan around it. |
| **OSM — vector tile rasterisation (tileserver-gl / maplibre-native)** | AMD RX 580, or Intel iGPU | This one *does* use OpenGL and today would fall back to `llvmpipe` on CPU. Pointing it at a DRI render node via EGL is a real speedup — and it is exactly the kind of low-VRAM, bursty job the RX 580 suits. |
| **OSM — routing / geocoding (OSRM, Valhalla, Nominatim)** | **none** | CPU, RAM and disk. No GPU path exists. |
| **Milvus vector index** | RTX 3050 (conditionally) | Milvus GPU indexes (CAGRA/IVF) need cc ≥ 7.0 — 8.6 qualifies. But it only pays off past roughly a million vectors, the GPU image is heavy, and it would contend for the same 8 GB as Whisper. Not now. |
| **Local LLM (ollama / vLLM)** | RTX 3050 | 7-8B at 4-bit fits. Fine for experiments; do not expect it to replace the Venice/OpenRouter calls for quality-sensitive work. |

### The vtranslate seam is already built

`vtranslate-engine/src/vtranslate/engine/providers/router.clj:18` declares the ASR providers:

```clojure
[:whisper-local :whisper-ffm :sherpa-onnx :onnx-bytedeco :qwen3-asr
 :groq :openai-whisper :whisper-server]
```

`:whisper-server` is documented in `adapters/transcriber/openai_compatible.clj` as *"a local
whisper.cpp / faster-whisper-server"* speaking the OpenAI transcription API. So **GPU ASR requires no
engine code change at all** — stand up a CUDA whisper server in-cluster, and set
`[:providers :transcriber] :whisper-server` with its cluster URL in the vtranslate config. The DIP
boundary that was built for provider-swapping is exactly the seam the GPU plugs into.

(The deployed `vtranslate-app` currently requests 200m CPU / 512Mi and runs 2 replicas, one on each
worker. It is not doing ASR in-cluster today.)

---

## 5. Recommended plan

Staged so each step is independently useful and independently reversible.

### Stage 0 — use the GPU you already have *(no Talos change, no reboot, no risk)*

1. Deploy **one GPU-resident inference service** on `talos-18t-abp` — `whisper.cpp` server or
   `faster-whisper-server`, CUDA build — with `runtimeClassName: nvidia` and
   `limits: {nvidia.com/gpu: 1}`. Give it a modest CPU request; the node has GPU room but no CPU room.
2. Point vtranslate at it: `[:providers :transcriber] :whisper-server`.
3. Prefer **one shared GPU service behind HTTP** over device-level sharing. With a single 8 GB card,
   a service that owns the GPU and multiplexes requests beats time-slicing, which gives no memory
   isolation and lets one OOM take out every tenant.
4. Only if you genuinely need several GPU *pods*: enable time-slicing in the device plugin
   (`replicas: 2..4`). Then also upgrade the plugin — **v0.14.5 is ~2 years old**; v0.17.x has the
   health-check and time-slicing fixes.

### Stage 1 — enable the AMD RX 580 *(no Talos change either — the driver is already loaded)*

The `amdgpu` extension is installed and `/dev/dri/{card0,renderD128}` exist. All that is missing is a
device plugin to make the render node a schedulable resource. Two options:

- **`squat/generic-device-plugin`** *(recommended)* — one DaemonSet, exposes `/dev/dri/renderD128` as
  a countable resource (e.g. `squat.ai/dri`). Works identically for AMD and Intel, needs no
  node-feature-discovery, and does not pretend the card is ROCm-capable.
- `rocm/k8s-device-plugin` — advertises `amd.com/gpu` and would technically bind (`/dev/kfd` exists),
  but it implies a ROCm stack that gfx803 cannot deliver. Avoid; it will mislead future readers.

Then the consumers: `ffmpeg` with VA-API for transcode, `llama.cpp`/`whisper.cpp` **Vulkan** builds
for compute, and `tileserver-gl` with EGL for OSM vector tiles. 4 GB VRAM is the ceiling — it fits
Whisper `small`/`medium`, not `large-v3`.

### Stage 2 — the Intel iGPUs on the control planes *(optional; I recommend against)*

It works — §3 proves it. The objection is not technical:

- All three CPs are etcd voters, and this cluster's entire failure history is etcd fragility:
  corruption after unclean shutdown (2026-01-31, 2026-02-03), a slow disk blocking `MemberPromote`
  (2026-04-09), split-brain (2026-04-09), and a ~71-minute reboot loop on every CP (2026-08-07). The
  T320 was bought *specifically* to stop this class of failure.
- GPU work is not free of CPU and memory — a transcode pod that starves `etcd` re-creates the exact
  2026-04-09 symptom, and the mini PCs are the two *load-bearing* voters.

If you want that idle capacity anyway, the least-bad shape is: **MPC1 only** (leave MPC2 pristine so
one healthy voter is never touched), a low `priorityClassName` well below `system-node-critical`,
hard CPU and memory *limits*, and only bursty non-critical jobs. Revisit the moment a 3rd worker
exists — that is the correct place for this work.

### Stage 3 — cross-cutting, do these regardless

- **Install metrics-server.** Right now nobody can see actual CPU usage, only requests, and the
  requests say both workers are 95 % full. Without measurement the 95 % cannot be safely challenged.
- **Right-size CPU requests** on the ~100 boilerplate `100m` pods. This, not GPU capacity, is what
  currently blocks new GPU workloads from scheduling.
- **Fix `base/worker.yaml` repo drift** — see §7. It is a live footgun.

---

## 6. The T320: no

The T320 has no GPU and no integrated graphics. Adding one is *physically* plausible — it has PCIe
3.0 slots and dual 495 W PSUs — but with no PCIe auxiliary power connectors you are limited to a
75 W slot-powered card (Tesla P4 8 GB, RTX A400, Quadro P620), and a tower chassis gives a passive
server card poor airflow. Verify slot availability and clearance physically before believing any of
that.

But the recommendation is **don't**, on strategy rather than physics:

- The T320 is the etcd anchor. It was chosen for ECC + power-loss-protected SSDs precisely to counter
  the cluster's dominant failure mode, and it is the **sole active backend** of the kubectl HAProxy
  LB. Every GPU workload placed there is contention against the one node whose job is to be boring.
- Its CPU is an 8c/16t 1.8 GHz E5-2450L — the weakest per-core in the fleet. A GPU there would be fed
  by the slowest host in the cluster.
- If more GPU capacity is genuinely needed, a second card in the 13400F worker, or a third worker,
  buys more and risks nothing.

There is also an unresolved hardware item on this box: **T320 PSU #2 is dead** (open kanban task
`20260724174233-5dbde5bb`). Adding a GPU while running on a single PSU trades away the redundancy
that was the reason to buy the machine.

---

## 7. Findings incidental to this study

1. **[FIXED 2026-09-21]** **`base/worker.yaml` points at the wrong schematic, and it is dangerous.** The file specifies
   `68c3b8b96ed13e5cdb05795811a135543cd21e64a7d0a8acca827aeb76214028` — the *superseded mini-PC CP*
   schematic, which **contains `nut-client`**. The AMD worker actually runs
   `836a1d743599cd04a2b12750a055d86d518f2cf03386d2588c8c9ec3a0f156b3`. Applying `base/worker.yaml`
   as written would ship an extension service with no `ExtensionServiceConfig` — i.e. reproduce the
   2026-08-07 reboot loop, this time on a worker. Fix the file to `836a1d74…`.
2. **[FIXED 2026-09-21, and it was worse than described]** `base/worker-gpu.yaml` still selects the install disk as `disk: /dev/sda` rather than by WWID —
   the same class of hazard the T320 install avoided by using `install.diskSelector.wwid`.
3. The `nvidia-device-plugin` DaemonSet *status* was stale (`desired: 0, misscheduled: 1`) while the
   pod was in fact healthy. It reconciled to `1/1` correctly on pod deletion. Cosmetic; no action.
   **Still in that state 2026-09-21** (same reading, pod up 45 d). Recurring, still cosmetic: the
   reconcile-on-delete test above is what rules out the scary reading.
4. The device plugin image is `nvcr.io/nvidia/k8s-device-plugin:v0.14.5` — worth upgrading.

---

## 8. Reproducing the measurements

```bash
# GPU allocatable + GPU-related labels, all nodes
kubectl get nodes -o json | jq -r '.items[] | "\(.metadata.name) \(.status.allocatable | with_entries(select(.key|test("gpu"))))"'

# Display controllers per node
talosctl -n <ip> --talosconfig base/talosconfig get pcidevices -o json \
  | jq -r 'select(.spec.class=="Display controller") | "\(.spec.vendor) | \(.spec.product)"'

# Render nodes present?
talosctl -n <ip> --talosconfig base/talosconfig ls /dev/dri

# NVIDIA end-to-end — runtimeClassName: nvidia is REQUIRED
kubectl run gpu-probe --image=nvidia/cuda:12.4.1-base-ubuntu22.04 --restart=Never \
  --overrides='{"spec":{"runtimeClassName":"nvidia","nodeSelector":{"nvidia.com/gpu.present":"true"},
                "containers":[{"name":"p","image":"nvidia/cuda:12.4.1-base-ubuntu22.04",
                "command":["nvidia-smi"],"resources":{"limits":{"nvidia.com/gpu":"1"}}}]}}'

# AMD / Intel capability probe: privileged pod + hostPath /dev/dri, then
#   vainfo                      (VA-API codecs)
#   vulkaninfo --summary        (RADV / ANV device enumeration)
#   clinfo -l                   (OpenCL platforms)
# NOTE: needs a namespace labelled pod-security.kubernetes.io/enforce=privileged —
# the cluster enforces PodSecurity baseline, which rejects privileged + hostPath.
```


---

## 9. Stage 1 executed — 2026-09-21

The RX 580 is now a schedulable resource. Verified end to end, not inferred.

### What the gap actually was

§5 Stage 1 called for a device plugin. By 2026-09-21 one was already deployed:
`kube-system/generic-device-plugin`, with

    --domain=gpu.blw
    --device={"name":"dri","groups":[{"count":4,"paths":[{"path":"/dev/dri/renderD128"}]}]}
    nodeSelector: gpu.blw/dri=true

but **no node had ever carried `gpu.blw/dri=true`**, so it sat at
`desired=0` and had never run. The mechanism was complete and switched off.
The missing piece was one node label, not an install.

### What was done

`base/gpu-dri.patch.yaml` supplies the label from the **machine config**, not
`kubectl label node`, so it survives a reset, a reinstall and a re-apply, and
the cluster does not drift from the repo.

    talosctl -n 192.168.100.136 --talosconfig base/talosconfig \
      patch machineconfig --patch @base/gpu-dri.patch.yaml

Applied without a reboot. Diff was a single `machine.nodeLabels` addition.

### Measured result

    label present after 1 s
    generic-device-plugin        desired 0 -> 1, ready 1/1
    talos-21a-oep allocatable    gpu.blw/dri = 4

    talos-18t-abp   {"nvidia.com/gpu":"1"}
    talos-21a-oep   {"gpu.blw/dri":"4"}

End-to-end probe: an **unprivileged** pod with no hostPath, requesting
`limits: {gpu.blw/dri: 1}`, scheduled onto talos-21a-oep and saw

    crw-rw-rw- 1 root root 226, 128 /dev/dri/renderD128

So the device is injected by the plugin under PodSecurity **baseline**. The
privileged-namespace caveat in §8 applies only to the hostPath probe style,
not to consumers that request the resource properly.

### Why the label is on .136 ONLY

Measured 2026-09-21, `talosctl ls /dev/dri/by-path`:

    .9   (18t)  renderD128 -> pci-0000:01:00.0   = the NVIDIA GA106 itself
    .136 (21a)  renderD128 -> pci-0000:08:00.0   = the Radeon RX 580

Labelling 18t would advertise **one physical GPU under two resource names**,
`nvidia.com/gpu` and `gpu.blw/dri`, and let two pods each believe they own it.
The Intel UHD on that i5-13400F does not currently enumerate a second render
node, so there is nothing to gain there either. Do not label .9 unless a second
render node appears.

### Next, in order

1. Point a consumer at it: ffmpeg VA-API for subtitle burn-in is the obvious
   first, and it is the `:burn-backend` seam in §4. On this node that backend
   is `:ffmpeg-vaapi`, **not** `:ffmpeg-nvenc`.
2. `count: 4` on the render node was never justified. It is a sharing
   *fan-out*, not a capability: four pods each get the same `renderD128` with
   no isolation between them. Pick it from measured concurrency, not taste.
3. Whether the image carries the Mesa/VA-API userspace. §3 proved the driver
   stack works on the node; it does not prove an arbitrary container has
   `libva` and the `radeonsi` driver in it.
