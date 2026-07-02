# Valve 工具函数

Dota 2 自定义游戏提供一系列 Lua 工具函数，位于 `utils/` 目录下。这些函数自动加载，可直接使用。

## 目录

- [vlua 库](#vlua-库)
- [类系统](#类系统)
- [数学与向量](#数学与向量)
- [VScript 扩展](#vscript-扩展)
- [实体扩展方法](#实体扩展方法)
- [调试工具](#调试工具)

---

## vlua 库

`vlua` 命名空间提供 Squirrel 兼容的表/字符串操作函数。

### 表操作

| 函数 | 说明 |
|------|------|
| `vlua.clear(t)` | 清空表 |
| `vlua.contains(t, k)` | 检查键是否存在 |
| `vlua.delete(t, k)` | 删除键，返回旧值 |
| `vlua.clone(t)` | 浅拷贝表 |
| `vlua.rawdelete(t, k)` | 同 `delete`（Squirrel 兼容） |
| `vlua.rawin(t, k)` | 同 `contains`（Squirrel 兼容） |
| `vlua.reverse(t)` | 原地反转数组 |
| `vlua.resize(t, size, fill)` | 调整数组大小，`fill` 为填充值 |
| `vlua.extend(t, ary)` | 将 `ary` 元素追加到 `t` |
| `vlua.tableadd(t1, t2)` | 将 `t2` 所有键值合并到 `t1` |

### 查找与切片

| 函数 | 说明 |
|------|------|
| `vlua.find(o, value)` | 表中查找值，返回索引；字符串中查找子串，返回位置 |
| `vlua.slice(o, start, end)` | 切片，支持负数索引 |
| `vlua.split(str, sep)` | 按分隔符拆分字符串 |

### 函数式

| 函数 | 说明 |
|------|------|
| `vlua.map(o, fn)` | 对每个元素应用函数，返回新表 |
| `vlua.reduce(o, fn)` | 累积归约 |

### 其他

| 函数 | 说明 |
|------|------|
| `vlua.compare(a, b)` | 三路比较，返回 -1/0/1 |
| `vlua.select(cond, true_val, false_val)` | 安全三元运算符 |

---

## 类系统

### class(def, statics, base)

创建类。实际使用中仅用单参数形式。引擎回调不可使用继承（第三个参数），应改用 `Merge()` 或 `vlua.tableadd()` 组合。详见 `ability-lua.md` 的"继承限制"章节。

```lua
MyClass = class({
    -- 默认属性
    health = 100,
    
    -- 构造函数
    constructor = function(self, name)
        self.name = name
    end,
    
    -- 方法
    GetName = function(self)
        return self.name
    end
})

-- 创建实例
local obj = MyClass("test")
```

### 辅助函数

| 函数 | 说明 |
|------|------|
| `instanceof(obj, class)` | 检查对象是否为类的实例 |
| `getclass(obj)` | 获取对象的类 |
| `getbase(class)` | 获取类的基类 |
| `isclass(obj)` | 检查是否为类 |

### 组合模式

`class()` 的第三个参数（继承）对引擎回调无效。只有不涉及 C++ 内核的部分才能通过继承产生效果，否则继承不可行。

**受影响**：修饰器（`modifier_*`）、技能（`ability_*`）、物品（`item_*`）的所有引擎回调函数。

**不受影响**：纯 Lua 逻辑（自定义方法、辅助函数等不直接被引擎调用的部分）。

必须使用 `Merge()` 或 `vlua.tableadd()` 将方法直接拷贝到类表中：

**区别**：
- `Merge(t1, t2)`：以第一个表的内容优先
- `vlua.tableadd(t1, t2)`：以第二个表的内容优先

```lua
-- 定义可复用模块
Serializable = {
    Serialize = function(self)
        return json.encode(self)
    end
}

Printable = {
    Print = function(self)
        print(self.name)
    end
}

-- 方式一：Merge()（第一个表优先）
MyClass = class(Merge(Merge({
    name = "default"
}, Serializable), Printable))

-- 方式二：vlua.tableadd()（第二个表优先）
local base = { name = "default" }
vlua.tableadd(base, Serializable)
vlua.tableadd(base, Printable)
MyClass = class(base)
```

---

## 数学与向量

### 数学函数

| 函数 | 说明 |
|------|------|
| `Deg2Rad(deg)` | 角度转弧度 |
| `Rad2Deg(rad)` | 弧度转角度 |
| `Clamp(val, min, max)` | 限制值在范围内 |
| `Lerp(t, a, b)` | 线性插值 |
| `RemapVal(v, a, b, c, d)` | 将 `[a,b]` 范围映射到 `[c,d]` |
| `RemapValClamped(v, a, b, c, d)` | 同上，但限制输入在 `[a,b]` |
| `min(x, y)` | 返回较小值 |
| `max(x, y)` | 返回较大值 |
| `abs(val)` | 绝对值 |
| `Merge(t1, t2)` | 合并两个表，返回新表 |

### 向量函数

| 函数 | 说明 |
|------|------|
| `VectorDistance(v1, v2)` | 两点距离 |
| `VectorDistanceSq(v1, v2)` | 两点距离平方（避免开方） |
| `VectorLerp(t, a, b)` | 向量线性插值 |
| `VectorIsZero(v)` | 检查是否为零向量 |

### 粒子控制点

`ParticleEffectControlPoints` 类用于传递粒子特效控制点：

```lua
local cp = ParticleEffectControlPoints()
cp.cp0_pos = origin
cp.cp0_norm = direction
```

---

## VScript 扩展

### 实体操作

| 函数 | 说明 |
|------|------|
| `UniqueString(prefix)` | 生成唯一字符串 |
| `EntFire(self, target, action, value, delay, activator)` | 通过名称触发实体输入 |
| `EntFireByHandle(self, target, action, value, delay, activator)` | 通过句柄触发实体输入 |

### 事件系统

| 函数 | 说明 |
|------|------|
| `__RegisterGameEventListeners(scope)` | 自动注册 `OnGameEvent_*` 函数 |
| `ConnectOutputs(table)` | 自动连接 `On*Output` 函数到实体输出 |
| `Dynamic_Wrap(mt, name)` | 动态包装函数，支持热重载 |

### 生成过滤器

| 函数 | 说明 |
|------|------|
| `RegisterSpawnGroupEntityFilter(name, func)` | 注册生成过滤器 |
| `RemoveSpawnGroupEntityFilter(name)` | 移除过滤器 |
| `FilterSpawnGroupEntities(self, name, tables)` | 执行过滤器 |
| `ClearSpawnGroupEntityFilters()` | 清空所有过滤器 |
| `GetSpawnGroupEntityFilterFunc(name)` | 获取过滤器函数 |
| `DumpSpawnGroupEntityFilters()` | 打印所有过滤器 |

---

## 实体扩展方法

以下方法挂载到 `CBaseEntity`，所有实体实例可用。

### SetThink(fnname, ...)

设置 Think 函数，支持函数名或函数对象。

```lua
-- 使用函数名
entity:SetThink("MyThink", 1.0)

-- 使用函数对象
entity:SetThink(function()
    print("thinking...")
    return 1.0  -- 返回间隔秒数
end, 1.0)
```

### StopThink(contextName)

停止指定名称的 Think。

```lua
entity:StopThink("MyThink")
```

### IsInstance(classOrClassName)

检查实体是否为指定类的实例。

```lua
if entity:IsInstance(CDOTA_BaseNPC) then
    print("is NPC")
end

if entity:IsInstance("CDOTA_BaseNPC_Hero") then
    print("is Hero")
end
```

---

## 调试工具

### 打印系列

以下函数经过充分测试，可安全使用。

| 函数 | 说明 |
|------|------|
| `DeepPrint(obj, prefix)` | 深度打印对象到控制台 |
| `DeepPrintTable(t, prefix, chaseMeta)` | 深度打印表，可选追踪元表 |
| `DeepToString(obj, prefix)` | 将对象转为字符串 |

```lua
DeepPrint(myTable)
DeepPrintTable(npc:GetAbilityList())
local str = DeepToString(complexObject)
```

### 监视与追踪

> **注意**：以下函数缺乏案例测试，谨慎使用。

| 函数 | 说明 |
|------|------|
| `ScriptDebugAddWatch(watch)` | 添加监视（函数或表达式字符串） |
| `ScriptDebugAddWatches(array)` | 批量添加监视 |
| `ScriptDebugRemoveWatch(watch)` | 移除监视 |
| `ScriptDebugRemoveWatches(array)` | 批量移除监视 |
| `ScriptDebugClearWatches()` | 清空所有监视 |
| `ScriptDebugAddWatchPattern(pattern)` | 按模式添加监视 |
| `ScriptDebugRemoveWatchPattern(pattern)` | 按模式移除监视 |
| `ScriptDebugAddTrace(target)` | 添加追踪目标 |
| `ScriptDebugRemoveTrace(target)` | 移除追踪 |
| `ScriptDebugClearTraces()` | 清空追踪 |
| `ScriptDebugTraceAll(bValue)` | 开启/关闭全部追踪 |
| `ScriptDebugTextPrint(text, color, isWatch)` | 打印调试文本 |
| `ScriptDebugTextTrace(text, color)` | 追踪模式打印 |
| `ScriptDebugAddTextFilter(filter)` | 添加文本过滤器 |
| `ScriptDebugRemoveTextFilter(filter)` | 移除文本过滤器 |
| `BeginScriptDebug()` | 开始调试钩子 |
| `EndScriptDebug()` | 结束调试钩子 |

---

来源: Valve Corporation - Dota 2 Workshop Tools
