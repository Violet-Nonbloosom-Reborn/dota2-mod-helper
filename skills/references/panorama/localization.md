# Panorama JavaScript 中使用本地化文本

## Token 引用语法

在 Panorama JS 中，本地化 token 以 `#` 前缀引用：

```javascript
// 解析 token 为本地化字符串
var text = $.Localize("#addon_game_name");  // "My Custom Game"

// 检查 token 是否存在
if ($.CanLocalize("#my_custom_token")) {
    // token 存在
}
```

## 核心函数

| 函数 | 用途 | 示例 |
|------|------|------|
| `$.Localize(token, [panel])` | 解析 token 为本地化字符串 | `$.Localize("#DOTA_Tooltip_ability_my_ability")` |
| `$.CanLocalize(token)` | 检查 token 是否存在 | `$.CanLocalize("#my_token")` |
| `$.Language()` | 获取当前语言 | `$.Language()` → `"english"` 或 `"schinese"` |

## Label 文本设置

```javascript
// 通过 token 设置（自动解析 #token）
label.SetLocString("#DOTA_GoodGuys");

// 设置已解析的文本
label.SetAlreadyLocalizedText("天辉");

// 直接设置原始文本（不进行本地化查找）
label.text("Hello World");
```

## 对话框变量

本地化字符串中的 `{d:var_name}` 和 `{s:var_name}` 占位符通过对话框变量替换：

```javascript
// addon_english.txt 中定义：
// "my_message"  "Player {s:player_name} dealt {d:damage_amount} damage!"

var panel = $.GetContextPanel();
panel.SetDialogVariable("player_name", "Pudge");
panel.SetDialogVariableInt("damage_amount", 150);

// 解析时自动替换
var text = $.Localize("#my_message", panel);
// "Player Pudge dealt 150 damage!"
```

| 方法 | 用途 |
|------|------|
| `panel.SetDialogVariable(name, value)` | 设置字符串变量 |
| `panel.SetDialogVariableInt(name, value)` | 设置整数变量 |
| `panel.SetDialogVariableTime(name, value)` | 设置时间变量 |
| `panel.SetDialogVariableLocString(name, token)` | 设置变量为另一个 token |
| `panel.SetDialogVariableLocStringNested(name, token)` | 设置嵌套 token 变量 |

## 单位与英雄名称

```javascript
// 获取单位的本地化名称
var unitName = GameUI.GetUnitNameLocalized("npc_dota_hero_pudge");
// "Pudge"

// 获取单位的 token
var token = GameUI.GetUnitLocToken("npc_dota_hero_pudge");
// "npc_dota_hero_pudge"

// 通过英雄 ID 获取本地化名称
var heroName = GameUI.GetHeroNameLocalizedForHeroID(1);
// "Anti-Mage"
```
