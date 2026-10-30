# pstack 三端共用安裝教學

這份文件會讓一台 Windows 電腦上的 Claude Code、Codex CLI 和 ChatGPT desktop 三者使用同一份 pstack。

裝好後會是這樣：

- pstack 只有一份，就是 Claude Code 安裝的那份。Codex CLI 和 ChatGPT desktop 透過 junction 讀取同一批檔案。
- 模型設定只有一個檔案：`~/.claude/rules/pstack-models.md`。三端都讀它。
- 用哪個模型，取決於你在哪裡開：

| 在哪裡開 | 執行類角色（寫程式、修 bug、探索、驗證） | 構思類角色（設計、判斷、寫作、總結） | 會跨模型嗎 |
| --- | --- | --- | --- |
| Claude Code | GPT-6.1 Sol high，在 herdr 開 Codex CLI 執行 | Opus 5.5 medium | 會 |
| herdr 裡的 Codex CLI | GPT-6.1 Sol high | Opus 5.5 medium，在 herdr 開 Claude Code 執行 | 會 |
| ChatGPT desktop app | GPT-6.1 Sol high | GPT-6-Astra high | **不會**，全程只用 GPT |
| herdr 外直接開的 Codex CLI | GPT-6.1 Sol high | GPT-6-Astra high | 不會，同 desktop |

- 判斷依據是環境變數 `HERDR_ENV`。herdr 開出的 terminal 都有 `HERDR_ENV=1`，desktop app 沒有，所以 desktop 永遠不會去呼叫 Claude。

## 0. 先備條件

逐項確認。缺任何一項，後面都會失敗。

| 項目 | 檢查指令（PowerShell） | 應該看到 |
| --- | --- | --- |
| Claude Code | `claude --version` | 版本號 |
| Codex CLI | `codex.cmd --version` | `codex-cli` 版本號 |
| ChatGPT desktop | 開啟 app | 能進入 Codex 對話 |
| herdr | `herdr status` | `server: status: running` |
| 模型權限 | 見第 6 步冒煙測試 | 兩個都回 `PONG` |

重點提示：

- 在 PowerShell 裡要打 `codex.cmd`，不要打 `codex`。Windows 預設的執行原則會擋掉 `codex.ps1`，出現「因為這個系統上已停用指令碼執行」。不要為了這個去改全域執行原則。
- 本文所有 `.ps1` 一律用 `powershell -NoProfile -ExecutionPolicy Bypass -File <檔案>` 執行，原因同上。

## 1. 在 Claude Code 安裝 pstack

在 Claude Code 裡輸入：

```text
/plugin marketplace add cursor/plugins
/plugin install pstack@cursor-plugins
```

裝完後重開 Claude Code。輸入 `/pstack:` 時，應該會看到 `poteto-mode` 等指令。

不要裝錯：

- Claude Code 的指令有 `pstack:` 前綴，例如 `/pstack:poteto-mode`。
- 不要從網路下載別人做的「pstack Codex 版」，也不要裝 `$pstack` 入口 skill。那類移植版會在 `~/.codex` 再複製一份 pstack，desktop 只會看到少數幾個入口，正是這份教學要避免的狀況。

## 2. 寫入模型設定（三端共用）

在 PowerShell 貼上整段：

```powershell
New-Item -ItemType Directory -Force "$HOME\.claude\rules" | Out-Null
$content = @'
{{MODELS}}'@
[IO.File]::WriteAllText("$HOME\.claude\rules\pstack-models.md", $content + "`n", (New-Object Text.UTF8Encoding $false))
```

不要裝錯：

- 這個檔案不能有 frontmatter，也不要把內容貼進 `CLAUDE.md` 或 `AGENTS.md`。
- **不要再執行 `/pstack:setup-pstack`。** 它會整份覆寫這個檔案，蓋掉 GPT-6.1 Sol 的分工和 herdr 路由說明。如果不小心跑了，重做這一步。
- `gpt-6.1-sol` 必須是這台電腦的 ChatGPT 帳號可以用的模型。打開 `~/.codex/config.toml`，確認 `model = "gpt-6.1-sol"`，或在第 6 步的冒煙測試確認。

## 3. 放入 Codex 端的三個檔案

在 PowerShell 貼上整段。它會建立 `~/.codex/pstack/`，放入 adapter、同步腳本和 herdr 委派腳本：

```powershell
$dir = "$HOME\.codex\pstack"
New-Item -ItemType Directory -Force $dir | Out-Null
$utf8 = New-Object Text.UTF8Encoding $false

$adapter = @'
{{ADAPTER}}'@
[IO.File]::WriteAllText("$dir\codex-adapter.md", $adapter + "`n", $utf8)

$sync = @'
{{SYNC}}'@
[IO.File]::WriteAllText("$dir\sync-pstack.ps1", $sync + "`n", $utf8)

$delegate = @'
{{DELEGATE}}'@
[IO.File]::WriteAllText("$dir\pstack-delegate.ps1", $delegate + "`n", $utf8)

Get-ChildItem $dir
```

應該看到 `codex-adapter.md`、`pstack-delegate.ps1`、`sync-pstack.ps1` 三個檔案。

## 4. 把 pstack 接到 Codex（junction）

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\.codex\pstack\sync-pstack.ps1"
```

第一次應該看到 `skills: 56 total, 56 created`。再跑一次，應該看到 `0 created, 56 kept`。數字會隨 pstack 版本變動，重點是第二次 `created` 為 0。

不要裝錯：

- 如果出現 `exists and is not a pstack junction`，代表 `~/.codex/skills` 裡已經有同名的真實資料夾，通常是舊的移植版。先把它搬到別處，再重跑。
- **刪除 junction 時，不要用 `Remove-Item -Recurse`。** PowerShell 5.1 可能會一路刪進目標，也就是 Claude 的 pstack 本體。要刪就用 `cmd /c rmdir "<路徑>"`，它只移除連結。
- 不要編輯 `~/.claude/plugins/cache/...` 底下的任何檔案。那是 Claude Code 的安裝目錄，更新時會被覆蓋。
- Claude Code 更新 pstack 之後，版本路徑會改變，**一定要重跑這一步**。腳本會自動把舊的連結改到新版本。

## 5. 讓 Codex 知道要讀 adapter

在 PowerShell 貼上。只有在 `AGENTS.md` 還沒有這段時才會加入，所以重複貼也安全：

```powershell
$agents = "$HOME\.codex\AGENTS.md"
if (-not (Test-Path $agents)) { New-Item -ItemType File -Force $agents | Out-Null }
if (-not (Select-String -Path $agents -Pattern 'pstack:begin' -Quiet)) {
$block = @'
{{AGENTS}}'@
    [IO.File]::AppendAllText($agents, "`n" + $block + "`n", (New-Object Text.UTF8Encoding $false))
}
Select-String -Path $agents -Pattern 'pstack:'
```

## 6. 驗證

### 6.1 模型冒煙測試

```powershell
codex.cmd exec -m gpt-6.1-sol -c model_reasoning_effort=high -s read-only --skip-git-repo-check "Reply with exactly the word PONG."
claude -p --model opus --effort medium "Reply with exactly the word PONG."
```

兩個都要回 `PONG`。Codex 的輸出裡應該看到 `model: gpt-6.1-sol` 和 `reasoning effort: high`。

### 6.2 Codex CLI 看得到全部 skill

```powershell
codex.cmd
```

在 Codex 裡輸入 `$pstack:`，應該會列出 `pstack:poteto-mode`、`pstack:how`、`pstack:swarm` 等，包含 24 個 `pstack:principle-*`，總共和第 4 步的數字相同。

### 6.3 ChatGPT desktop

先**完全結束** app，包括系統匣圖示的「結束」，再重新開啟。只關視窗不會重新掃描 skill。輸入 `/` 或 `$pstack:`，應該看到和 6.2 相同的清單。

desktop 不會跨模型。用 pstack 時，它不會在 herdr 開 Claude Code，構思角色改由 GPT-6-Astra high 擔任。如果 desktop 開了 herdr tab 或呼叫了 `claude`，代表 adapter 沒有被讀到，請回頭檢查第 3 步和第 5 步。

另外確認這台電腦的帳號可以用 Astra：

```powershell
codex.cmd exec -m gpt-6-astra -c model_reasoning_effort=high -s read-only --skip-git-repo-check "Reply with exactly the word PONG."
```

### 6.4 herdr 跨模型委派

先在任一資料夾建立 `brief.md`，內容寫 `List the files in this directory.`，然後執行：

```powershell
$s = "$HOME\.codex\pstack\pstack-delegate.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File $s -Kind codex  -Name testcodex  -Repo . -Brief .\brief.md
powershell -NoProfile -ExecutionPolicy Bypass -File $s -Kind claude -Name testclaude -Repo . -Brief .\brief.md
```

每一個都應該在 herdr 開出一個 `pstack-<名稱>` tab，跑完印出報告，然後自動關閉 tab。

如果印出 `No report ... (status blocked)`，代表那個 tab 停在權限或問題對話框。到 herdr 裡看那個 tab，自己決定怎麼回答。看不懂的題目先選「No, and ask again next time」，不要選會改到全域設定的選項。

## 7. 日常使用

| 想做的事 | Claude Code | Codex CLI / ChatGPT desktop |
| --- | --- | --- |
| 主要入口 | `/pstack:poteto-mode <任務>` | `$pstack:poteto-mode <任務>` |
| 不知道用哪個 | `/pstack:poteto-help <問題>` | `$pstack:poteto-help <問題>` |
| 其他 skill | `/pstack:<名稱>` | `$pstack:<名稱>` |

分工會依 `pstack-models.md` 和開啟位置自動套用，見文件開頭的表格。想改 desktop 的構思模型，修改設定檔裡的 `# codex-only design model:` 這一行。

## 8. 更新與移除

- **pstack 更新後。** 重跑第 4 步。
- **想改模型分工。** 只改 `~/.claude/rules/pstack-models.md`，三端會一起生效，新 session 才會讀到。
- **移除 Codex 端。** 對 `~/.codex/skills` 裡每個 pstack junction 執行 `cmd /c rmdir`，刪除 `~/.codex/pstack`，再移除 `AGENTS.md` 中 `<!-- pstack:begin -->` 到 `<!-- pstack:end -->` 的區塊。
