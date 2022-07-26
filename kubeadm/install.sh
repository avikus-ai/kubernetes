lsmod | grep br_netfilter
sudo modprobe br_netfilter

#
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

sudo apt-get update
sudo apt-get install -y docker.io

# systemctl on
sudo systemctl enable docker
sudo usermod -aG docker $USER

sudo mkdir /etc/docker

cat <<EOF | sudo tee /etc/docker/daemon.json
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
},
"storage-driver": "overlay2"
}
EOF
 
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# downloading
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# installing
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

cat << EOF >> ~/.bashrc
alias k=kubectl
EOF
source ~/.bashrc

sudo swapoff -a                 # Disable all devices marked as swap in /etc/fstab
sudo sed -e '/swap/ s/^#*/#/' -i /etc/fstab   # Comment the correct mounting point
sudo systemctl mask swap.target               # Completely disabled

