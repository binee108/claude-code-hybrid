# Claude Code Hybrid Model System

**Leader runs Anthropic Opus. Teammates run any model you choose.**

Use Claude Code Teams with a hybrid architecture: the leader (orchestrator) uses Anthropic's direct API while teammates use alternative models like GLM, Codex, Kimi, or any OpenAI-compatible provider.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/binee108/claude-code-hybrid/main/install.sh | bash
```

Then restart your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```

## How It Works

```
ct --model glm
    |
    +-- Leader pane: Anthropic Opus (direct API)
    |
    +-- Teammate pane 1: GLM-5
    +-- Teammate pane 2: GLM-5
    +-- Teammate pane N: GLM-5
```

The system uses tmux's `session-created` hook to automatically inject model environment variables at the session level. The leader's pane explicitly unsets these variables, so it always uses Anthropic's direct API. When teammates are spawned as new panes, they inherit the session-level variables and use the configured model.

### Architecture

```
~/.claude-models/*.env       Model profiles (credentials + endpoints)
~/.tmux-hybrid-hook.sh       tmux hook (reads marker, injects env vars)
~/.claude-hybrid-active      Marker file (active model name)
~/.zshrc                     Shell functions (cc, ct, ccw, ctw)
```

### Flow

```
1. ct --model glm
2. Write "glm" to ~/.claude-hybrid-active
3. Create tmux session "claude-teams-glm"
4. Hook fires -> reads marker -> loads glm.env -> sets session-level vars
5. Leader pane: unset vars via send-keys -> Anthropic direct
6. Teammate spawns -> new pane inherits session vars -> GLM
7. .zshrc switcher: HYBRID_ACTIVE detected -> skip unset
```

## Commands

| Command | Description |
|---------|-------------|
| `cc` | Claude Code solo (Anthropic direct) |
| `cc --model glm` | Claude Code solo with GLM |
| `cc --model codex` | Claude Code solo with Codex |
| `ct` | Teams mode (all Anthropic) |
| `ct --model glm` | Teams hybrid (leader: Opus, teammates: GLM) |
| `ct --model codex` | Teams hybrid (leader: Opus, teammates: Codex) |
| `ccw` | Same as `cc` with `--worktree` |
| `ctw` | Same as `ct` with `--worktree` |
| `ctw --model glm` | Teams hybrid + worktree |

Short aliases: `cc-glm`, `ct-glm`

## Model Profiles

Profiles live in `~/.claude-models/`. Each `.env` file uses the same variable names:

```bash
# ~/.claude-models/glm.env
MODEL_AUTH_TOKEN="your-api-key-here"
MODEL_BASE_URL="https://open.bigmodel.cn/api/anthropic"
MODEL_HAIKU="glm-4.7-flashx"
MODEL_SONNET="glm-5"
MODEL_OPUS="glm-5"
```

### Pre-configured Profiles

| Profile | Provider | Requires |
|---------|----------|----------|
| `glm.env` | [ZhipuAI GLM](https://open.bigmodel.cn/) | API key |
| `codex.env` | OpenAI Codex via [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) | CLIProxyAPI running |
| `kimi.env` | Moonshot Kimi via CLIProxyAPI | CLIProxyAPI running |

### Add Your Own Model

Create `~/.claude-models/<name>.env`:

```bash
MODEL_AUTH_TOKEN="your-token"
MODEL_BASE_URL="https://your-api-endpoint.com"
MODEL_HAIKU="model-name-fast"
MODEL_SONNET="model-name-standard"
MODEL_OPUS="model-name-best"
```

Then use it immediately:
```bash
ct --model <name>
```

## Using with CLIProxyAPI

For models that need an OpenAI-to-Anthropic proxy (Codex, Kimi, etc.):

```bash
# Install
brew install cliproxyapi

# Login to ChatGPT (for Codex)
cli-proxy-api --codex-login

# Start proxy (runs on localhost:8317)
brew services start cliproxyapi

# Use it
ct --model codex
```

## Session Management

Multiple sessions are supported. If `claude-teams-glm` already exists, a new session `claude-teams-glm-1` is created automatically:

```
claude-teams          # ct
claude-teams-glm      # ct --model glm (first)
claude-teams-glm-1    # ct --model glm (second)
claude-teams-glm-2    # ct --model glm (third)
claude-teams-codex    # ct --model codex
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/binee108/claude-code-hybrid/main/uninstall.sh | bash
```

Or manually:
```bash
rm -f ~/.tmux-hybrid-hook.sh ~/.claude-hybrid-active
# Remove "CLAUDE HYBRID" block from ~/.zshrc
# Remove hook line from ~/.tmux.conf
# Optionally: rm -rf ~/.claude-models/
```

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) with Teams support
- tmux
- zsh or bash

## License

MIT
