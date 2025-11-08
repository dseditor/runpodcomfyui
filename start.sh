#!/usr/bin/env bash

echo "=========================================="
echo "  ComfyUI RunPod Serverless Worker"
echo "=========================================="
echo ""

# Check if network volume is mounted
if [ -d "/workspace/models" ]; then
    echo "✅ Network volume detected at /workspace"
    echo "   Models will be loaded from network volume"
    echo ""

    # Show model counts
    echo "📋 Model verification:"
    [ -d "/workspace/models/diffusion_models" ] && echo "   Diffusion: $(ls /workspace/models/diffusion_models 2>/dev/null | wc -l) files" || echo "   ⚠️  Diffusion models not found"
    [ -d "/workspace/models/clip" ] && echo "   CLIP: $(ls /workspace/models/clip 2>/dev/null | wc -l) files" || echo "   ⚠️  CLIP not found"
    [ -d "/workspace/models/vae" ] && echo "   VAE: $(ls /workspace/models/vae 2>/dev/null | wc -l) files" || echo "   ⚠️  VAE not found"
    [ -d "/workspace/models/loras" ] && echo "   LoRA: $(find /workspace/models/loras -type f 2>/dev/null | wc -l) files" || echo "   ⚠️  LoRA not found"
    [ -d "/workspace/models/upscale_models" ] && echo "   Upscale: $(ls /workspace/models/upscale_models 2>/dev/null | wc -l) files" || echo "   ⚠️  Upscale not found"
    echo ""
else
    echo "⚠️  Network volume not mounted at /workspace"
    echo "   Using built-in models (if any)"
    echo ""
fi

# Set default log level if not specified
: "${COMFY_LOG_LEVEL:=INFO}"

echo "🎬 Starting ComfyUI..."
echo "   Log level: ${COMFY_LOG_LEVEL}"
echo ""

# Start ComfyUI in background
python -u /comfyui/main.py \
    --disable-auto-launch \
    --disable-metadata \
    --verbose "${COMFY_LOG_LEVEL}" \
    --log-stdout &

# Wait a moment for ComfyUI to start
sleep 5

echo "=========================================="
echo "🎧 Starting RunPod Handler..."
echo "=========================================="
echo ""

# Start the RunPod handler
python -u /handler.py
