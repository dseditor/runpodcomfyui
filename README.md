# ComfyUI Serverless Worker for RunPod

RunPod Serverless worker for ComfyUI video generation with Wan 2.2 models.

Based on the official [worker-comfyui](https://github.com/runpod-workers/worker-comfyui) template, optimized for Wan 2.2 video generation.

## Features

- 🎬 Video generation using Wan 2.2 distilled models
- ⚡ Serverless deployment (pay per use)
- 📦 Network Volume support for model storage
- 🚀 Based on pre-configured image `niketgupta2002/comfyui-wanvideo-runpod:v1.1`
- 🔄 Standard RunPod worker API
- 🎯 Optimized for RTX 4090/5090 GPUs

## Architecture

- **Base Image**: `niketgupta2002/comfyui-wanvideo-runpod:v1.1`
- **Handler**: Official RunPod worker-comfyui handler
- **Models**: Stored in RunPod Network Volume (mounted at `/workspace`)

## Models Required

Place these in your Network Volume at `/workspace/models/`:

### Diffusion Models (~28GB)
```
diffusion_models/
├── wan2.2_i2v_A14b_high_noise_scaled_fp8_e4m3_lightx2v_4step_comfyui_1030.safetensors
└── wan2.2_i2v_A14b_low_noise_scaled_fp8_e4m3_lightx2v_4step_comfyui.safetensors
```

### CLIP Model (~20GB)
```
clip/
└── umt5_xxl_fp16.safetensors
```

### VAE (~335MB)
```
vae/
└── wan_2.1_vae.safetensors
```

### LoRA Models (~1.5GB)
```
loras/Wan/
├── lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors
├── Wan2.2-Fun-A14B-InP-low-noise-HPS2.1.safetensors
└── Wan2.2-Fun-A14B-InP-high-noise-MPS.safetensors
```

### Upscale Model (~17MB)
```
upscale_models/
└── 2x-AnimeSharpV2_RPLKSR_Sharp.pth
```

## API Usage

### Input Format

```json
{
  "input": {
    "workflow": {
      // Your ComfyUI workflow JSON
    },
    "images": [
      {
        "name": "start_image.png",
        "image": "base64_encoded_image_data"
      }
    ]
  }
}
```

### Output Format

```json
{
  "status": "success",
  "message": "Completed",
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

## Deployment

### Prerequisites

1. **Network Volume** with models uploaded
   - See `../upload-models-simple.md` for instructions
2. **GitHub Repository** with this code
3. **RunPod Account** with API key

### Steps

1. **Push to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
   git push -u origin main
   ```

2. **Create Serverless Endpoint**
   - Go to https://www.runpod.io/console/serverless
   - Click **+ New Endpoint**
   - Configuration:
     - Name: `comfyui-video-worker`
     - GPU: RTX 4090 or RTX 5090
     - Container Type: **GitHub**
     - GitHub URL: `https://github.com/YOUR_USERNAME/YOUR_REPO`
     - Branch: `main`
     - Dockerfile Path: `Dockerfile`
     - Network Volume: Select your volume (leave Mount Path empty for `/workspace`)
     - Min Workers: `0`
     - Max Workers: `3`
     - Idle Timeout: `60` seconds
     - Execution Timeout: `600` seconds

3. **Wait for Build**
   - First build takes 5-10 minutes
   - Check Logs for build progress

4. **Test**
   ```bash
   curl -X POST https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_API_KEY" \
     -d @test_input.json
   ```

## Files

- **Dockerfile** - Container definition based on niketgupta2002 image
- **handler.py** - Official RunPod worker handler
- **start.sh** - Startup script
- **extra_model_paths.yaml** - Network volume configuration
- **README.md** - This file

## Environment Variables

- `COMFY_LOG_LEVEL` - ComfyUI log level (default: `INFO`)
- `REFRESH_WORKER` - Restart worker after each job (default: `false`)
- `WEBSOCKET_RECONNECT_ATTEMPTS` - WebSocket reconnect attempts (default: `5`)
- `WEBSOCKET_RECONNECT_DELAY_S` - Delay between reconnects (default: `3`)

## Cost Estimate

- **Network Volume**: ~$5/month (50GB)
- **Execution** (RTX 4090): ~$0.40/hour
- **Idle**: $0 (auto-scales to zero)
- **Per video**: ~$0.01-0.02 (30-60s execution)
[![Runpod](https://api.runpod.io/badge/dseditor/runpodcomfyui)](https://console.runpod.io/hub/dseditor/runpodcomfyui)

## Troubleshooting

### Models not found

Check logs for model verification output:
```
✅ Network volume detected at /workspace
📋 Model verification:
   Diffusion: 2 files
   CLIP: 1 files
   VAE: 1 files
```

If models show 0 files, verify:
1. Network volume is attached to endpoint
2. Volume Mount Path is empty (uses `/workspace` by default)
3. Models are in correct paths

### ComfyUI won't start

Check container logs:
```bash
# In RunPod Console → Serverless → Endpoint → Logs
```

Common issues:
- Out of memory (use larger GPU)
- Model loading failed (check model paths)
- Port already in use (shouldn't happen in serverless)

## Credits

- ComfyUI by comfyanonymous
- Official worker-comfyui by RunPod
- Wan 2.2 models by lightx2v
- Base image by niketgupta2002

## License

This worker code follows the official worker-comfyui license.
Model licenses apply to their respective models.
