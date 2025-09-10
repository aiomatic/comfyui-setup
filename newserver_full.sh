#!/bin/bash
set -euo pipefail

# === New Server Installation Script ===
echo "[INFO] Starting new server installation..."

# --- Create comfy user if missing ---
USERNAME="comfy"
HOME_DIR="/home/$USERNAME"

if ! id "$USERNAME" &>/dev/null; then
    echo "[INFO] Creating user: $USERNAME"
    adduser --disabled-password --gecos "" "$USERNAME" </dev/null
    usermod -aG sudo "$USERNAME"
fi

# --- Install dependencies ---
echo "[INFO] Installing dependencies..."
apt-get update && apt-get upgrade -y
apt-get install -y git wget curl unzip

# --- Switch to comfy user ---
su - "$USERNAME" -c bash <<'EOSU'
set -euo pipefail

# === Model folders ===
mkdir -p ~/ComfyUI/models/{checkpoints,vae,loras,gguf,text_encoders,diffusion_models}

# --- Download Models ---
echo "[INFO] Downloading models, text encoders, VAEs, and checkpoints..."

# Text Encoder
wget -nc -O ~/ComfyUI/models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors \
  https://huggingface.co/google/umt5-xxl/resolve/main/umt5_xxl_fp8_e4m3fn_scaled.safetensors

# VAEs
wget -nc -O ~/ComfyUI/models/vae/wan_2.1_vae.safetensors \
  https://huggingface.co/city96/wan-vae/resolve/main/wan_2.1_vae.safetensors

wget -nc -O ~/ComfyUI/models/vae/wan2.2_vae.safetensors \
  https://huggingface.co/city96/wan-vae/resolve/main/wan2.2_vae.safetensors

# Diffusion Models
wget -nc -O ~/ComfyUI/models/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors \
  https://huggingface.co/QuantStack/Wan2.2-I2V-A14B/resolve/main/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors

wget -nc -O ~/ComfyUI/models/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors \
  https://huggingface.co/QuantStack/Wan2.2-I2V-A14B/resolve/main/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors

wget -nc -O ~/ComfyUI/models/diffusion_models/wan2.2_ti2v_5B_fp16.safetensors \
  https://huggingface.co/QuantStack/Wan2.2-TI2V-5B/resolve/main/wan2.2_ti2v_5B_fp16.safetensors

# Rapid AIO checkpoint
wget -nc -O ~/ComfyUI/models/checkpoints/wan2.2-i2v-rapid-aio-v10.safetensors \
  https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/v10/wan2.2-i2v-rapid-aio-v10.safetensors

# === Install ComfyUI ===
echo "[INFO] Installing ComfyUI Easy Installer..."
if [ ! -d ~/ComfyUI-Easy-Install ]; then
  git clone https://github.com/VenimK/ComfyUI-Easy-Install.git ~/ComfyUI-Easy-Install
fi
cd ~/ComfyUI-Easy-Install
chmod +x ComfyUI-Easy-Install.sh
./ComfyUI-Easy-Install.sh || true   # skip "press any key" error

# === Sage Attention ===
echo "[INFO] Installing Sage Attention..."
mkdir -p ~/ComfyUI/custom_nodes
cd ~/ComfyUI/custom_nodes
if [ ! -d "PatchSageAttentionKJ" ]; then
  git clone https://github.com/kijai/ComfyUI-PatchSageAttention.git PatchSageAttentionKJ
fi

# === Custom Nodes ===
declare -A NODES=(
  [ComfyUI-Manager]="https://github.com/ltdrdata/ComfyUI-Manager.git"
  [ComfyUI_LayerStyle]="https://github.com/chflame163/ComfyUI_LayerStyle.git"
  [ComfyUI-essentials]="https://github.com/city96/ComfyUI-essentials.git"
  [ComfyUI-AnyWhere]="https://github.com/shiimizu/ComfyUI-AnyWhere.git"
  [comfyui-layerutility]="https://github.com/mrbadass/comfyui-layerutility.git"
  [GetNode]="https://github.com/Suzie1/GetNode.git"
  [SetNode]="https://github.com/Suzie1/SetNode.git"
  [LoaderGGUF]="https://github.com/city96/ComfyUI-LoaderGGUF.git"
  [wanBlockSwap]="https://github.com/city96/ComfyUI-wanBlockSwap.git"
  [rgthree-comfyui-tools]="https://github.com/rgthree/rgthree-comfyui-tools.git"
  [pysssss-comfyui-extras]="https://github.com/pysssss/ComfyUI-Custom-Scripts.git"
  [VideoHelperSuite]="https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git"
  [ComfyUI-Custom-Nodes]="https://github.com/Kosinkadink/ComfyUI-Custom-Nodes.git"
)

for NODE in "${!NODES[@]}"; do
  if [ ! -d "$HOME/ComfyUI/custom_nodes/$NODE" ]; then
    echo "[INFO] Installing node: $NODE"
    git clone "${NODES[$NODE]}" "$HOME/ComfyUI/custom_nodes/$NODE" || true
  else
    echo "[OK] Node already present: $NODE"
  fi
done

# === Final Verification ===
echo "[INFO] Verifying installation..."

MISSING=0

# Check models
for FILE in \
  "$HOME/ComfyUI/models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
  "$HOME/ComfyUI/models/vae/wan_2.1_vae.safetensors" \
  "$HOME/ComfyUI/models/vae/wan2.2_vae.safetensors" \
  "$HOME/ComfyUI/models/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors" \
  "$HOME/ComfyUI/models/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors" \
  "$HOME/ComfyUI/models/diffusion_models/wan2.2_ti2v_5B_fp16.safetensors" \
  "$HOME/ComfyUI/models/checkpoints/wan2.2-i2v-rapid-aio-v10.safetensors"; do
  if [ ! -f "$FILE" ]; then
    echo "[MISSING] $FILE"
    MISSING=1
  else
    echo "[OK] Found $FILE"
  fi
done

# Check nodes
for NODE in "${!NODES[@]}"; do
  if [ ! -d "$HOME/ComfyUI/custom_nodes/$NODE" ]; then
    echo "[MISSING NODE] $NODE"
    MISSING=1
  else
    echo "[OK] Node installed: $NODE"
  fi
done

if [ $MISSING -eq 0 ]; then
  echo "[SUCCESS] All components installed successfully!"
else
  echo "[WARNING] Some components are missing. Please re-check logs."
fi

EOSU

echo "[INFO] Installation complete! Run ComfyUI from ~/ComfyUI-Easy-Install or ~/ComfyUI."
