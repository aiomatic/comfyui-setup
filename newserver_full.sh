#!/bin/bash
set -euo pipefail

USERNAME="comfy"
HOME_DIR="/home/$USERNAME"

# --- Create comfy user if missing ---
if ! id "$USERNAME" &>/dev/null; then
    adduser --disabled-password --gecos "" "$USERNAME"
    usermod -aG sudo "$USERNAME"
fi

# --- Run everything as comfy ---
su - "$USERNAME" -c bash <<'EOSU'
set -euo pipefail

# === ComfyUI Easy Installer ===
if [ ! -d ~/ComfyUI-Easy-Install ]; then
  git clone https://github.com/VenimK/ComfyUI-Easy-Install.git ~/ComfyUI-Easy-Install
fi
cd ~/ComfyUI-Easy-Install
chmod +x ComfyUI-Easy-Install.sh
./ComfyUI-Easy-Install.sh

# === Model folders ===
mkdir -p ~/ComfyUI/models/{checkpoints,vae,loras,gguf,text_encoders,upscale}

# --- Core WAN models ---
curl -L -o ~/ComfyUI/models/gguf/Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf \
https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf
curl -L -o ~/ComfyUI/models/gguf/Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf \
https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf
curl -L -o ~/ComfyUI/models/vae/wan_2.1_vae.safetensors \
https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors
curl -L -o ~/ComfyUI/models/loras/Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors \
https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/loras/Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors
curl -L -o ~/ComfyUI/models/loras/Wan2.1_I2V_14B_FusionX_LoRA.safetensors \
https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/loras/Wan2.1_I2V_14B_FusionX_LoRA.safetensors
curl -L -o ~/ComfyUI/models/checkpoints/wan2.1_t2v.safetensors \
https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/checkpoints/wan2.1_t2v.safetensors
curl -L -o ~/ComfyUI/models/checkpoints/wan2.2_ti2v_5B_fp16.safetensors \
https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/checkpoints/wan2.2_ti2v_5B_fp16.safetensors

# === Extra installs ===
# Sage Attention
cd ~/ComfyUI/custom_nodes
rm -rf SageAttention
git clone https://github.com/thu-ml/SageAttention.git
cd SageAttention
export EXT_PARALLEL=4 NVCC_APPEND_FLAGS="--threads 8" MAX_JOBS=32
python setup.py install --user

# WFusion X LoRA (same as FusionX_LoRA)
# Already included above (Wan2.1_I2V_14B_FusionX_LoRA.safetensors)

# SCAX Upscale model
curl -L -o ~/ComfyUI/models/upscale/4x-UltraSharp.pth \
https://huggingface.co/Sanster/4x-UltraSharp/resolve/main/4x-UltraSharp.pth

# Nunchaku installer
cd ~/ComfyUI/custom_nodes
rm -rf Nunchaku
git clone https://github.com/Kosinkadink/ComfyUI-Nunchaku.git Nunchaku || true

# === WAN 2.2 Dual-UNet Workflow Template ===
mkdir -p ~/ComfyUI/workflows
cat > ~/ComfyUI/workflows/wan2.2_dual_unet.json <<'EOW'
{
  "name": "WAN 2.2 Dual UNet Workflow",
  "description": "Template for WAN 2.2 with LowNoise + HighNoise models, two UNet loaders, and two K-samplers.",
  "nodes": [
    {"type": "UNetLoader", "model": "Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf"},
    {"type": "UNetLoader", "model": "Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf"},
    {"type": "KSampler", "name": "LowNoise Sampler"},
    {"type": "KSampler", "name": "HighNoise Sampler"}
  ]
}
EOW

# === Start ComfyUI ===
cd ~/ComfyUI
~/ComfyUI/venv/bin/python main.py --listen 0.0.0.0 --port 18188
EOSU
