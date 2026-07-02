# Panorama JavaScript

Panorama 使用 JavaScript 作为脚本语言，运行在 Google V8 引擎上。客户端 JS 可与服务端 Lua 通信。

## 脚本引入

```xml
<root>
    <scripts>
        <include src="file://{resources}/scripts/custom_game/my_script.js" />
    </scripts>
    <Panel>
        <!-- ... -->
    </Panel>
</root>
```

源文件路径：`content/dota_addons/ADDON_NAME/panorama/scripts/custom_game/my_script.js`
编译后路径：`game/dota_addons/ADDON_NAME/panorama/scripts/custom_game/my_script.vjs_c`

## `$` 全局对象

### 选择器

`$("#PanelID")` 按 ID 查找面板。

**约束**：
- 只能按 ID 匹配单个 Panel
- 无匹配时返回 `null`（不是空集合），直接调用属性/方法会导致 JS 错误并中断后续脚本执行

```javascript
$("#MyLabel").text = "hello";
```

### 日志

`$.Msg()` 支持所有 JS 类型和任意数量参数，连续输出在同一行。

```javascript
$.Msg("Hello ", { "who": "world" }, "!");
// 输出: Hello {"who":"world"}!
```

### 上下文面板

`$.GetContextPanel()` 返回当前脚本所属 XML 的根面板。

```javascript
// 在外部 JS 文件中
$.GetContextPanel().SetHasClass("context_panel", true);
```

### 动态创建面板

```javascript
var parentPanel = $.GetContextPanel();
var newChild = $.CreatePanel("Panel", parentPanel, "ChildPanelID");
newChild.BLoadLayout("file://{resources}/layout/custom_game/new_panel.xml", false, false);
```

## CSS 属性访问

通过 `panel.style.propertyName` 访问。CSS 连字符命名转为 JS 驼峰命名：

| CSS 属性 | JS 访问 |
|----------|---------|
| `background-color` | `style.backgroundColor` |
| `font-size` | `style.fontSize` |

## 常用 Panel 方法

| 方法 | 说明 |
|------|------|
| `panel.FindChildInLayoutFile(id)` | 按 ID 查找子面板 |
| `panel.SetHasClass(class, bool)` | 添加/移除 CSS 类 |
| `panel.SwitchClass(slot, class)` | 切换属性槽位的类 |
| `panel.GetAttributeInt(name, default)` | 读取整数属性 |
| `$.Schedule(delay, callback)` | 延迟执行回调 |
| `GameUI.CustomUIConfig()` | 获取全局 UI 配置对象 |

```javascript
// 查找子面板
var child = panel.FindChildInLayoutFile("ChildID");

// 切换 CSS 类
$("#Panel").SetHasClass("Visible", true);
$("#Panel").SwitchClass("Difficulty", "Difficulty3");

// 读取自定义属性
var entIndex = $("#Container").GetAttributeInt("ent_index", -1);

// 延迟执行（5 秒后隐藏面板）
$.Schedule(5.0, function() { $("#Panel").SetHasClass("Visible", false); });

// 全局配置（在 manifest 中设置，各面板共享）
GameUI.CustomUIConfig().team_colors = {};
```

## 重载行为

面板重载时，关联的 JS 会重新执行。注意事项：

- 通过 `GameEvents.Subscribe` 注册的回调在面板重载后自动失效，可安全重新注册
- 动态创建的面板需检查是否已存在，避免重载后重复创建

```javascript
var existing = $("#DynamicPanel");
if (!existing) {
    var panel = $.CreatePanel("Panel", $.GetContextPanel(), "DynamicPanel");
    panel.BLoadLayout("file://{resources}/layout/custom_game/dynamic.xml", false, false);
}
```

## 游戏 API

### 游戏事件

```javascript
function OnFoo(data) { $.Msg("foo_event: ", data); }
var handle = GameEvents.Subscribe("foo_event_name", OnFoo);
GameEvents.Unsubscribe(handle);
```

### 网络表

服务端到客户端的持久状态通信。详见 `nettables.md`。

### 游戏对象访问

通过 `Entities.*`、`Players.*`、`Buffs.*`、`Abilities.*`、`Items.*`、`Game.*` 命名空间访问。详见 `game-objects.md`。

## 约束与建议

- 使用 `"use strict"` 模式
- 使用 `===` 而非 `==` 进行相等比较
- 注意闭包变量捕获：`for` 循环中的 `var` 变量按引用捕获，需使用 IIFE 或 `let` 避免陷阱

```javascript
// 错误：所有闭包共享同一个 i，最终都输出 5
var closures = [];
for (var i = 0; i < 5; i++) {
    closures[i] = function() { $.Msg("i = ", i); };
}

// 正确：通过 IIFE 捕获每次循环的值
for (var i = 0; i < 5; i++) {
    closures[i] = (function(j) { return function() { $.Msg("i = ", j); }; })(i);
}
```
