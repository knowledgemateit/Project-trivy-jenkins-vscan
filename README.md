# Java Docker Trivy Security Scan

A simple Java web application with automated vulnerability scanning via Trivy in Jenkins CI/CD.

## Requirements

- Java 8+
- Maven 3.6+
- Docker
- Trivy (installed on Jenkins agent)

## Local Build & Test

```bash
./run.sh
```

This builds the Java application, creates a Docker image, and prepares for scanning.

## Jenkins Pipeline

The `Jenkinsfile` automatically:
1. **Build** — Compiles Java app and creates Docker image
2. **Scan** — Runs Trivy vulnerability scan on the image
3. **Report** — Archives scan results and emails on failure

The scan report is saved as `trivy-report.json` and available as an artifact in Jenkins.
