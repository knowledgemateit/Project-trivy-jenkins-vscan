# Quick Start - Amazon Linux

This installs everything automatically:
- ✅ Java 8
- ✅ Maven
- ✅ Docker
- ✅ Trivy
- ✅ Jenkins

---

## Manual Setup 

### System Update
```bash
sudo dnf update -y
```

### Install Each Component
```bash
# Java 8
sudo dnf update -y
sudo dnf install java-21-amazon-corretto -y

# Maven
sudo yum install -y maven

# Docker
sudo yum install -y docker
sudo systemctl start docker && sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Trivy
cat << EOF | sudo tee /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://aquasecurity.github.io/trivy-repo/rpm/public.key
EOF

sudo yum -y update
sudo yum -y install trivy


# Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install -y jenkins
sudo systemctl start jenkins && sudo systemctl enable jenkins
sudo usermod -a -G docker jenkins
sudo systemctl restart jenkins

# Fix temp Issue Jenkins
sudo mkdir -p /etc/systemd/system/jenkins.service.d
sudo bash -c 'cat > /etc/systemd/system/jenkins.service.d/override.conf <<EOF
[Service]
Environment="JAVA_OPTS=-Djava.io.tmpdir=/var/lib/jenkins/tmp"
EOF'

sudo mkdir -p /var/lib/jenkins/tmp
sudo chown jenkins:jenkins /var/lib/jenkins/tmp
sudo systemctl daemon-reload
sudo systemctl restart jenkins
```

---

## Access Jenkins

1. **Get Jenkins URL:**
   ```bash
   echo "http://$(hostname -I | awk '{print $1}'):8080"
   ```

2. **Get Admin Password:**
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

3. **Open in Browser:** Copy URL from step 1

---

## Create Jenkins Pipeline Job

1. **New Item** → Enter job name
2. Select **Pipeline**
3. Under Pipeline:
   - Select **Pipeline script from SCM**
   - Choose **Git**
   - Enter repo URL: `https://github.com/yourusername/trivy-jenkins-vscan`
   - Branch: `main`
4. **Save**
5. Click **Build Now**

---

## Verify Everything Works

```bash
# Check all components
java -version
mvn -version
docker --version
trivy --version
sudo systemctl status jenkins

# Test project build
git clone <your-repo>
cd trivy-jenkins-vscan
./run.sh
```

---

## Troubleshooting Quick Fixes

| Issue | Fix |
|-------|-----|
| Docker permission denied | `sudo usermod -a -G docker $USER` then logout/login |
| Jenkins can't run Docker | `sudo usermod -a -G docker jenkins && sudo systemctl restart jenkins` |
| Port 8080 in use | Change in `/etc/default/jenkins` to different port |
| Trivy not found | Use full path: `/usr/local/bin/trivy` |

---

## Project Structure Overview

```
trivy-jenkins-vscan/
├── Jenkinsfile              # Pipeline definition
├── run.sh                   # Build script
├── pom.xml                  # Maven config
├── src/
│   └── main/
│       ├── java/            # Java source code
│       ├── docker/          # Dockerfile
│       └── webapp/          # Web config
└── SETUP_AMAZON_LINUX.md    # Detailed setup guide
```

---

## What Happens When You Build

1. **Build Stage** → Compiles Java + Creates Docker image
2. **Scan Stage** → Trivy scans image for vulnerabilities
3. **Report Stage** → Saves results to `trivy-report.json`
4. **Email on Failure** → Notifies if vulnerabilities found

---

## Next: Configure Email Notifications

Edit `Jenkinsfile` and update email recipient:

```groovy
to: 'your-email@example.com'
```

Then in Jenkins:
1. **Manage Jenkins** → **Configure System**
2. Find **Email Notification**
3. Enter SMTP server (e.g., `smtp.gmail.com`)
4. Save

---

## Need Help?

See `SETUP_AMAZON_LINUX.md` for detailed step-by-step guide.
