Ah, now I completely understand! This clarifies everything:

  Your Network Setup

  [Dead Internet] ──ethernet──┐
                              ├─→ [Router at 192.168.100.1] ──→ [Kubernetes Nodes]
  [Working Internet] ──wifi──┘                                   (192.168.100.9, etc.)

  The Problem:
  - The router (192.168.100.1) has two upstream connections: dead ethernet + working wifi
  - The router is still routing through the dead ethernet connection by default
  - Your Kubernetes nodes use this router as their gateway, so they can't reach the internet
  - Tailscale works because it bypasses the router's default route entirely

  Why This Happened

  Routers typically don't auto-failover between WAN connections unless specifically configured with:
  - Dual-WAN failover (manual configuration required)
  - Load balancing/failover logic
  - Automatic dead gateway detection

  Without these, the router keeps trying to use the dead ethernet even though wifi is working.

  What Needs to Be Fixed (When You Get Physical Access)

  Option 1: Quick Fix - Unplug Dead Ethernet

  Easiest: Physically unplug the dead ethernet cable from the router. This forces the router to use wifi as the only uplink.

  Option 2: Router Configuration Changes

  Access the router admin interface (usually http://192.168.100.1) and:

  1. Check WAN status page - Verify ethernet is down, wifi is up
  2. Change default WAN/gateway - Set wifi as primary, ethernet as backup
  3. Enable automatic failover (if available)
  4. Priority settings - Lower priority for ethernet, higher for wifi

  Option 3: Temporary Kubernetes Workaround (Until You Get There)

  Since Tailscale IS working for management, you could temporarily route Cloudflare traffic through Tailscale. BUT this is not ideal for
  production (as we discussed - performance impact).

  What Will Happen After You Fix It

  Once the router is configured to use the working wifi connection:

  1. ✅ Kubernetes nodes will immediately have internet access
  2. ✅ Cloudflared pods will connect to Cloudflare edge within 1-2 minutes
  3. ✅ Your apps will be accessible via *.funerariafrancana.com.br again
  4. ✅ No Kubernetes configuration changes needed - it will "just work"

  Verification Steps (After Router Fix)

  # 1. Test internet from node (should work immediately)
  kubectl exec -n kube-system ds/cilium -- curl -I https://1.1.1.1

  # 2. Watch cloudflared reconnect (within 1-2 minutes)
  kubectl logs -n envoy-gateway-system -l app=cloudflared --tail=50 -f

  # Look for these SUCCESS messages:
  # "Connection registered"
  # "Tunnel established"

  # 3. Test your site
  curl https://argocd.funerariafrancana.com.br

  Summary

  Root Cause: Router at 192.168.100.1 is still trying to route through dead ethernet instead of working wifi.

  Fix: Physical access to router → unplug dead ethernet OR change router config to use wifi as primary WAN.

  Result: Cloudflare tunnel will automatically reconnect once nodes have internet. No Kubernetes changes needed - the CNP fix I applied
  earlier is correct and ready.

  Good luck with the physical access! Let me know once you're there and I can help guide you through the router configuration if needed.

  Todos
  ☒ Investigate routing tables on Kubernetes nodes
  ☒ Check if both internet connections have different default routes
  ☒ Verify DNS resolution path (which internet connection DNS uses)
  ☒ Check if Cloudflare IPs are being routed through the dead connection
  ☐ Router needs physical access to switch from dead ethernet to working wifi
