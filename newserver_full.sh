#!/bin/bash
set -euo pipefail

# === New Server Installation Script ===
echo "[INFO] Starting new server installation..."

# --- Create comfy user if missing ---
USERNAME="comfy"
HOME_DIR="/home/$USERNAME"

if ! id "$USERNAME" &>/dev/null; then
    echo "[INFO] Creating user: $USERNAME"
    adduser --disabled-password --gecos "" "$USERNAME"
    usermod -aG sudo "$USERNAME"
fi

# --- Install dependencies ---
echo "[INFO] Installing dependencies..."
apt-get update
apt-get install -y git wget curl unzip

# --- Switch to comfy user ---
su - "$USERNAME" -c bash <<'EOSU'
set -euo pipefail

# === ComfyUI Easy Installer ===
if [ ! -d ~/ComfyUI-Easy-Install ]; then
  git clone https://github.com/VenimK/ComfyUI-Easy-Install.git ~/ComfyUI-Easy-Install
fi
cd ~/ComfyUI-Easy-Install
chmod +x ComfyUI-Easy-Install.sh
./ComfyUI-Easy-Install.sh

# === Custom Nodes ===
cd ~/ComfyUI/custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
git clone https://github.com/chflame163/ComfyUI_LayerStyle.git
git clone https://github.com/city96/ComfyUI-essentials.git
git clone https://github.com/shiimizu/ComfyUI-AnyWhere.git
git clone https://github.com/mrbadass/comfyui-layerutility.git
git clone https://github.com/Suzie1/GetNode.git
git clone https://github.com/Suzie1/SetNode.git
git clone https://github.com/city96/ComfyUI-LoaderGGUF.git

# === Model folders ===
mkdir -p ~/ComfyUI/models/{checkpoints,vae,loras,gguf,text_encoders}

# --- Download WAN2.2 models ---
echo "[INFO] Downloading WAN2.2 models..."
wget -O ~/ComfyUI/models/gguf/Wan2.2-LowNoise-Q4_K_S.gguf \
  https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf

wget -O ~/ComfyUI/models/gguf/Wan2.2-HighNoise-Q4_K_S.gguf \
  https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf

wget -O ~/ComfyUI/models/vae/wan_2.1_vae.safetensors \
  https://huggingface.co/city96/wan-vae/resolve/main/wan_2.1_vae.safetensors

# --- Rapid AIO model ---
wget -O ~/ComfyUI/models/checkpoints/wan2.2-i2v-rapid-aio-v10.safetensors \
  https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/v10/wan2.2-i2v-rapid-aio-v10.safetensors

EOSU

echo "[INFO] Installation complete! Run ComfyUI from ~/ComfyUI-Easy-Install or ~/ComfyUI."
