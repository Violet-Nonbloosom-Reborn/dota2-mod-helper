# Lua 类继承示例

本目录包含 Dota 2 自定义游戏中 `class()` 继承的有效用法示例。

## 核心原则

`class()` 的继承（第三个参数）**仅适用于纯 Lua 逻辑**。

| 类型 | 是否可用继承 | 原因 |
|------|-------------|------|
| 纯 Lua 方法（`self:Method()`） | ✅ 可用 | Lua 元表链查找 |
| 引擎回调（`IsHidden()`、`OnSpellStart()` 等） | ❌ 不可用 | 引擎直接查表，不沿元表链 |

## 示例说明

### encounter-base.lua

遭遇战系统基类，定义可被重写的 Lua 方法：
- `GetEncounterType()` - 返回遭遇战类型
- `GetEncounterLevels()` - 返回可用等级列表
- `Start()` - 启动遭遇战
- `SpawnCreepsRandomlyInRoom()` - 生成单位
- `IsCleared()` - 检查是否清除

### encounter-ghosts.lua

派生类示例，展示：
1. `require()` 加载基类
2. `class({}, {}, CCavernEncounter)` 继承语法
3. 重写方法
4. `CCavernEncounter.Start(self)` 调用父类方法

## 不可用的场景

修饰器、技能、物品的引擎回调**不可使用继承**：

```lua
-- ❌ 错误：引擎不会识别继承的回调
modifier_base = class({
    IsHidden = function() return true end,
})

modifier_my_buff = class({}, {}, modifier_base)
-- 引擎调用 IsHidden() 时返回 false（默认值），而非 true

-- ✅ 正确：使用 Merge() 组合
modifier_my_buff = class(Merge({
    -- 其他方法
}, {
    IsHidden = function() return true end,
}))
```

详见 `ability-lua.md` 的"继承限制"章节。
