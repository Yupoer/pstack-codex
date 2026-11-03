# 在 Codex 使用 pstack

這個 fork 的 Codex 安裝獨立管理技能、模型設定與更新。基底是上游 pstack v0.15.36。原始 `pstack/` 與上游 Git 歷史保留，方便之後合併新版。

## 安裝與更新

在 Windows PowerShell 於這個 checkout 根目錄執行：

```powershell
& .\codex\sync-pstack.ps1 -SourceRoot $PWD.Path
```

需要 Windows PowerShell 5.1 的啟動方式時，可執行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\codex\sync-pstack.ps1 -SourceRoot .
```

安裝會把來源複製到 `~/.codex/pstack/versions/`，用 `runtime` junction 指向這一版，再把技能連到 `~/.agents/skills/`。`codex/skills/` 的 Codex 專用入口覆蓋同名上游技能。每個安裝的技能都會先載入 [Codex runtime](runtime.md)。

模型設定存於 `~/.codex/pstack/pstack-models.md`。首次安裝沿用 repo 裡所有角色的 `gpt-6.1-sol high`，panel 保留兩個 agent。重跑安裝會保留已存在的模型設定。

安裝程式只取代自己管理的 junction，遇到同名的其他技能會在安裝前停止。原本指向官方 pstack 快取的舊 junction 會移除，目標檔案保留。舊 adapter、herdr 委派腳本與共用教學會移到備份。這些舊整合不再參與 Codex 執行。

`~/.codex/AGENTS.md` 只更新 pstack 區塊，其餘個人指示保留。開啟新的 Codex chat 以載入新指示；若技能清單仍未刷新，再重新啟動 Codex。

需要檢查原始上游、修改來源、同步 fork PR、合併並更新本機時，使用 [maintain-pstack](../pstack/skills/maintain-pstack/SKILL.md)。它會分別確認上游、遠端合併與本機安裝，保留既有模型設定和個人指示。可直接要求「用 maintain-pstack 檢查上游並同步 fork 和本機，驗證後合併」。

只要安裝 fork 已合併的版本時，從乾淨的 checkout 更新來源並安裝：

```powershell
git pull --ff-only origin main
& .\codex\sync-pstack.ps1 -SourceRoot $PWD.Path
```

已安裝的同步腳本也可搭配明確的 checkout 路徑使用：

```powershell
& "$HOME/.codex/pstack/sync-pstack.ps1" -SourceRoot 'C:\repos\pstack-codex'
```

## 非同步熱路徑掃描

可重用的 [async hot-path prompt](../pstack/skills/poteto-mode/references/async-hot-paths.md) 會盤點非同步入口、確認依賴、修正多餘的循序等待並驗證行為。安裝後可從 `~/.agents/skills/poteto-mode/references/async-hot-paths.md` 讀取。完整 prompt 包含完成後建立 GitHub issue；只做本機掃描時移除該段。

## 視覺設計指引

共用指引位於 [`pstack/skills/poteto-mode/references/visual-design.md`](../pstack/skills/poteto-mode/references/visual-design.md)。Poteto mode、Feature、Prototype 與 Experience First 已接入。來源貼文的字型、token、API 與 iframe 限制只在實際宿主支援時適用。

## 檢查與復原

CI/CD 失敗追蹤的共用流程位於 [CI recovery](../pstack/skills/poteto-mode/references/ci-recovery.md)，已接入 Poteto mode、Bug fix、Babysit、PR 與 Shipping。它區分 workflow 綠燈、原失敗關卡通過與修正歸因。歷史統計保留取樣方式、逐筆證據與未解決項目，不把專案個案寫成全域規則。

CI 效能的共用流程位於 [`CI performance diagnosis`](../pstack/skills/benchmark-checklist/references/ci-performance.md)，已接入 Poteto mode、Perf issue、Benchmark checklist 與 PR 流程。純審核先交付報告；實作依既有授權處理。付費資源與檢查覆蓋範圍的變更會明確列出供決策。

```powershell
& .\codex\test-sync-pstack.ps1 -SourceRoot $PWD.Path -TestRoot 'C:\temp\pstack-check'
node scripts/generate-pstack-harness-trees.mjs --check
```

第一個命令在獨立測試目錄檢查安裝、舊 junction 遷移、衝突保護與重跑。第二個命令檢查保留的上游 harness 產物，該產物不是 Codex 的安裝來源。修改 `pstack/` 後，先執行 `node scripts/generate-pstack-harness-trees.mjs` 再提交。

每次安裝都保留上一版 runtime 與 `~/.codex/pstack/backups/<安裝編號>/`。備份中的 `junctions.json` 保存舊連結目標，`AGENTS.md` 保存修改前指示。`install.json` 記錄目前來源、runtime 與備份路徑。復原時先確認目標，再重建對應 junction 並還原備份檔案。

本機驗證證明安裝內容與檔案路由，不代表已逐一執行全部技能。上游 MIT 授權保留於 `pstack/LICENSE`。
