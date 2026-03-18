#!/bin/bash
set -e

echo "=== Installing DevOps tools for WSL/Ubuntu ==="

# k9s
echo "[1/4] Installing k9s..."
K9S_VER=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep -oP '"tag_name": "\K[^"]+')
curl -fsSL "https://github.com/derailed/k9s/releases/download/${K9S_VER}/k9s_Linux_amd64.tar.gz" -o /tmp/k9s.tar.gz
sudo tar -xzf /tmp/k9s.tar.gz -C /usr/local/bin k9s
rm /tmp/k9s.tar.gz
echo "  k9s ${K9S_VER} installed"

# kubectx + kubens
echo "[2/4] Installing kubectx & kubens..."
KUBECTX_VER=$(curl -s https://api.github.com/repos/ahmetb/kubectx/releases/latest | grep -oP '"tag_name": "\K[^"]+')
curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VER}/kubectx_${KUBECTX_VER}_linux_x86_64.tar.gz" -o /tmp/kubectx.tar.gz
curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VER}/kubens_${KUBECTX_VER}_linux_x86_64.tar.gz" -o /tmp/kubens.tar.gz
sudo tar -xzf /tmp/kubectx.tar.gz -C /usr/local/bin kubectx
sudo tar -xzf /tmp/kubens.tar.gz -C /usr/local/bin kubens
rm /tmp/kubectx.tar.gz /tmp/kubens.tar.gz
echo "  kubectx/kubens ${KUBECTX_VER} installed"

# yq
echo "[3/4] Installing yq..."
YQ_VER=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep -oP '"tag_name": "\K[^"]+')
curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VER}/yq_linux_amd64" -o /tmp/yq
sudo install /tmp/yq /usr/local/bin/yq
rm /tmp/yq
echo "  yq ${YQ_VER} installed"

# kubelogin (Azure AD auth for AKS)
echo "[4/4] Installing kubelogin..."
KUBELOGIN_VER=$(curl -s https://api.github.com/repos/Azure/kubelogin/releases/latest | grep -oP '"tag_name": "\K[^"]+')
curl -fsSL "https://github.com/Azure/kubelogin/releases/download/${KUBELOGIN_VER}/kubelogin-linux-amd64.zip" -o /tmp/kubelogin.zip
sudo unzip -o -q /tmp/kubelogin.zip -d /tmp/kubelogin
sudo install /tmp/kubelogin/bin/linux_amd64/kubelogin /usr/local/bin/kubelogin
rm -rf /tmp/kubelogin /tmp/kubelogin.zip
echo "  kubelogin ${KUBELOGIN_VER} installed"

echo ""
echo "=== All tools installed ==="
echo "Verifying..."
echo "  terraform  : $(terraform version -json 2>/dev/null | grep -oP '"terraform_version": "\K[^"]+' || terraform --version | head -1)"
echo "  kubectl    : $(kubectl version --client -o json 2>/dev/null | grep -oP '"gitVersion": "\K[^"]+' || echo 'installed')"
echo "  helm       : $(helm version --short 2>/dev/null)"
echo "  az         : $(az version 2>/dev/null | grep -oP '"azure-cli": "\K[^"]+' || echo 'installed')"
echo "  k9s        : $(k9s version --short 2>/dev/null || k9s version 2>/dev/null | head -1)"
echo "  kubectx    : $(kubectx --version 2>/dev/null || echo 'installed')"
echo "  kubens     : $(kubens --version 2>/dev/null || echo 'installed')"
echo "  kubelogin  : $(kubelogin --version 2>/dev/null | head -1)"
echo "  yq         : $(yq --version 2>/dev/null)"
echo "  jq         : $(jq --version 2>/dev/null)"
echo ""
echo "Done!"
