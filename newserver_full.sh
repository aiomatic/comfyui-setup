#!/bin/bash

source /venv/main/bin/activate
COMFYUI_DIR=${WORKSPACE}/ComfyUI

# --- Extra apt packages (if needed) ---
APT_PACKAGES=(
    # "package-1"
    # "package-2"
)

# --- Extra pip packages ---
PIP_PACKAGES=(
    # "package-1"
    # "package-2"
)

# --- Custom Nodes ---
NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/chflame163/ComfyUI_LayerStyle"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/cg-cnu/comfyui-use-everywhere"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/city96/ComfyUI-Get-Meta"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/westontron/ComfyUI-LogicUtils"
    "https://github.com/Fannovel16/comfyui-videohelpersuite"
    "https://github.com/melMass/comfyui-creaprompt"
    "https://github.com/PKzebra/ComfyUI-WanBlockSwap"
    "https://github.com/city96/ComfyUI-GGUF"
    "https://github.com/cubiq/ComfyUI_AnyToAny"
    "https://github.com/layerdiffusion/ComfyUI_LayerUtility"
    "https://github.com/Kosinkadink/ComfyUI-Nunchaku"
    "https://github.com/thu-ml/SageAttention"
)

# --- Models ---
CHECKPOINT_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/checkpoints/wan2.1_t2v.safetensors"
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/checkpoints/wan2.2_ti2v_5B_fp16.safetensors"
)

UNET_MODELS=(
    "https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf"
    "https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf"
)

LORA_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/loras/Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors"
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/loras/Wan2.1_I2V_14B_FusionX_LoRA.safetensors"
)

VAE_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"
)

ESRGAN_MODELS=(
    "https://huggingface.co/Sanster/4x-UltraSharp/resolve/main/4x-UltraSharp.pth"
)

CONTROLNET_MODELS=(
    # Add if needed
)

WORKFLOWS=(
    # WAN 2.2 Dual UNet template
    "https://raw.githubusercontent.com/your-repo/workflows/main/wan2.2_dual_unet.json"
)

### DO NOT EDIT BELOW HERE ###
function provisioning_start() {
    provisioning_print_header
    provisioning_get_apt_packages
    provisioning_get_nodes
    provisioning_get_pip_packages
    provisioning_get_files \
        "${COMFYUI_DIR}/models/checkpoints" \
        "${CHECKPOINT_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/unet" \
        "${UNET_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/lora" \
        "${LORA_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/controlnet" \
        "${CONTROLNET_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/vae" \
        "${VAE_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/esrgan" \
        "${ESRGAN_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/workflows" \
        "${WORKFLOWS[@]}"
    provisioning_print_end
}

# === (Rest of official Vast.ai provisioning functions remain unchanged) ===

if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi
