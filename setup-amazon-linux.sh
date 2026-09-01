#!/bin/bash
set -e

echo "======================================"
echo "Amazon Linux Setup Script"
echo "Java + Maven + Docker + Trivy + Jenkins"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Update System
echo -e "${YELLOW}[1/8] Updating system packages...${NC}"
sudo yum update -y > /dev/null 2>&1
sudo yum upgrade -y > /dev/null 2>&1
echo -e "${GREEN}✓ System updated${NC}"

# Step 2: Install Java
echo -e "${YELLOW}[2/8] Installing Java OpenJDK 8...${NC}"
sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel > /dev/null 2>&1
java -version
echo -e "${GREEN}✓ Java installed${NC}"

# Step 3: Install Maven
echo -e "${YELLOW}[3/8] Installing Maven...${NC}"
sudo yum install -y maven > /dev/null 2>&1
mvn -version | head -1
echo -e "${GREEN}✓ Maven installed${NC}"

# Step 4: Install Docker
echo -e "${YELLOW}[4/8] Installing Docker...${NC}"
sudo yum install -y docker > /dev/null 2>&1
sudo systemctl start docker
sudo systemctl enable docker > /dev/null 2>&1
docker --version
sudo usermod -a -G docker ec2-user 2>/dev/null || true
echo -e "${GREEN}✓ Docker installed and started${NC}"

# Step 5: Install Trivy
echo -e "${YELLOW}[5/8] Installing Trivy...${NC}"
TRIVY_VERSION="0.50.1"
cd /tmp
wget -q https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
tar zxf trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
sudo mv trivy /usr/local/bin/
rm trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
trivy --version
echo -e "${GREEN}✓ Trivy installed${NC}"

# Step 6: Install Jenkins
echo -e "${YELLOW}[6/8] Installing Jenkins...${NC}"
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo > /dev/null 2>&1
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key > /dev/null 2>&1
sudo yum install -y jenkins > /dev/null 2>&1
sudo systemctl start jenkins
sudo systemctl enable jenkins > /dev/null 2>&1
echo -e "${GREEN}✓ Jenkins installed and started${NC}"

# Step 7: Configure Jenkins user for Docker
echo -e "${YELLOW}[7/8] Configuring Jenkins for Docker access...${NC}"
sudo usermod -a -G docker jenkins 2>/dev/null || true
sudo systemctl restart jenkins > /dev/null 2>&1
sleep 5
echo -e "${GREEN}✓ Jenkins configured${NC}"

# Step 8: Display Jenkins Initial Password
echo -e "${YELLOW}[8/8] Retrieving Jenkins initial admin password...${NC}"
sleep 10  # Wait for Jenkins to fully start
JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "CHECK JENKINS LOGS")
echo -e "${GREEN}✓ Setup complete!${NC}"

echo ""
echo "======================================"
echo "Installation Summary"
echo "======================================"
echo ""
echo "✓ Java 8 installed"
echo "✓ Maven installed"
echo "✓ Docker installed and running"
echo "✓ Trivy installed"
echo "✓ Jenkins installed and running"
echo ""
echo "======================================"
echo "Next Steps:"
echo "======================================"
echo ""
echo "1. Open Jenkins in your browser:"
echo "   http://$(hostname -I | awk '{print $1}'):8080"
echo ""
echo "2. Enter this admin password:"
echo "   $JENKINS_PASSWORD"
echo ""
echo "3. Follow Jenkins setup wizard"
echo "4. Install plugins when prompted"
echo "5. Create first admin user"
echo ""
echo "======================================"
echo "Verify Installation:"
echo "======================================"
echo ""
echo "Test commands:"
echo "  java -version"
echo "  mvn -version"
echo "  docker --version"
echo "  trivy --version"
echo "  sudo systemctl status jenkins"
echo ""
echo "======================================"
