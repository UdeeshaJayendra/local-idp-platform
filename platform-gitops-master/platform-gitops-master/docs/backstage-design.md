# Backstage Developer Portal — Design

## Purpose
Backstage acts as the single-pane-of-glass developer portal for this platform.
It does not replace any existing component — it is a UI and catalog layer on
top of what already exists: GitHub, GitHub Actions, Argo CD, and Kubernetes.

## What Backstage Would Do Here

1. **Service Catalog** — every service (e.g. payment-service) gets a
   `catalog-info.yaml` at its repo root. Backstage reads this to register
   the service, its owner, its links (repo, CI, Argo CD app, dashboards).

2. **Software Templates ("Create Service")** — a scaffolder template that:
   - Creates a new GitHub repo from the payment-service structure
   - Injects the reusable `service-chart` Helm chart
   - Creates a GitOps entry under `apps/<service>/dev`
   - Registers a new Argo CD Application
   - Registers the new service in the Backstage catalog

3. **TechDocs** — renders each service's README/docs directly in the portal.

4. **Plugins that would link back to real, already-built infrastructure**:
   - Kubernetes plugin → shows live pod status pulled from the cluster
   - Argo CD plugin → shows sync/health status per service
   - GitHub Actions plugin → shows latest CI run status

## catalog-info.yaml (for payment-service)

This file would sit at the root of the payment-service repo:

\`\`\`yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: payment-service
  description: Payment processing REST API
  annotations:
    github.com/project-slug: UdeeshaJayendra/payment-service
    argocd/app-name: payment-service-dev
spec:
  type: service
  lifecycle: development
  owner: platform-team
  system: idp-platform
\`\`\`

## Software Template Skeleton

A Backstage scaffolder template (`template.yaml`) for "Create Service" would
define input fields (service name, language, database) and a set of steps:

\`\`\`yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: create-node-service
  title: Create Node.js Service
  description: Scaffolds a new Node.js service with CI/CD and GitOps wired in
spec:
  parameters:
    - title: Service details
      properties:
        serviceName:
          type: string
        database:
          type: string
          enum: [postgres, none]
  steps:
    - id: fetch-base
      name: Fetch skeleton
      action: fetch:template
      input:
        url: ./skeleton
        values:
          serviceName: \${{ parameters.serviceName }}
    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        repoUrl: github.com?repo=\${{ parameters.serviceName }}&owner=UdeeshaJayendra
    - id: register
      name: Register in catalog
      action: catalog:register
      input:
        repoContentsUrl: \${{ steps.publish.output.repoContentsUrl }}
        catalogInfoPath: /catalog-info.yaml
\`\`\`

## Why Not Deployed Live in This Environment

Backstage requires its own Node.js backend, a frontend build step (resource-
intensive TypeScript/webpack compilation), and its own PostgreSQL instance.
Running this alongside the existing single-node Kind cluster (which already
hosts payment-service, its database, Argo CD, and ingress-nginx) exceeded
the available memory/disk I/O on the development machine used for this
project (7GB RAM, single disk).

In a real environment, Backstage would run either:
- On a separate, dedicated node/VM, or
- As a managed service outside the application cluster entirely

This is a realistic constraint many platform teams face early on — Backstage
itself is commonly run outside the clusters it manages, precisely because it
is a control-plane tool, not a workload the application clusters need to host.

## What Was Actually Built Instead

Everything Backstage would *display* already exists and is provably working
in this project:
- Service Catalog data → available via GitHub API + \`catalog-info.yaml\` (written above)
- Argo CD status → real, running, screenshotted (Synced/Healthy)
- CI status → real, running GitHub Actions pipeline (green)
- Kubernetes pod status → real, queryable via kubectl against the live cluster

Backstage's value here is aggregation and UX, not new capability.
