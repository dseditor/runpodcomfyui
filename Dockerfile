# RunPod Serverless Worker for ComfyUI Video Generation
# Based on existing configured image with Wan models support

FROM niketgupta2002/comfyui-wanvideo-runpod:v1.1

# RunPod handler metadata
LABEL com.runpod.handler="/handler.py"
LABEL com.runpod.description="ComfyUI Video Generator (Wan 2.2)"

# Set working directory
WORKDIR /

# Install RunPod dependencies
RUN pip install runpod requests websocket-client

# Add extra_model_paths.yaml to support network volume
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml

# Add the handler and start script
COPY handler.py /handler.py
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Verify handler was copied successfully
RUN ls -lh /handler.py && echo "✅ Handler copied successfully ($(du -h /handler.py | cut -f1))"

# Set environment variables
ENV COMFY_HOST=127.0.0.1:8188
ENV COMFY_LOG_LEVEL=INFO
ENV REFRESH_WORKER=false

# Start the worker
CMD ["/start.sh"]
