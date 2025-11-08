# ComfyUI Video Generator (Wan 2.2)

Generate high-quality videos using ComfyUI with Wan 2.2 distilled models.

## Features

- 🎬 **Video Generation**: Image-to-video using Wan 2.2 models
- ⚡ **Fast**: Distilled 4-step models for quick generation
- 📦 **Network Volume Support**: Use your own model storage
- 🎯 **RTX 4090/5090 Optimized**: FP8 quantized models for efficiency

## Models Included

This worker requires a network volume with the following models:

### Diffusion Models (~28GB)
- `wan2.2_i2v_A14b_high_noise_scaled_fp8_e4m3_lightx2v_4step_comfyui_1030.safetensors`
- `wan2.2_i2v_A14b_low_noise_scaled_fp8_e4m3_lightx2v_4step_comfyui.safetensors`

### CLIP Model (~20GB)
- `umt5_xxl_fp16.safetensors`

### VAE (~335MB)
- `wan_2.1_vae.safetensors`

### LoRA Models (~1.5GB)
- Various Wan 2.2 LoRA models for fine-tuning

### Upscale Model (~17MB)
- `2x-AnimeSharpV2_RPLKSR_Sharp.pth`

## Requirements

- **GPU**: RTX 4090 or RTX 5090 (24GB VRAM minimum)
- **Network Volume**: 50GB+ with models uploaded
- **Container Disk**: 20GB

## Input Format

```json
{
  "input": {
    "workflow": {
      // Your ComfyUI workflow JSON
    },
    "images": [
      {
        "name": "start_frame.png",
        "image": "base64_encoded_image"
      }
    ]
  }
}
```

## Output Format

```json
{
  "status": "success",
  "output": {
    "images": [
      {
        "url": "https://...",
        "filename": "output.mp4"
      }
    ]
  }
}
```

## Configuration

### Log Level
Control ComfyUI verbosity (DEBUG, INFO, WARNING, ERROR, CRITICAL)

### WebSocket Settings
Configure reconnection behavior for stability

### Worker Refresh
Optionally restart worker after each job for clean state

### S3 Upload
Configure AWS S3 for automatic video upload

## Network Volume Setup

1. Create a RunPod Network Volume (50GB+)
2. Upload models to `/workspace/models/` with proper structure:
   ```
   /workspace/models/
   ├── diffusion_models/
   ├── clip/
   ├── vae/
   ├── loras/
   └── upscale_models/
   ```
3. Attach the volume to your endpoint (leave mount path empty)

## Performance

- **Generation Time**: 30-60 seconds per video (depending on length)
- **Cost**: ~$0.01-0.02 per video (RTX 4090)
- **Idle Cost**: $0 (auto-scales to zero)

## Credits

- ComfyUI by comfyanonymous
- Wan 2.2 models by lightx2v
- Worker based on official RunPod worker-comfyui
- Base image by niketgupta2002

## Support

For issues and questions:
- GitHub: https://github.com/dseditor/runpodcomfyui
- RunPod Docs: https://docs.runpod.io
