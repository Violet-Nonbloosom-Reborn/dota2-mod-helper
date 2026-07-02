# Panel 类型参考

## 约束

- XML 文件的**顶层 Panel 不能有 `id`**，必须使用 `class`，否则无法正确渲染
- 可通过 Panorama Debugger 检查现有 UI 结构

## 通用 Panel

| Panel          | 用途                                   | 关键属性                                       |
| -------------- | ------------------------------------ | ------------------------------------------ |
| `Panel`        | 空容器，用于层级、布局、边框。类似 HTML `div`         | —                                          |
| `Button`       | 按钮，无自带视觉元素，需添加子 Label/Image 或 CSS 背景 | `onactivate`                               |
| `Image`        | 图片，支持 PNG/PSD/TGA 等引擎纹理格式            | `src`, `scaling`                           |
| `Label`        | 文本，支持纯文本或 HTML                       | `text`, `html`                             |
| `TextEntry`    | 可编辑文本框                               | `maxchars`, `placeholder`, `oninputsubmit` |
| `DropDown`     | 下拉选择。每个选项必须有唯一 `id`                  | `oninputsubmit`                            |
| `ToggleButton` | 切换按钮（复选框）                            | `checked`, `text`                          |
| `RadioButton`  | 单选按钮，同 `group` 内只能选中一个               | `group`, `checked`, `text`                 |

## DOTA 专用 Panel

| Panel              | 用途                  | 关键属性                                       |
| ------------------ | ------------------- | ------------------------------------------ |
| `DOTAHeroImage`    | 英雄图片                | `heroid` 或 `heroname`, `heroimagestyle`    |
| `DOTAAvatarImage`  | Steam 头像            | `steamid`（`"local"` 表示本地玩家，或 64 位 SteamID） |
| `DOTAItemImage`    | 物品图片                | `itemname`                                 |
| `DOTAAbilityImage` | 技能图片                | `abilityname`                              |
| `DOTAUserName`     | Steam 用户名           | `steamid`                                  |
| `DOTAScenePanel`   | 3D 场景面板，渲染英雄模型或粒子特效 | `unit`, `camera`, `map`, `particleonly`    |
| `ProgressBar`      | 进度条                 | `min`, `max`, `value`                      |

## Image 缩放模式

| `scaling` 值 | 说明 |
|--------------|------|
| `stretch` | 默认，拉伸填充 |
| `none` | 原始尺寸 |
| `stretchx` | 仅水平拉伸 |
| `stretchy` | 仅垂直拉伸 |
| `stretch-to-fit-preserve-aspect` | 等比缩放适配 |
| `stretch-to-fit-x-preserve-aspect` | 等比缩放适配宽度 |
| `stretch-to-fit-y-preserve-aspect` | 等比缩放适配高度 |
| `stretch-to-cover-preserve-aspect` | 等比缩放覆盖 |

## DOTAHeroImage 图片样式

| `heroimagestyle` 值 | 尺寸 | 用途 |
|---------------------|------|------|
| `landscape` | 128x72 | 记分板 |
| `portrait` | 71x94 | 英雄选择 |
| `icon` | 32x32 | 小地图 |

## Image 资源路径

图片存放在 `content/dota_addons/ADDON_NAME/panorama/images/`，编译后自动转为 VTEX_C。

```xml
<Image src="file://{images}/custom_game/my_image.png" />
```

## Label HTML 标签

设置 `html="true"` 后支持以下标签：

| 标签 | 说明 |
|------|------|
| `<b>`, `<i>`, `<em>`, `<strong>` | 文本格式 |
| `<h1>`, `<h2>` | 标题 |
| `<br>`, `<p>` | 换行、段落 |
| `<li>` | 列表项 |
| `<span class="...">` | 文本范围样式（推荐方式） |
| `<font color="#ff0000">` | 字体颜色（不推荐，应使用 span + class） |
| `<img src="...">` | 内嵌图片 |
| `<a href="..." onmouseover="..." onmouseout="..." oncontextmenu="...">` | 链接，支持 URL、Panorama 事件、`javascript:` 函数 |

```xml
<Label html="true" text="Click &lt;a href=&quot;http://www.example.com&quot;&gt;here&lt;/a&gt;" />
```

## DOTAScenePanel

渲染 3D 英雄模型或粒子特效的面板。

```xml
<!-- 渲染英雄模型 -->
<DOTAScenePanel id="HeroModel" unit="npc_dota_hero_axe" camera="default_camera" />

<!-- 渲染粒子特效 -->
<DOTAScenePanel id="ParticleFX" map="particles/my_effect" camera="shot_camera" particleonly="true" />
```

| 属性 | 说明 |
|------|------|
| `unit` | 英雄单位名（如 `npc_dota_hero_axe`） |
| `map` | 粒子资源路径 |
| `camera` | 摄像机名称 |
| `particleonly` | 设为 `true` 时仅渲染粒子 |

可通过 JS 动态设置英雄：

```javascript
$("#HeroModel").SetUnit("npc_dota_hero_pudge", "default_camera");
```

## ProgressBar

进度条控件，常用于血条、蓝条、经验条。

```xml
<ProgressBar id="HealthBar" min="0" max="100" value="75" />
```

| 属性 | 类型 | 说明 |
|------|------|------|
| `min` | Integer | 最小值 |
| `max` | Integer | 最大值 |
| `value` | Integer | 当前值 |

可通过 JS 动态更新：

```javascript
$("#HealthBar").value = 50;
```
