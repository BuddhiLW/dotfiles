# ArgoCD & GHCR Token Rotation

## Problem: GitHub PAT Expiration (90 days)

GitHub Personal Access Tokens expire after 90 days. This affects:

1. **ArgoCD Git sync** - can't fetch manifests from private repos
2. **GHCR image pulls** - Kubernetes can't pull container images

### Symptoms

**ArgoCD ComparisonError:**
```
Failed to load target state: failed to generate manifest for source 1 of 1:
rpc error: code = Unknown desc = failed to list refs: authentication required:
Invalid username or token. Password authentication is not supported for Git operations.
```

**ImagePullBackOff:**
```
Failed to pull image "ghcr.io/assistencia-familiar-francana/cartas-frontend":
failed to authorize: failed to fetch oauth token: 403 Forbidden
```

## Solution: Update Secrets with Fresh PAT

Both ArgoCD and GHCR use the **same GitHub PAT** for authentication.

### Prerequisites

```bash
# Your GitHub PAT should have these scopes:
# - repo (for private Git repos)
# - read:packages (for pulling from GHCR)
# - write:packages (for pushing to GHCR)

# Stored in pass:
pass Github/BuddhiLW/ghp/all
```

### 1. Update ArgoCD Repository Secret

```bash
CR_PAT=$(pass Github/BuddhiLW/ghp/all | head -1)

# Update the password field in the repo secret
kubectl patch secret argocd-repo-k8s-a3f -n argocd-a3f \
  -p "{\"data\":{\"password\":\"$(echo -n $CR_PAT | base64 -w0)\"}}"

# Force ArgoCD to refresh
kubectl annotate application <app-name> -n argocd-a3f \
  argocd.argoproj.io/refresh=hard --overwrite
```

### 2. Update GHCR Pull Secret (per namespace)

```bash
CR_PAT=$(pass Github/BuddhiLW/ghp/all | head -1)
NAMESPACE="funeraria-francana-v2-a3f"  # or staging, dev

# Delete and recreate the secret
kubectl delete secret ghcr-secret -n $NAMESPACE --ignore-not-found

kubectl create secret docker-registry ghcr-secret \
  -n $NAMESPACE \
  --docker-server=ghcr.io \
  --docker-username=BuddhiLW \
  --docker-password="$CR_PAT"

# Restart affected deployments to pick up new secret
kubectl rollout restart deployment -n $NAMESPACE -l app.kubernetes.io/part-of=funeraria-francana
```

## Secrets Inventory

| Secret | Namespace | Purpose | Rotation |
|--------|-----------|---------|----------|
| `argocd-repo-k8s-a3f` | `argocd-a3f` | Git clone for ArgoCD | Patch password field |
| `argocd-image-updater-git-secret` | `argocd-a3f` | Image updater Git push | Patch password field |
| `ghcr-secret` | `funeraria-francana-v2-a3f` | Production image pulls | Recreate |
| `ghcr-secret` | `funeraria-staging` | Staging image pulls | Recreate |
| `ghcr-secret` | `funeraria-dev` | Dev image pulls | Recreate |

## Quick Reference: Check Secret Age

```bash
# ArgoCD secrets
kubectl get secrets -n argocd-a3f -l argocd.argoproj.io/secret-type=repository

# GHCR secrets across namespaces
for ns in funeraria-francana-v2-a3f funeraria-staging funeraria-dev; do
  echo "=== $ns ==="
  kubectl get secret ghcr-secret -n $ns -o jsonpath='{.metadata.creationTimestamp}' 2>/dev/null
  echo
done
```

## Proactive: Set Calendar Reminder

GitHub PATs expire at 90 days. Set a reminder at 80 days to rotate tokens before services fail.

**Last rotated:** 2025-12-30
**Next rotation due:** 2026-03-20 (approximately)
