# Panorama 概览

## 简介

Panorama 是 Valve 开发的 UI 框架，使用 XML/CSS/JS 技术栈。已完全取代 Scaleform。

## 文件结构

### 目录约定

```
content/dota_addons/ADDON_NAME/panorama/
├── layout/custom_game/
│   ├── custom_ui_manifest.xml    # UI 入口（必需）
│   ├── custom_loading_screen.xml # 加载界面（可选）
│   └── *.xml                     # 其他布局文件
├── styles/custom_game/
│   └── *.css                     # 样式文件
└── scripts/custom_game/
    └── *.js                      # 脚本文件
```

**注意**：部分项目会将 CSS 和 JS 文件与 XML 放在同一目录（`layout/custom_game/`），而非按上述标准结构分开。查找文件时应检查实际项目结构。

### 入口文件

- **Custom UI Manifest**：`custom_ui_manifest.xml` 是 UI 入口，所有自定义 UI 从这里加载。详见 `custom-ui-manifest.md`
- **加载界面**：`custom_loading_screen.xml` 独立加载，时机早于 manifest

## 核心概念

### Panel

Panel 是 UI 的基本单元。所有可见元素（标签、图像、按钮）都是 Panel。详见 `panels.md`。

### XML 布局

XML 描述 UI 结构和 Panel 层级。

**约束**：
- `<root>` 元素内只能有一个无 ID 的 Panel
- 违反此约束会导致编译错误："Found duplicate panel description"
- **已废弃**：`<script>` 标签直接包含脚本的方式已废弃。逻辑必须写在独立 JS 文件中，通过 `<scripts>` 和 `<include>` 引入

### CSS 样式

CSS 定义 Panel 的呈现方式。

**约束**：
- 部分 CSS 属性与 Web CSS 不同，完整列表参见 `dota2-script-ref` skill 的 `panorama/css.json`
- 无需考虑浏览器兼容性

### JavaScript

JS 处理用户交互和游戏状态。

**关键约束**：
- `$` 选择器只能按 ID 匹配单个 Panel：`$('#panel_id')`
- 无匹配时返回 `null`（不是空集合），直接调用方法会报错
- 无 `document.querySelector` 等 Web API

### 事件

Panel 间通信机制，有特定的路由规则。

## 关键约束

### 加载界面

- 必须轻量，避免影响加载速度
- **禁止**引用游戏内容（3D 模型、粒子等）

### JavaScript

- `$` 选择器功能受限：仅支持 ID 选择，返回 `null` 而非空集合
- 无 DOM API（`document.querySelector`、`fetch`、`localStorage` 等）
- 游戏数据通过 `Entities.*`、`Players.*` 等命名空间访问（参见 `game-objects.md`）

### 热重载

- 修改文件后自动重载
- 异常时使用 `dota_launch_custom_game ADDON_NAME MAP_NAME` 重新加载
## 服务端 API

### DynamicHud（服务端创建 UI）

| 函数 | 签名 |
|------|------|
| `CustomUI.DynamicHud_Create` | `(playerID: int, elementID: string, layoutFile: string, dialogVars: table)` |
| `CustomUI.DynamicHud_Destroy` | `(playerID: int, elementID: string)` |
| `CustomUI.DynamicHud_SetDialogVariables` | `(playerID: int, elementID: string, vars: table)` |
| `CustomUI.DynamicHud_SetVisible` | `(playerID: int, elementID: string, visible: bool)` |

`playerID = -1` 表示所有玩家。

### GameUI.SetMouseCallback

详见 `mouse-callback.md`。

## 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| "Found duplicate panel description" | `<root>` 内有多个无 ID Panel | 确保只有一个无 ID 的根 Panel |
| `null` 相关 JS 错误 | `$` 选择器未匹配到 Panel | 检查 Panel ID 是否存在 |
