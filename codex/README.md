# 更新自己的 pstack fork

這是 `cursor/plugins` 的公開 fork。保留完整上游 Git 歷史，並在 `codex/` 保存本機的 Codex 整合與模型設定。

目前基底是 pstack **v0.15.36**，上游 commit 為 `4dd1d05818d19792e7cd6e818f1667f95f7e1dbe`。本機已安裝套件的 559 個檔案與 `harness/pstack/claude-code/` 逐檔 SHA-256 比對一致，排除執行期 `.in_use/`。

## 同步官方新版

在這個 clone 的根目錄執行以下指令。`origin` 是 `Yupoer/pstack-codex`，`upstream` 是 `cursor/plugins`。

```powershell
git status --short
git fetch upstream
git merge upstream/main
git push origin main
```

先處理尚未提交的工作。若 merge 出現衝突，解決衝突並完成提交後再 push。不要用 `reset --hard` 或 force push 取代合併，否則可能丟失自己的修改。

GitHub 的 fork 不會自動同步。合併上游會保留自己的提交；雙方修改相同位置時仍可能需要處理衝突。重新 clone 後，若尚無 `upstream`，先執行 `git remote add upstream https://github.com/cursor/plugins.git`。

## 更新這台 Windows 的安裝

目前本機的插件來源仍是官方 `cursor-plugins` marketplace。Codex 的 adapter 與模型設定位於插件安裝目錄之外，因此本次官方插件更新完整保留了這些客製設定。

```powershell
claude.exe plugin marketplace update cursor-plugins
claude.exe plugin update pstack@cursor-plugins --scope user
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$HOME/.codex/pstack/sync-pstack.ps1"
claude.exe plugin list --json
```

更新後重新啟動 Claude Code，並重新開啟 Codex chat；若技能清單未刷新，再重啟 Codex。同步 fork 本身不會更新本機插件，`sync-pstack.ps1` 只重建技能 junction，不下載插件。

如果日後直接修改 fork 裡的 pstack 技能，必須另將本機安裝來源切換至含有那些修改的套件。本機目前的官方來源不會安裝 fork 專有的技能修改。

## 保存與還原 Codex 整合

`codex-adapter.md`、`sync-pstack.ps1`、`pstack-delegate.ps1` 和 `guide/` 來自既有的 `~/.codex/pstack/`。`rules/pstack-models.md` 來自 `~/.claude/rules/pstack-models.md`。目前所有角色使用 `gpt-6.1-sol high`，panel 保留兩個 agent。

還原前先備份目標檔案並查看差異，再把整合檔與 `guide/` 複製至 `~/.codex/pstack/`，把模型設定複製至 `~/.claude/rules/pstack-models.md`。先透過 Claude Code 安裝並啟用 pstack，再執行 `sync-pstack.ps1`。這個腳本依賴 Claude Code 的 `installed_plugins.json` 安裝紀錄；本 repo 不攜帶該機器專屬紀錄。

`guide/template.md` 是歷史教學範本，其中的預設模型可能與目前設定不同。執行時以 `rules/pstack-models.md` 和實際工具能力為準。herdr 委派另需對應 CLI，封存腳本不代表已驗證所有委派流程。

本次驗證包含官方插件 manifest、58 個 Codex junction、模型設定的 SHA-256，以及本機套件與上游的逐檔比對。未逐一執行全部技能。

上游 pstack 的 MIT 授權與作者資訊保留於原目錄。這個 fork 沒有設定自動同步排程。
