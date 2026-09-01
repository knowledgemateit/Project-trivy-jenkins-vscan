# Amazon Linux Setup Guide

Complete installation steps to run this Java Docker Trivy Jenkins project on Amazon Linux.

## Prerequisites

- Amazon Linux 2 instance (t2.medium or larger recommended)
- Root or sudo access
- ~20 GB disk space

## Step 1: Update System Packages

```bash
sudo yum update -y
sudo yum upgrade -y
```

## Step 2: Install Java (OpenJDK 8)

```bash
sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel

# Verify installation
java -version
javac -version
```

## Step 3: Install Maven

```bash
sudo yum install -y maven

# Verify installation
mvn -version
```

## Step 4: Install Docker

```bash
sudo yum install -y docker

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group (avoid sudo for docker commands)
sudo usermod -a -G docker ec2-user

# Apply new group
newgrp docker

# Verify Docker
docker --version
```

## Step 5: Install Trivy

```bash
# Add Aqua Security repository
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

# For Amazon Linux 2 (RPM-based), use binary installation instead:
wget https://github.com/aquasecurity/trivy/releases/download/v0.50.1/trivy_0.50.1_Linux-64bit.tar.gz
tar zxvf trivy_0.50.1_Linux-64bit.tar.gz
sudo mv trivy /usr/local/bin/

# Verify installation
trivy --version
```

## Step 6: Install Jenkins

```bash
# Add Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install Java (if not already done)
sudo yum upgrade -y

# Install Jenkins
sudo yum install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Verify Jenkins is running
sudo systemctl status jenkins
```

## Step 7: Configure Jenkins

```bash
# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

**In your browser:**
1. Go to `http://<your-ec2-public-ip>:8080`
2. Paste the admin password from above
3. Select "Install suggested plugins"
4. Create first admin user
5. Save and continue

## Step 8: Install Jenkins Plugins

In Jenkins Dashboard:
1. Go to **Manage Jenkins** → **Manage Plugins**
2. Search and install:
   - Email Extension Plugin
   - Pipeline
   - Git

## Step 9: Clone Project Repository

```bash
# Create workspace directory
mkdir -p /home/ec2-user/jenkins-workspace
cd /home/ec2-user/jenkins-workspace

# Clone your project
git clone <your-repo-url>
cd trivy-jenkins-vscan
```

## Step 10: Create Jenkins Pipeline Job

In Jenkins Dashboard:
1. Click **New Item**
2. Enter job name: `trivy-docker-scan`
3. Select **Pipeline**
4. In **Pipeline** section:
   - Select **Pipeline script from SCM**
   - Choose **Git**
   - Enter repository URL
   - Set branch to `main`
5. Save

Or create directly from Jenkinsfile in your repo with **Multibranch Pipeline**.

## Step 11: Verify Setup

```bash
# Test Java
java -version

# Test Maven
mvn -version

# Test Docker
docker --version
docker ps

# Test Trivy
trivy --version

# Test project build (in project directory)
./run.sh
```

## Troubleshooting

### Docker permission denied errors:
```bash
sudo usermod -a -G docker ec2-user
# Logout and login again
```

### Jenkins can't run docker:
```bash
sudo usermod -a -G docker jenkins
sudo systemctl restart jenkins
```

### Trivy command not found:
```bash
which trivy
# If not found, check PATH or use full path
/usr/local/bin/trivy --version
```

### Port 8080 already in use:
```bash
# Change Jenkins port in /etc/default/jenkins
sudo nano /etc/default/jenkins
# Modify: JENKINS_PORT=8081
sudo systemctl restart jenkins
```

## Security Configuration (Optional but Recommended)

1. **Enable Jenkins authentication:**
   - Manage Jenkins → Configure Global Security
   - Enable "Jenkins own user database"
   - Disable "Allow users to sign up"

2. **Install SSL/HTTPS:**
   ```bash
   # Use AWS Certificate Manager + ALB in front of Jenkins
   ```

3. **Restrict Jenkins network:**
   - Use Security Group to allow only required ports
   - Close port 8080 to public, use VPN/ALB

## Running the Pipeline

1. Go to Jenkins job `trivy-docker-scan`
2. Click **Build Now**
3. Monitor build in **Console Output**
4. After completion:
   - Check **Artifacts** for `trivy-report.json`
   - Review vulnerability scan results

## Next Steps

- Configure email notifications (in Jenkinsfile)
- Set up webhook for automatic builds on git push
- Add more scan policies/thresholds in Trivy
- Integrate with container registry (Docker Hub, ECR, etc.)
