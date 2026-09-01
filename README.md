# Java Docker Trivy Security Scan

A simple Java web application with automated vulnerability scanning via Trivy in Jenkins CI/CD.

## Quick Start

### For Amazon Linux 2 Server

See **[QUICK_START.md](QUICK_START.md)** for instant setup, or **[SETUP_AMAZON_LINUX.md](SETUP_AMAZON_LINUX.md)** for detailed steps.

**One-command setup:**
```bash
chmod +x setup-amazon-linux.sh
sudo ./setup-amazon-linux.sh
```

### Local Development

**Requirements:**
- Java 8+
- Maven 3.6+
- Docker
- Trivy

**Build:**
```bash
./run.sh
```

## How It Works

The `Jenkinsfile` pipeline has 3 stages:

1. **Build** → Compiles Java app and creates Docker image
2. **Scan** → Runs Trivy vulnerability scan on the image  
3. **Report** → Archives results and emails on failure

Output: `trivy-report.json` (available in Jenkins artifacts)

## Project Files

| File | Purpose |
|------|---------|
| `Jenkinsfile` | Jenkins CI/CD pipeline definition |
| `run.sh` | Local build script |
| `pom.xml` | Maven project configuration |
| `src/main/docker/Dockerfile` | Docker image definition |
| `src/main/java/` | Java servlet source code |
| `SETUP_AMAZON_LINUX.md` | Detailed Amazon Linux setup guide |
| `QUICK_START.md` | Quick reference for setup |
| `setup-amazon-linux.sh` | Automated installation script |

## Project Structure

```
.
├── Jenkinsfile
├── run.sh
├── pom.xml
├── README.md
├── QUICK_START.md
├── SETUP_AMAZON_LINUX.md
├── setup-amazon-linux.sh
└── src/main/
    ├── java/com/sap/docker/
    ├── webapp/WEB-INF/
    └── docker/Dockerfile
```
