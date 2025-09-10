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
