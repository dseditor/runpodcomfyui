# 部署指南

## 快速開始（3 步驟）

### 第 1 步：推送到 GitHub (2 分鐘)

```bash
cd F:\Serverless\runpodworker

# 初始化 Git（如果還沒有）
git init

# 添加文件
git add .
git commit -m "Initial commit: ComfyUI Serverless Worker"

# 推送到 GitHub（先在 GitHub 創建 repo）
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git branch -M main
git push -u origin main
```

### 第 2 步：在 RunPod 創建 Endpoint (3 分鐘)

1. 前往：https://www.runpod.io/console/serverless
2. 點擊 **+ New Endpoint**
3. 配置：

| 選項 | 值 |
|------|-----|
| Name | `comfyui-video-worker` |
| GPU Type | RTX 5090 或 RTX 4090 |
| Container Type | **GitHub** |
| GitHub URL | `https://github.com/YOUR_USERNAME/YOUR_REPO` |
| Branch | `main` |
| Dockerfile Path | `Dockerfile` |
| Network Volume | 選擇您的 volume |
| Volume Mount Path | **留空**（自動使用 `/workspace`）|
| Min Workers | `0` |
| Max Workers | `3` |
| Idle Timeout | `60` 秒 |
| Execution Timeout | `600` 秒 |

4. 點擊 **Deploy**

### 第 3 步：等待構建並測試 (10 分鐘)

**等待構建**：
- 首次構建約 5-10 分鐘
- 在 Endpoint 頁面查看進度
- 狀態變為 **Active** 即完成

**測試 Endpoint**：

創建 `test_input.json`：
```json
{
  "input": {
    "workflow": {
      "6": {
        "inputs": {
          "text": "A beautiful sunset"
        },
        "class_type": "CLIPTextEncode"
      }
    }
  }
}
```

發送請求：
```bash
curl -X POST https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d @test_input.json
```

**檢查 Logs**：

前往 RunPod Console → Serverless → Your Endpoint → Logs

應該看到：
```
==========================================
  ComfyUI RunPod Serverless Worker
==========================================

✅ Network volume detected at /workspace
   Models will be loaded from network volume

📋 Model verification:
   Diffusion: 2 files
   CLIP: 1 files
   VAE: 1 files
   LoRA: 3 files
   Upscale: 1 files

🎬 Starting ComfyUI...
   Log level: INFO

==========================================
🎧 Starting RunPod Handler...
==========================================

worker-comfyui - Checking API server at http://127.0.0.1:8188/history/...
worker-comfyui - API is reachable
```

---

## 更新代碼

當您修改 handler.py 或其他文件後：

```bash
cd F:\Serverless\runpodworker
git add .
git commit -m "Update handler"
git push
```

RunPod 會自動檢測更新並重新構建（約 5 分鐘）。

---

## 檢查清單

部署前確認：

- [ ] Network Volume 已創建並上傳模型
- [ ] GitHub repo 已創建
- [ ] 代碼已推送到 GitHub
- [ ] RunPod Endpoint 已創建
- [ ] Network Volume 已附加到 Endpoint
- [ ] Volume Mount Path 為空（使用默認 `/workspace`）

部署後驗證：

- [ ] 構建成功（狀態 = Active）
- [ ] Logs 顯示模型已加載
- [ ] 測試請求返回成功
- [ ] 輸出視頻可下載

---

## 常見問題

### Q1: 構建失敗

**檢查**：
- GitHub repo URL 是否正確
- Dockerfile 路徑是否為 `Dockerfile`（不是其他名稱）
- 查看 Build Logs 找出錯誤

### Q2: 模型顯示 0 files

**檢查**：
- Network Volume 是否附加到 Endpoint
- Volume Mount Path 是否留空
- 用 CPU Pod SSH 進入驗證：`ls -la /workspace/models/`

### Q3: ComfyUI 啟動失敗

**檢查**：
- GPU 記憶體是否足夠（至少 24GB）
- 查看 Container Logs 找出錯誤
- 確認基礎鏡像 `niketgupta2002/comfyui-wanvideo-runpod:v1.1` 可用

### Q4: 請求超時

**檢查**：
- Execution Timeout 是否足夠（建議 600 秒）
- Worker 是否已啟動（Min Workers = 0 時第一次請求會慢）
- 增加 Max Workers 以處理並發請求

---

## 費用優化

- **Min Workers = 0**：閒置時自動縮放到零，不計費
- **Idle Timeout = 60s**：請求結束後 60 秒自動關閉
- **Execution Timeout = 600s**：避免卡住的任務持續計費
- **Network Volume**：固定 $5/月（50GB），但可重複使用

**預估**：
- 每個視頻：$0.01-0.02
- 每月 100 個視頻：~$1-2 + $5（volume）= ~$6-7

---

## 下一步

1. ✅ Endpoint 已部署
2. ⏭️ 集成到前端（參考 `../frontend-adapter.tsx`）
3. ⏭️ 配置 API Key 和 Endpoint ID
4. ⏭️ 開始生成視頻！

---

**需要幫助？**
- RunPod 文檔：https://docs.runpod.io/serverless
- 官方 worker-comfyui：https://github.com/runpod-workers/worker-comfyui
- 查看 Logs 是最好的調試工具
