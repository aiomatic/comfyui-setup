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

# === SageAttention ===
cd ~/ComfyUI/custom_nodes
rm -rf SageAttention
git clone https://github.com/thu-ml/SageAttention.git
cd SageAttention
export EXT_PARALLEL=4 NVCC_APPEND_FLAGS="--threads 8" MAX_JOBS=32
python setup.py install --user

# === Custom Nodes ===
cd ~/ComfyUI/custom_nodes

rm -rf ComfyUI-Manager
git clone https://github.com/ltdrdata/ComfyUI-Manager.git ComfyUI-Manager

rm -rf ComfyUI_LayerStyle
git clone https://github.com/chflame163/ComfyUI_LayerStyle.git ComfyUI_LayerStyle

rm -rf ComfyUI_essentials
git clone https://github.com/cubiq/ComfyUI_essentials.git ComfyUI_essentials

rm -rf cg-use-everywhere
git clone https://github.com/cg-cnu/comfyui-use-everywhere.git cg-use-everywhere

rm -rf comfyui-custom-scripts
git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git comfyui-custom-scripts

rm -rf comfyui-easy-use
git clone https://github.com/yolain/ComfyUI-Easy-Use.git comfyui-easy-use

rm -rf comfyui-get-meta
git clone https://github.com/city96/ComfyUI-Get-Meta.git comfyui-get-meta

rm -rf comfyui-kjnodes
git clone https://github.com/kijai/ComfyUI-KJNodes.git comfyui-kjnodes

rm -rf comfyui-logicutils
git clone https://github.com/westontron/ComfyUI-LogicUtils.git comfyui-logicutils

rm -rf comfyui-videohelpersuite
git clone https://github.com/Fannovel16/comfyui-videohelpersuite.git comfyui-videohelpersuite

rm -rf comfyui_creaprompt
git clone https://github.com/melMass/comfyui-creaprompt.git comfyui_creaprompt

rm -rf wanblockswap
git clone https://github.com/PKzebra/ComfyUI-WanBlockSwap.git wanblockswap

rm -f websocket_image_save.py
wget -O websocket_image_save.py https://raw.githubusercontent.com/comfyanonymous/ComfyUI_examples/main/websocket_image_save.py

rm -rf gguf
git clone https://github.com/city96/ComfyUI-GGUF.git gguf

# Anything Everywhere
rm -rf comfyui-anytoany
git clone https://github.com/cubiq/ComfyUI_AnyToAny.git comfyui-anytoany

# LayerUtility (PurgeVRAM etc.)
rm -rf ComfyUI_LayerUtility
git clone https://github.com/layerdiffusion/ComfyUI_LayerUtility.git ComfyUI_LayerUtility

# Cleanup
rm -rf comfyui_layerstyle __pycache__ example_node.py.example

# === Extra models ===
# SCAX Upscale model
curl -L -o ~/ComfyUI/models/upscale/4x-UltraSharp.pth \
https://huggingface.co/Sanster/4x-UltraSharp/resolve/main/4x-UltraSharp.pth

# Nunchaku
cd ~/ComfyUI/custom_nodes
rm -rf Nunchaku
git clone https://github.com/Kosinkadink/ComfyUI-Nunchaku.git Nunchaku || true

# WAN 2.2 Dual-UNet Workflow Template
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

# === Print installed custom nodes ===
echo "Installed custom nodes:"
ls -1 ~/ComfyUI/custom_nodes

# === Print server access URL ===
IP=$(hostname -I | awk '{print $1}')
echo "✅ ComfyUI is running at: http://$IP:18188"

# === Start ComfyUI ===
cd ~/ComfyUI
~/ComfyUI/venv/bin/python main.py --listen 0.0.0.0 --port 18188
EOSU
