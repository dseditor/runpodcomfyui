# RunPod "找不到 Handler" 問題診斷

## ✅ 已確認正確的部分

1. **handler.py 在 repo 中**
   ```bash
   $ git ls-files | grep handler
   handler.py  # ✅ 35KB
   ```

2. **Dockerfile 正確配置**
   ```dockerfile
   COPY handler.py /handler.py  # ✅ 複製到根目錄
   CMD ["/start.sh"]            # ✅ 啟動腳本
   ```

3. **start.sh 正確調用 handler**
   ```bash
   python -u /handler.py  # ✅ 執行 handler
   ```

4. **handler.py 包含正確的入口點**
   ```python
   if __name__ == "__main__":
       runpod.serverless.start({"handler": handler})  # ✅
   ```

## 🔍 可能的問題原因

### 1. RunPod 構建失敗

**症狀**: RunPod Console 顯示構建錯誤

**檢查方法**:
1. 前往 RunPod Console → Serverless → Your Endpoint
2. 查看 **Build Logs**
3. 尋找錯誤訊息

**常見原因**:
- 基礎鏡像無法拉取（`niketgupta2002/comfyui-wanvideo-runpod:v1.1`）
- pip install 失敗
- COPY/ADD 指令失敗

**解決方法**:
```dockerfile
# 在 Dockerfile 中添加調試信息
RUN ls -la / && echo "Checking if handler.py exists:" && ls -la /handler.py
```

### 2. GitHub Repo 訪問問題

**症狀**: RunPod 無法訪問 GitHub repo

**檢查方法**:
- 確認 repo 是 Public（或提供了正確的 access token）
- 確認 GitHub URL 正確：`https://github.com/dseditor/runpodcomfyui`
- 確認 Branch 是 `main`

**解決方法**:
- 將 repo 設為 Public
- 或在 RunPod 配置中添加 GitHub Personal Access Token

### 3. Dockerfile 路徑配置錯誤

**症狀**: RunPod 找不到 Dockerfile

**檢查**:
- Dockerfile Path 應該是：`Dockerfile`（不是 `Dockerfile.runpod`）
- Dockerfile 在 repo 根目錄

**當前狀態**:
```
runpodcomfyui/
├── Dockerfile  ✅ 正確位置
├── handler.py  ✅
├── start.sh    ✅
└── ...
```

### 4. RunPod 掃描器問題

**症狀**: RunPod 在創建 endpoint 時顯示警告

**可能原因**:
- RunPod 的自動掃描器期望特定的檔案結構
- 缺少某些元數據

**解決方法**:
嘗試添加 LABEL 到 Dockerfile：
```dockerfile
LABEL com.runpod.handler="/handler.py"
LABEL com.runpod.description="ComfyUI Video Generator (Wan 2.2)"
```

### 5. 運行時錯誤

**症狀**: Endpoint 創建成功，但運行時報錯

**檢查方法**:
1. 查看 **Container Logs**
2. 尋找啟動錯誤

**常見錯誤**:
```
worker-comfyui - Checking API server at http://127.0.0.1:8188/...
❌ ComfyUI failed to start
```

**解決方法**:
- 確認 Network Volume 已附加
- 確認模型已上傳到 `/workspace/models/`
- 檢查 GPU 記憶體是否足夠（需要 24GB+）

## 🛠️ 診斷步驟

### 步驟 1: 確認 Endpoint 配置

前往 RunPod Console，檢查設置：

| 設定 | 正確值 |
|------|-------|
| Container Type | **GitHub** |
| GitHub URL | `https://github.com/dseditor/runpodcomfyui` |
| Branch | `main` |
| Dockerfile Path | `Dockerfile` |
| GPU | RTX 4090 或 RTX 5090 |
| Network Volume | 已附加，Mount Path **留空** |

### 步驟 2: 檢查構建日誌

1. 點擊 Endpoint → **Logs** → **Build Logs**
2. 查找：
   ```
   Step X/Y : COPY handler.py /handler.py
   ✅ 應該成功
   ```
3. 查找最後幾行：
   ```
   Successfully tagged ...
   ✅ 構建成功
   ```

### 步驟 3: 檢查運行日誌

1. 點擊 **Container Logs**
2. 應該看到：
   ```
   ==========================================
     ComfyUI RunPod Serverless Worker
   ==========================================

   ✅ Network volume detected at /workspace
   📋 Model verification:
      Diffusion: 2 files
      CLIP: 1 files

   🎬 Starting ComfyUI...
   🎧 Starting RunPod Handler...
   ```

3. 如果看到錯誤，記錄並報告

### 步驟 4: 測試 Handler

創建測試請求：
```bash
curl -X POST https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "input": {
      "images": [{"name": "test.png", "image": "data:image/png;base64,iVBORw0KG..."}],
      "workflow": {}
    }
  }'
```

## 📋 完整檢查清單

- [ ] GitHub repo 是 Public 或已配置 token
- [ ] Dockerfile 在 repo 根目錄
- [ ] handler.py 在 repo 中（`git ls-files | grep handler`）
- [ ] RunPod Endpoint 配置正確
- [ ] Dockerfile Path = `Dockerfile`
- [ ] Branch = `main`
- [ ] Network Volume 已附加
- [ ] GPU 類型正確（RTX 4090/5090）
- [ ] 查看 Build Logs 無錯誤
- [ ] 查看 Container Logs 顯示成功啟動

## 🔗 相關文件

- **handler.py**: https://github.com/dseditor/runpodcomfyui/blob/main/handler.py
- **Dockerfile**: https://github.com/dseditor/runpodcomfyui/blob/main/Dockerfile
- **start.sh**: https://github.com/dseditor/runpodcomfyui/blob/main/start.sh

## 💡 快速修復

如果仍然無法解決，嘗試：

### 選項 A: 使用最小化測試 Dockerfile

創建一個簡單的 Dockerfile 測試：
```dockerfile
FROM niketgupta2002/comfyui-wanvideo-runpod:v1.1
RUN pip install runpod
COPY handler.py /handler.py
CMD ["python", "-u", "/handler.py"]
```

### 選項 B: 檢查基礎鏡像

驗證基礎鏡像可訪問：
```bash
docker pull niketgupta2002/comfyui-wanvideo-runpod:v1.1
```

### 選項 C: 聯繫 RunPod 支援

如果以上都無法解決，提供：
1. Endpoint ID
2. Build Logs 截圖
3. Container Logs 截圖
4. 錯誤訊息的完整文本

## 📞 獲取幫助

- RunPod Discord: https://discord.gg/runpod
- RunPod Docs: https://docs.runpod.io
- GitHub Issues: https://github.com/dseditor/runpodcomfyui/issues

---

**您看到的具體錯誤訊息是什麼？** 請提供完整的錯誤文本或截圖，我可以幫您更精確地診斷問題。
