# 本地化文本文件

Dota 2 自定义游戏使用 KV 格式的本地化文件来定义游戏名称、技能描述、修饰器文本、HUD 字符串等。

## 文件位置与命名

本地化文件位于两个位置：

- `resource/addon_<language>.txt` — 服务端通用本地化
- `panorama/localization/addon_<language>.txt` — Panorama UI 专用本地化

```
<addon_name>/
├── resource/
│   ├── addon_english.txt      # 英文
│   ├── addon_schinese.txt     # 简体中文
│   └── ...
└── panorama/
    └── localization/
        ├── addon_english.txt  # 英文
        ├── addon_schinese.txt # 简体中文
        └── ...
```

以下语言有支持：brazilian、bulgarian、czech、danish、dutch、english、finnish、french、german、greek、hungarian、italian、japanese、korean、koreana、latam、norwegian、polish、portuguese、romanian、russian、schinese、spanish、swedish、tchinese、thai、turkish、ukrainian、vietnamese。

如果语言缺失部分键值对，默认会使用英文的键值对。

## 文件结构

### resource/ 格式

`resource/` 下的本地化文件使用以下 KV 结构：

```kv
"lang"
{
    "Language"      "English"
    "Tokens"
    {
        "addon_game_name"    "YOUR ADDON NAME"
    }
}
```

- `"Language"` 的值必须与文件名中的语言标识一致（如 `addon_schinese.txt` 中为 `"SChinese"`）
- `"Tokens"` 包含所有本地化键值对
- 键名始终使用英文，仅值需要翻译
- 如果 Dota2 自己也有本地化键，自定义游戏内的键值对优先级更高。

## 键名约定

| 键名前缀                                              | 用途       | 示例                                                                          |
| ------------------------------------------------- | -------- | --------------------------------------------------------------------------- |
| `addon_game_name`                                 | 游戏显示名称   | `"addon_game_name" "My Custom Game"`                                        |
| `DOTA_Tooltip_ability_<name>`                     | 技能显示名称   | `"DOTA_Tooltip_ability_my_ability" "Fireball"`                              |
| `DOTA_Tooltip_ability_<name>_Description`         | 技能描述     | `"DOTA_Tooltip_ability_my_ability_Description" "Deals damage..."`           |
| `DOTA_Tooltip_ability_<name>_Lore`                | 技能背景故事   | `"DOTA_Tooltip_ability_my_ability_Lore" "Ancient flames..."`                |
| `DOTA_Tooltip_ability_<name>_Note0`..`NoteN`      | 技能备注     | `"DOTA_Tooltip_ability_my_ability_Note0" "Does not..."`                     |
| `DOTA_Tooltip_ability_<name>_Scepter_Description` | 技能神杖升级描述 | `"DOTA_Tooltip_ability_my_ability_Scepter_Description" "Ancient flames..."` |
| `DOTA_Tooltip_ability_<name>_Shard_Description`   | 技能魔晶升级描述 | `"DOTA_Tooltip_ability_my_ability_Shard_Description" "Ancient flames..."`   |
| `DOTA_Tooltip_modifier_<name>`                    | 修饰器显示名称  | `"DOTA_Tooltip_modifier_my_modifier" "Burning"`                             |
| `DOTA_Tooltip_modifier_<name>_Description`        | 修饰器描述    | `"DOTA_Tooltip_modifier_my_modifier_Description" "Taking damage..."`        |
| `DOTA_HUD_<context>`                              | HUD 文本   | `"DOTA_HUD_Victory" "Victory!"`                                             |
| `npc_dota_<unit_name>`                            | 单位显示名称   | `"npc_dota_my_unit" "Fire Elemental"`                                       |
| `DOTA_GameMode_<id>`                              | 游戏模式名称   | `"DOTA_GameMode_15" "My Game Mode"`                                         |
| `dota_hud_error_<context>`                        | 错误提示     | `"dota_hud_error_not_enough_gold" "Not enough gold"`                        |

## 格式化语法

本地化值支持以下格式化方式：

### 参数替换

- `%value%` — 引用技能特殊值（AbilityValues 中定义的变量）
- `%value%%%` — 显示为百分比（如 `50%`）
- `{d:int_value}` — 动态整数值
- `{s:string_value}` — 动态字符串值

### HTML 富文本

- `<font color='#70EA72'>text</font>` — 彩色文本（常用于高亮自定义值）
- `<h1>text</h1>` — 粗体标题
- `<br>` 或 `<br/>` — 换行
- `\n` — 换行符

### 注释

支持 `//` 单行注释：

```kv
"lang"
{
    "Language"      "English"
    "Tokens"
    {
        "addon_game_name"    "My Game"
        // "old_key"          "Deprecated value"
    }
}
```

## 示例
###  一般示例

```kv
"lang"
{
    "Language"      "English"
    "Tokens"
    {
        "addon_game_name"    "Custom Hero Clash"
        
        // 技能
        "DOTA_Tooltip_ability_custom_fireball"              "Fireball"
        "DOTA_Tooltip_ability_custom_fireball_Description"  "Launches a fireball that deals <font color='#70EA72'>%damage%</font> damage in an area."
        "DOTA_Tooltip_ability_custom_fireball_Lore"         "The ancient flames consume all in their path."
        "DOTA_Tooltip_ability_custom_fireball_Note0"        "Does not affect allies."
        
        // 修饰器
        "DOTA_Tooltip_modifier_custom_burn"                 "Burning"
        "DOTA_Tooltip_modifier_custom_burn_Description"     "Taking <font color='#70EA72'>%dps%</font> damage per second."
        
        // HUD
        "DOTA_HUD_Victory"    "Victory!"
        "DOTA_HUD_Defeat"     "Defeat!"
        
        // 单位
        "npc_dota_custom_fire_elemental"    "Fire Elemental"
    }
}
```
### 中文翻译示例

```kv
"lang"
{
    "Language"      "schinese"
    "Tokens"
    {
        "addon_game_name"    "自定义英雄大乱斗"
        
        "DOTA_Tooltip_ability_custom_fireball"              "火球术"
        "DOTA_Tooltip_ability_custom_fireball_Description"  "发射一个火球，对区域内造成 %damage% 点伤害。"
        "DOTA_Tooltip_ability_custom_fireball_Lore"         "远古的烈焰吞噬一切。"
        
        "DOTA_Tooltip_modifier_custom_burn"                 "燃烧"
        "DOTA_Tooltip_modifier_custom_burn_Description"     "每秒受到 <font color='#70EA72'>%dps%</font> 点伤害。"
        
        "npc_dota_custom_fire_elemental"    "火元素"
    }
}
```

## 注意事项

- 键名区分大小写
- 非英文文件的键名仍使用英文，仅值需要翻译
- 文件编码为 UTF-8
- 支持 `//` 单行注释，可用于标记废弃的键
- **不要**使用 `#base` 或 `#include`，它们对本地化文本无效。

## Panorama 本地化文件

Panorama UI 使用独立的本地化文件，位于 `game/dota_addons/<addon_name>/panorama/localization/` 目录下，命名规则与 `resource/` 相同（`addon_<language>.txt`）。

覆盖原生的部分文本（如“无视减益免疫”）必须放在 Panorama 本地化文件中才能生效。

文件结构与 `resource/` 下的不同——根键为 `"dota"`，直接包含键值对列表：

```kv
"dota"
{
    "addon_game_name"    "My Custom Game"
    
    "DOTA_Tooltip_ability_custom_fireball"              "Fireball"
    "DOTA_Tooltip_ability_custom_fireball_Description"  "Launches a fireball..."
}
```
