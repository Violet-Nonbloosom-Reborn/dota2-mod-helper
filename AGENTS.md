# Agent 指引

## 项目概述

本仓库包含一个 Dota 2 自定义游戏开发辅助 Agent Skill。该 Skill 提供以下领域的指引、代码模式和参考文档：

- **KeyValue (KV)** 文件 — 技能、单位、物品、修饰器定义
- **Lua (VScript)** — 服务端游戏逻辑
- **Panorama** — 客户端 UI（XML、JavaScript、CSS）

## 仓库结构

```
dota2-mod-helper/
├── skills/
│   ├── SKILL.md              # Skill 定义（必需）
│   └── references/           # 领域参考文档
│       ├── kv/               # KV 模式与约定
│       ├── lua/              # Lua vscript 模式
│       └── panorama/         # Panorama UI 模式
├── AGENTS.md                 # 本文件
└── LICENSE
```

## 语言约定

本 Skill 涵盖三种语言/技术：

| 领域 | 语言 | 文件类型 | 用途             |
|------|------|----------|------|
| 数据定义 | KeyValue (KV) | `.txt` | 技能、单位、物品、修饰器定义 |
| 服务端逻辑 | Lua | `.lua` | VScript 游戏逻辑   |
| 客户端 UI | XML + JavaScript + CSS | `.xml`, `.js`, `.css` | Panorama UI 面板 |

**注意**：本 Skill 不包含 API 参考（函数、常量、枚举）。API 参考维护在独立的 Skill `dota2-script-ref`（仓库：`violet-nonblossom-reborn/dota2-script-ref`）中。

## TypeScript 警告

**该 Skill 专注于 Lua + JavaScript + KV 方案。若当前项目采用 TypeScript，请警告用户，并询问是否继续。**

TypeScript 也可用于 Dota 2 自定义游戏开发，但通常不与 Lua + JavaScript 方案同时使用。本 Skill 的参考文档和代码模式均基于 Lua + JavaScript + KV 方案，若项目使用 TypeScript，则可能采用不同的工具链，本 Skill 的适用性有限。

使用本 Skill 前：

1. 检查当前项目是否使用了 TypeScript：
   - 查找 `tsconfig.json`
   - 查找 `.ts` 或 `.tsx` 文件
   - 检查 `package.json` 中的 TypeScript 依赖

2. 若检测到 TypeScript：
   - **停止**并警告用户
   - 说明本 Skill 基于 Lua + Panorama JS + KV 方案，与 TypeScript 方案通常不共存
   - 询问用户是否仍要继续

警告示例：
```
⚠️ 警告：当前项目似乎使用了 TypeScript。

本 Skill 基于 Lua + JavaScript + KV 方案，一般不与 Typescript 同时使用。
若项目采用 TypeScript 工具链，本 Skill 的参考内容可能不适用。

是否仍要继续？
```

## Skill 开发指南

- 遵循标准 Skill 格式（参见 skill-creator skill）
- `SKILL.md` 保持在 500 行以内
- 使用渐进式披露：SKILL.md 负责导航，references 负责详细内容
- 不在本 Skill 中包含 API 参考
- 不引入未经授权的第三方内容
