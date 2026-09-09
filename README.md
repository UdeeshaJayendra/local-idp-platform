# Local Internal Developer Platform — GitOps-Based

A self-service internal developer platform built from scratch, demonstrating
end-to-end software delivery: from a developer's code commit to a running,
observable, self-healing service in Kubernetes — with no manual `kubectl apply`
in the deployment path

## Architecture


## Repositories

| Repo | Purpose |
|---|---|
| [infrastructure](https://github.com/UdeeshaJayendra/infrastructure) | Terraform: Kind cluster, namespaces, ingress-nginx, Argo CD |
| [payment-service](https://github.com/UdeeshaJayendra/payment-service) | Node.js/Express/PostgreSQL app + CI pipeline |
| [platform-gitops](https://github.com/UdeeshaJayendra/platform-gitops) | Desired-state repo Argo CD watches: Helm chart, values, Argo CD Applications |
| [platform-cli](https://github.com/UdeeshaJayendra/platform-cli) | Golden-path scaffolder script — automates repo/CI/GitOps setup for a new service |



The platform demonstrates an end-to-end developer workflow:

**Developer → GitHub → CI/CD → Container Registry → GitOps → Argo CD → Kubernetes → Application → Monitoring & Security**

The project is implemented across four repositories that work together as a single platform.

---

## Project Overview
<img width="1408" height="768" alt="4" src="https://github.com/user-attachments/assets/eeb5d073-7831-4756-adb5-e1a58456a586" />

The goal of this project is to simulate how an internal platform team can provide developers with a **standardized golden path** for deploying services without requiring developers to manually manage Kubernetes manifests or execute `kubectl apply` as part of the normal deployment workflow.

A developer can work with the application repository while the platform handles:

* Infrastructure provisioning
* Kubernetes cluster setup
* Containerization
* CI/CD
* Security scanning
* Container image publishing
* GitOps deployment
* Environment configuration
* Application health checks
* Autoscaling
* Network policies
* Policy enforcement
* Monitoring
* Service scaffolding

This project was designed and implemented as a practical platform engineering system rather than as a collection of isolated tutorials.

## Screenshots

## Argo CD dashboard
<img width="1917" height="902" alt="1" src="https://github.com/user-attachments/assets/2c126592-2954-4f18-98ec-b4f018fbba67" />
<img width="1917" height="902" alt="1a" src="https://github.com/user-attachments/assets/3bdd0382-1cdb-4318-b0b9-9589b415df0b" />
<img width="1917" height="902" alt="1b" src="https://github.com/user-attachments/assets/786c9c15-43c2-48aa-b84e-c5ad61f884d1" />

## Grafana dashboard with real metrics
<img width="1917" height="886" alt="2" src="https://github.com/user-attachments/assets/ab4c4898-8793-4bb1-b3b2-2fbcb4ce4720" />

## Kyverno blocking a bad deployment
<img width="1917" height="584" alt="3" src="https://github.com/user-attachments/assets/23004b19-c5f8-4796-8acb-6609b0761512" />

## GitHub Actions green CI run
<img width="1917" height="659" alt="4" src="https://github.com/user-attachments/assets/bcd146a6-1379-45c3-bebc-115e389f10b0" />

## Real API calls against the deployed service — same app, three environments, real data
<img width="1917" height="575" alt="5" src="https://github.com/user-attachments/assets/021c3929-007e-493d-8af7-1cf65ed0cab2" />

## GitOps commit
<img width="1681" height="314" alt="6" src="https://github.com/user-attachments/assets/15320ba2-b5eb-4824-bdbe-c55c9b10fb6d" />

---

# Architecture

```text
                         Developer
                            |
                            v
                    +----------------+
                    |    GitHub      |
                    | Application    |
                    | Repository     |
                    +-------+--------+
                            |
                            v
                    +----------------+
                    | GitHub Actions |
                    |      CI        |
                    +-------+--------+
                            |
             +--------------+--------------+
             |                             |
             v                             v
      Security Scanning             Docker Build
      - Gitleaks                    - Docker image
      - npm audit                   - Trivy scan
                                    - Push to GHCR
                                           |
                                           v
                                  +------------------+
                                  | Container        |
                                  | Registry (GHCR)  |
                                  +---------+--------+
                                            |
                                            v
                                  +------------------+
                                  | platform-gitops  |
                                  |                  |
                                  | Helm Chart       |
                                  | Environment      |
                                  | Values           |
                                  | Argo CD Apps     |
                                  +---------+--------+
                                            |
                                            v
                                      +-----------+
                                      | Argo CD   |
                                      | GitOps    |
                                      +-----+-----+
                                            |
                                            v
                              +---------------------------+
                              | Kubernetes / Kind         |
                              |                           |
                              |  +---------------------+  |
                              |  | payment-service     |  |
                              |  +----------+----------+  |
                              |             |             |
                              |             v             |
                              |       +-----------+       |
                              |       | PostgreSQL|       |
                              |       +-----------+       |
                              |                           |
                              |  Ingress-NGINX            |
                              |  HPA                      |
                              |  NetworkPolicy            |
                              |  Kyverno                  |
                              |                           |
                              |  Prometheus               |
                              |  Grafana                  |
                              |  node-exporter            |
                              +---------------------------+
```

---


# Project Structure

The overall project is organized into four repositories:

```text
IDP Platform
│
├── infrastructure/
│   ├── Terraform
│   ├── Kubernetes
│   ├── Argo CD
│   ├── Ingress
│   ├── Monitoring
│   └── Kyverno
│
├── payment-service/
│   ├── Node.js application
│   ├── PostgreSQL integration
│   ├── Dockerfile
│   └── GitHub Actions
│
├── platform-gitops/
│   ├── Helm charts
│   ├── Environment values
│   ├── Argo CD Applications
│   ├── GitOps configuration
│   └── Architecture documentation
│
└── platform-cli/
    ├── Service scaffolder
    ├── Repository automation
    ├── CI configuration
    └── GitOps automation
```


### Infrastructure

Terraform provisions the local Kubernetes platform, including:

* Kind Kubernetes cluster
* Kubernetes namespaces
* Ingress-NGINX
* Argo CD
* Prometheus
* Grafana
* node-exporter
* Kyverno

The infrastructure is reproducible using:

```bash
terraform init
terraform plan
terraform apply
```

---

### Payment Service

The example application used to demonstrate the platform workflow.

**Technology:**

* Node.js
* Express.js
* PostgreSQL
* Docker
* Kubernetes
* GitHub Actions
* GHCR

API endpoints:

```text
GET  /healthz
GET  /readyz
POST /payments
GET  /payments
```

The application is containerized and goes through automated CI security checks before the image is published.

---

### Platform GitOps

Contains the desired Kubernetes state managed through Git.

It includes:

* Reusable Helm chart
* Environment-specific values
* Argo CD Applications
* Kubernetes configuration
* GitOps documentation

Git acts as the **source of truth**.

```text
Git Repository
      |
      v
   Argo CD
      |
      v
 Kubernetes
```

No manual `kubectl apply` is required in the normal deployment path.

---

### Platform CLI

Provides a scripted **golden path** for onboarding new services.

The CLI automates platform setup such as:

* Application scaffolding
* GitHub repository creation
* CI configuration
* GitOps configuration
* Argo CD Application registration

The goal is to allow developers to create services using a standardized platform workflow instead of configuring everything manually.

---

# End-to-End Workflow

```text
1. Developer pushes code
          |
          v
2. GitHub Actions
          |
          +---- Tests
          +---- Gitleaks
          +---- npm audit
          +---- Docker Build
          +---- Trivy Scan
          |
          v
3. Image pushed to GHCR
          |
          v
4. GitOps configuration
          |
          v
5. Argo CD detects Git change
          |
          v
6. Kubernetes deployment
          |
          v
7. Application available through Ingress
          |
          v
8. Prometheus collects metrics
          |
          v
9. Grafana visualizes metrics
```

---


# Kubernetes Platform

The platform includes several Kubernetes capabilities:

* Ingress-NGINX
* Health probes
* Resource requests and limits
* Horizontal Pod Autoscaler
* NetworkPolicy
* Namespace isolation
* Kyverno admission policies

The payment service uses:

```text
/healthz → Liveness Probe
/readyz  → Readiness Probe
```

---

# Multi-Environment Deployment

The same Helm-based deployment model is used for:

```text
Development
Staging
Production
```

Deployment behavior:

```text
Dev         → Automatic Sync
Staging     → Automatic Sync
Production → Manual Sync
```

This demonstrates environment separation while keeping Git as the source of truth.

---

# Observability

The platform includes:

* Prometheus
* Grafana
* node-exporter

Metrics can be used to monitor:

* CPU usage
* Memory usage
* Node metrics
* Pod status
* Kubernetes objects
* Workload health

```text
Kubernetes
     |
     v
Prometheus
     |
     v
Grafana
```

---

# Security / DevSecOps

Security is integrated into both CI and Kubernetes.

### CI Security

**Gitleaks**

Detects accidentally committed secrets.

**npm audit**

Checks Node.js dependencies for known vulnerabilities.

**Trivy**

Scans container images for known vulnerabilities.

```text
Code
 |
 +---- Gitleaks
 +---- npm audit
 +---- Trivy
 |
 v
GHCR
```

### Kubernetes Security

Kyverno enforces admission policies such as:

```text
No privileged containers
        +
Required CPU / Memory limits
        +
No :latest image tags
```

Non-compliant workloads are rejected by the Kubernetes admission process.

---

# Verified Features

The following components have been implemented and tested as part of the project:

* Terraform infrastructure
* Local Kind Kubernetes cluster
* Ingress-NGINX
* Argo CD
* GitOps deployment
* Argo CD self-healing
* Helm
* Docker
* GitHub Actions
* GHCR
* Gitleaks
* npm audit
* Trivy
* Node.js / Express
* PostgreSQL
* Liveness/readiness probes
* HPA
* NetworkPolicy
* Multi-environment deployment
* Prometheus
* Grafana
* node-exporter
* Kyverno
* Golden-path service scaffolding

---

# Engineering Challenges

The project involved real infrastructure debugging, including:

### Kind Ingress Scheduling

Resolved ingress scheduling problems using node labels and `nodeSelector` configuration.

### Container Image Pull Failures

Diagnosed IPv6 image-pull timeouts and loaded required images into Kind through the host Docker environment.

### Helm Type Coercion

Resolved incorrect value types caused by Helm `--set` usage by using structured YAML configuration.

### Argo CD Pruning

Separated PostgreSQL from the application's Helm-managed lifecycle to prevent unintended pruning.

### PostgreSQL Authentication

Diagnosed application `503` errors through PostgreSQL authentication logs and corrected credential configuration.

### Resource Constraints

The local development machine reached significant CPU, memory and disk I/O limits while running the complete platform. The cluster was therefore optimized to run as a single-node Kind environment with a reduced Argo CD footprint.

---

# Planned / Not Deployed

The following were considered but are **not presented as completed features**:

| Component               | Status                 |
| ----------------------- | ---------------------- |
| Backstage               | Designed, not deployed |
| HashiCorp Vault         | Designed, not deployed |
| Reliability Engineering | Not attempted          |
| Progressive Delivery    | Not attempted          |
| Disaster Recovery       | Not attempted          |
| Chaos Engineering       | Not attempted          |

The project intentionally stops at a realistic boundary rather than attempting to add technologies simply to increase the feature count.
During development, the local machine reached a genuine resource ceiling multiple times.

---

# Technology Stack

| Area                 | Technologies                        |
| -------------------- | ----------------------------------- |
| Infrastructure       | Terraform, Kind, Kubernetes         |
| CI/CD                | GitHub Actions                      |
| Containers           | Docker, GHCR                        |
| GitOps               | Argo CD                             |
| Kubernetes Packaging | Helm                                |
| Application          | Node.js, Express.js                 |
| Database             | PostgreSQL                          |
| Security             | Gitleaks, npm audit, Trivy, Kyverno |
| Networking           | Ingress-NGINX, NetworkPolicy        |
| Observability        | Prometheus, Grafana, node-exporter  |
| Platform Engineering | Golden Path, Service Scaffolding    |

---
