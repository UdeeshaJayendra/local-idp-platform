# HashiCorp Vault — Secrets Management Design

## The Problem It Solves

Today, `payment-service`'s database password lives as a Kubernetes Secret
(base64-encoded, not encrypted) and is set via plaintext values in the
`platform-gitops` repo (`values-dev.yaml`, `values-staging.yaml`,
`values-production.yaml`). Anyone with read access to those Git repos or
`kubectl get secret -o yaml` can see the credential in plain text.

Vault removes secrets from both Git and Kubernetes Secrets entirely.

## Intended Architecture

\`\`\`
Pod starts
    |
    v
Vault Agent Injector (mutating webhook)
    |
    v
Sidecar container fetches secret from Vault at runtime
    |
    v
Secret mounted as a file inside the pod (never as an env var, never in Git)
\`\`\`

Pods are annotated to opt into injection:

\`\`\`yaml
metadata:
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "payment-service"
    vault.hashicorp.com/agent-inject-secret-db-creds: "secret/data/payment-service/dev"
\`\`\`

The application would read the mounted secret file at startup instead of
an environment variable — the `service-chart` Helm chart would need a
`vault.enabled` toggle to switch between the current ConfigMap/Secret model
and Vault injection, without changing the app code itself (both approaches
can write to the same file path convention).

## Per-Environment Secret Paths

\`\`\`
secret/data/payment-service/dev
secret/data/payment-service/staging
secret/data/payment-service/production
\`\`\`

Each environment's Postgres password would be stored at its own Vault path,
with Vault policies restricting which Kubernetes ServiceAccount can read
which path — so a dev-namespace pod cannot read production secrets, enforced
by Vault itself, not just Kubernetes RBAC.

## Why Not Deployed Live in This Environment

During this project, installing Vault (even in lightweight dev mode, no HA,
no persistent storage) alongside the already-running stack — Argo CD,
Prometheus/Grafana, Kyverno, and three environments of payment-service —
pushed the development machine's load average to 27+ for the third time
in this session, each time requiring the cluster to be stopped and the
system given several minutes to recover.

This was a deliberate engineering decision, not a failed attempt: after
observing this resource ceiling repeat three separate times (once installing
Argo CD, once installing a full 3-node cluster, once here), continuing to
force additional components onto the same single-node, 7GB development
machine had diminishing return and genuine risk of destabilizing work
already proven and screenshotted in earlier phases.

In a real environment, Vault is commonly run as shared, centralized
infrastructure — one Vault cluster serving many application clusters —
rather than co-located inside every Kubernetes cluster it protects. Treating
it as external infrastructure here (documented, not embedded in this Kind
cluster) reflects that common real-world pattern rather than a shortcut.

## What Was Actually Built Instead

The current secret handling (Kubernetes Secrets sourced from Helm values)
is explicitly the "quick, dev-appropriate" version, called out as such
in the project's own troubleshooting history — the same credential
mismatch that broke `payment-service` in staging (Phase 9) was diagnosed
and fixed using this simpler model, which is itself a demonstration of
understanding the gap Vault would close.
