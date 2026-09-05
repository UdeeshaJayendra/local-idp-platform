#!/usr/bin/env bash
set -euo pipefail

# Golden Path service scaffolder
# Usage: ./create-service.sh <service-name>

SERVICE_NAME="${1:?Usage: ./create-service.sh <service-name>}"
GITHUB_USER="UdeeshaJayendra"
GITOPS_REPO_PATH="$HOME/idp-project/gitops"
TEMPLATE_SOURCE="$HOME/idp-project/services/payment-service"
NEW_SERVICE_PATH="$HOME/idp-project/services/${SERVICE_NAME}"

echo "==> Creating new service: ${SERVICE_NAME}"

# 1. Scaffold app code from the payment-service template
echo "==> Copying base service template..."
cp -r "$TEMPLATE_SOURCE" "$NEW_SERVICE_PATH"
rm -rf "${NEW_SERVICE_PATH}/.git" "${NEW_SERVICE_PATH}/node_modules"

# 2. Rename references
sed -i "s/payment-service/${SERVICE_NAME}/g" "${NEW_SERVICE_PATH}/package.json"

# 3. Create GitHub repo and push
echo "==> Creating GitHub repository..."
cd "$NEW_SERVICE_PATH"
git init
git add .
git commit -m "Initial scaffold for ${SERVICE_NAME}"
gh repo create "${SERVICE_NAME}" --public --source=. --remote=origin --push

# 4. Create GitOps values file from the reusable Helm chart
echo "==> Wiring up GitOps entry..."
mkdir -p "${GITOPS_REPO_PATH}/apps/${SERVICE_NAME}-helm"
cat > "${GITOPS_REPO_PATH}/apps/${SERVICE_NAME}-helm/values-dev.yaml" << YAML
serviceName: ${SERVICE_NAME}
namespace: dev

image:
  repository: ghcr.io/${GITHUB_USER}/${SERVICE_NAME}
  tag: latest

replicaCount: 2

ingress:
  enabled: true
  host: ${SERVICE_NAME}.dev.local

hpa:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
YAML

cp "${GITOPS_REPO_PATH}/charts/service-chart/values-dev.yaml" "${GITOPS_REPO_PATH}/charts/service-chart/values-dev-${SERVICE_NAME}.yaml" 2>/dev/null || true

# 5. Register Argo CD Application
cat > "${GITOPS_REPO_PATH}/argocd-apps/${SERVICE_NAME}-dev.yaml" << YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${SERVICE_NAME}-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/${GITHUB_USER}/platform-gitops.git
    targetRevision: master
    path: charts/service-chart
    helm:
      valueFiles:
        - ../../apps/${SERVICE_NAME}-helm/values-dev.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
