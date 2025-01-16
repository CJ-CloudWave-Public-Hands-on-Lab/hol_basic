#!/bin/bash
# Set environment variables
AWS_REGION="ap-northeast-2"
AWS_ACCOUNT_ID="*************"
USER_EMAIL="cj-cloud-wave@workshops.aws"
USER_NAME="Workshop Public Cloud"
PASSWORD="CJ_CloudWave2025!!"
HOMEFOLDER="/Workshop"

# Update package lists
sudo apt-get update

# Install curl and unzip (required for several installations)
DEBIAN_FRONTEND=noninteractive apt-get install -y curl unzip

# Install AWS CLI
curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip -o /tmp/aws-cli.zip
unzip -q -d /tmp /tmp/aws-cli.zip
sudo /tmp/aws/install
rm -rf /tmp/aws
aws --version

# Install SAM CLI
curl -fsSL https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip -o /tmp/aws-sam-cli.zip
unzip -q -d /tmp/sam-installation /tmp/aws-sam-cli.zip
sudo /tmp/sam-installation/install
rm -rf /tmp/sam-installation
sam --version

# Install Docker
# - curl -fsSL https://get.docker.com | sh
DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >> /etc/apt/sources.list.d/docker.list
# sudo rm /etc/apt/sources.list.d/docker.list
# sudo rm /usr/share/keyrings/docker-archive-keyring.gpg
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker ubuntu
docker --version

# Install Git
echo \n | add-apt-repository ppa:git-core/ppa
DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
DEBIAN_FRONTEND=noninteractive apt-get install -y git
sudo -u ubuntu git config --global user.email "${USER_EMAIL}"
sudo -u ubuntu git config --global user.name "${USER_NAME}"
sudo -u ubuntu git config --global init.defaultBranch "main"
git --version

# Install Node.js
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource-keyring.gpg
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash - 
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

# Install Python
apt install python3-pip -y
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1
echo 1 | sudo update-alternatives --config python

# Update Profile
echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.UTF-8 >> /etc/environment
echo 'PATH=$PATH:/home/ubuntu/.local/bin' >> /home/ubuntu/.bashrc
echo 'export PATH' >> /home/ubuntu/.bashrc
echo "export AWS_REGION=${AWS_REGION}" >> /home/ubuntu/.bashrc
echo "export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}" >> /home/ubuntu/.bashrc
echo 'export NEXT_TELEMETRY_DISABLED=1' >> /home/ubuntu/.bashrc
touch /home/ubuntu/.hushlogin
sudo chown ubuntu:ubuntu /home/ubuntu -R  

# Install VS Code Server
export HOME=/home/ubuntu
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
curl -fsSL https://code-server.dev/install.sh | sh
sudo systemctl enable --now code-server@ubuntu

# sudo tee /etc/nginx/sites-available/code-server <<EOF
# server {
#     listen 80;
#     listen [::]:80;
#     server_name 0.0.0.0/0;
#     location / {
#     proxy_pass http://localhost:8080/;
#     proxy_set_header Host \$host;
#     proxy_set_header Upgrade \$http_upgrade;
#     proxy_set_header Connection upgrade;
#     proxy_set_header Accept-Encoding gzip;
#     }
#     location /dev {
#     proxy_pass http://localhost:8081/dev;
#     proxy_set_header Host \$host;
#     proxy_set_header Upgrade \$http_upgrade;
#     proxy_set_header Connection upgrade;
#     proxy_set_header Accept-Encoding gzip;
#     }
# }
# EOF

sudo npm install npm -y
sudo tee /home/ubuntu/.config/code-server/config.yaml <<EOF
bind-addr: 0.0.0.0:8080
cert: false
auth: password
hashed-password: "$(echo -n "${PASSWORD}" | sudo npx argon2-cli -e)"
EOF

sudo -u ubuntu --login mkdir -p /home/ubuntu/.local/share/code-server/User/
sudo -u ubuntu --login touch /home/ubuntu/.local/share/code-server/User/settings.json

sudo mkdir "${HOMEFOLDER}"
sudo tee /home/ubuntu/.local/share/code-server/User/settings.json <<EOF
{
    "extensions.autoUpdate": false,
    "extensions.autoCheckUpdates": false,
    "terminal.integrated.cwd": "${HOMEFOLDER}",
    "telemetry.telemetryLevel": "off",
    "security.workspace.trust.startupPrompt": "never",
    "security.workspace.trust.enabled": false,
    "security.workspace.trust.banner": "never",
    "security.workspace.trust.emptyWindow": false,
    "editor.formatOnSave": true,
    "editor.indentSize": "tabSize",
    "editor.tabSize": 2,
    "python.testing.pytestEnabled": true,
    "auto-run-command.rules": [
        {
            "command": "workbench.action.terminal.new"
        }
    ],
    "workbench.colorTheme": "Visual Studio Dark",
    "json.schemas": [],
    "python.analysis.extraPaths": [
        "/Workshop/streamlit/src"
    ]
}
EOF

sudo systemctl restart code-server@ubuntu
# sudo ln -s ../sites-available/code-server /etc/nginx/sites-enabled/code-server
# sudo systemctl restart nginx
sudo -u ubuntu --login code-server --install-extension AmazonWebServices.aws-toolkit-vscode --force
sudo -u ubuntu --login code-server --install-extension AmazonWebServices.amazon-q-vscode --force
sudo -u ubuntu --login code-server --install-extension synedra.auto-run-command --force
sudo -u ubuntu --login code-server --install-extension vscjava.vscode-java-pack --force
sudo -u ubuntu --login code-server --install-extension ms-vscode.live-server --force
sudo -u ubuntu --login code-server --install-extension njpwerner.autodocstring --force
sudo -u ubuntu --login code-server --install-extension ms-toolsai.jupyter --force
sudo -u ubuntu --login code-server --install-extension ms-python.python --force
sudo -u ubuntu --login code-server --install-extension donjayamanne.python-extension-pack --force
sudo -u ubuntu --login code-server --install-extension tht13.python --force
sudo -u ubuntu --login code-server --install-extension Equinusocio.vsc-material-theme --force
sudo chown ubuntu:ubuntu /home/ubuntu -R

# Install CDK
npm install -g aws-cdk -y
cdk --version

# Install Go
echo \n | sudo add-apt-repository ppa:longsleep/golang-backports
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y golang-go
go version

# Install Rust
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y rustc cargo
rustc --version

# Install Dotnet
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y dotnet-sdk-8.0
sudo dotnet tool install -g Microsoft.Web.LibraryManager.Cli
export PATH="$PATH:/home/ubuntu/.dotnet/tools"
sudo chown ubuntu:ubuntu /home/ubuntu -R
dotnet --list-sdks

# Install Vite
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y vite
npm install -g create-vite

# Install Java
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y wget
wget -O - https://apt.corretto.aws/corretto.key | sudo gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | sudo tee /etc/apt/sources.list.d/corretto.list
echo \n | sudo add-apt-repository 'deb https://apt.corretto.aws stable main' -y
DEBIAN_FRONTEND=noninteractive sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y java-21-amazon-corretto-jdk java-17-amazon-corretto-jdk java-1.8.0-amazon-corretto-jdk maven
echo 'export JAVA_1_8_HOME=$(dirname $(dirname $(readlink -f $(which java))))' >> /home/ubuntu/.bashrc
echo 'export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))' >> /home/ubuntu/.bashrc
echo 'export PATH=$PATH:$JAVA_HOME/bin:/usr/share/maven/bin' >> /home/ubuntu/.bashrc
java -version
mvn --version
update-alternatives --list java
