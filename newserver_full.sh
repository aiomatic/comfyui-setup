#!/bin/bash
set -euo pipefail

echo "[INFO] Starting ComfyUI setup..."

# --- Paths ---
BASE_DIR="/workspace/ComfyUI"
MODELS_DIR="$BASE_DIR/models"
NODES_DIR="$BASE_DIR/custom_nodes"

# --- Hugging Face Token (replace with yours) ---
HF_TOKEN="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"

# --- Ensure folders exist ---
mkdir -p $MODELS_DIR/{checkpoints,vae,loras,gguf,upscale_models,clip_vision}
mkdir -p $NODES_DIR

# =============================
# MODELS
# =============================

echo "[INFO] Downloading WAN 2.2 Rapid AIO..."
curl -L -o $MODELS_DIR/checkpoints/wan2.2-i2v-rapid-aio-v10.safetensors \
https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/v10/wan2.2-i2v-rapid-aio-v10.safetensors

echo "[INFO] Downloading WAN VAEs..."
curl -L -o $MODELS_DIR/vae/wan_2.1_vae.safetensors \
https://huggingface.co/city96/wan-vae/resolve/main/wan_2.1_vae.safetensors?download=true

curl -L -o $MODELS_DIR/vae/wan2.2_vae.safetensors \
https://huggingface.co/city96/wan-vae/resolve/main/wan2.2_vae.safetensors?download=true

echo "[INFO] Downloading LightX2V LoRA..."
curl -L -H "Authorization: Bearer $HF_TOKEN" \
-o $MODELS_DIR/loras/lightx2v_T2V_14B_cfg_step_distill_v2_lora_rank256_bf16.safetensors \
https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_T2V_14B_cfg_step_distill_v2_lora_rank256_bf16.safetensors

echo "[INFO] Downloading UltraSharp upscalers..."
curl -L -o $MODELS_DIR/upscale_models/4x-UltraSharp.pth \
https://huggingface.co/cszn/KAIR/resolve/main/models/upscaling/4x_UltraSharp.pth

curl -L -o $MODELS_DIR/upscale_models/4x-UltraSharpV10.pt \
https://huggingface.co/camenduru/Magic-Me/resolve/main/models/upscale_models/4xUltrasharpV10.pt?download=true

echo "[INFO] Downloading CLIP Vision ViT-H..."
curl -L -o $MODELS_DIR/clip_vision/clip_vision_vit_h.safetensors \
https://huggingface.co/lllyasviel/misc/resolve/main/clip_vision_vit_h.safetensors?download=true

# =============================
# CUSTOM NODES
# =============================

cd $NODES_DIR

echo "[INFO] Installing custom nodes..."
git clone https://github.com/ltdrdata/ComfyUI-Manager.git || true
git clone https://github.com/cubiq/ComfyUI_essentials.git || true
git clone https://github.com/kijai/ComfyUI-KJNodes.git || true
git clone https://github.com/city96/ComfyUI-GGUF.git || true
git clone https://github.com/rgthree/rgthree-comfy.git || true
git clone https://github.com/chrisgoringe/cg-use-everywhere.git || true
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git || true
git clone https://github.com/ShmuelRonen/ComfyUI-VideoUpscale_WithModel.git || true
git clone https://github.com/chflame163/ComfyUI_LayerStyle.git || true
git clone https://github.com/thu-ml/SageAttention.git ComfyUI-SageAttention || true

# =============================
# VERIFY
# =============================

echo "[INFO] Setup complete. Verifying..."
du -sh $MODELS_DIR/* 2>/dev/null || true
ls -lh $NODES_DIR | head -30

echo "[DONE] ComfyUI setup finished successfully!"

