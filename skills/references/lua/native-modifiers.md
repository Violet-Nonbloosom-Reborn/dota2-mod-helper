# 原生修饰器应用技巧

引擎内置的修饰器可直接通过 `AddNewModifier` 使用，无需自定义实现。

## modifier_kill

**作用**：持续时间结束后单位死亡。

**使用场景**：
- 控制召唤单位的存在时间
- 限制支配单位的持续时间
- 临时单位的自动清理

**代码示例**：

```lua
-- 召唤单位 10 秒后死亡
unit:AddNewModifier(caster, nil, "modifier_kill", { duration = 10 })

-- 支配单位 30 秒后死亡
dominated_unit:AddNewModifier(caster, nil, "modifier_kill", { duration = 30 })
```

**注意事项**：
- 死亡效果在持续时间结束后立即触发
- 无法被驱散（除非使用 `modifier_purge` 相关机制）
- 适用于需要自动清理的临时单位

---

## 属性书标记修饰器

以下修饰器仅用于标记单位已使用属性书，**不提供实际属性加成**。属性提升应由属性书物品本身或其派生效果实现。

### modifier_book_of_strength

**作用**：标记单位已使用力量属性书。

**代码示例**：

```lua
-- 标记已使用力量书（无实际加成）
hero:AddNewModifier(caster, nil, "modifier_book_of_strength", {})
```

### modifier_book_of_agility

**作用**：标记单位已使用敏捷属性书。

**代码示例**：

```lua
-- 标记已使用敏捷书（无实际加成）
hero:AddNewModifier(caster, nil, "modifier_book_of_agility", {})
```

### modifier_book_of_intelligence

**作用**：标记单位已使用智力属性书。

**代码示例**：

```lua
-- 标记已使用智力书（无实际加成）
hero:AddNewModifier(caster, nil, "modifier_book_of_intelligence", {})
```

**使用场景**：
- 防止重复使用同一属性书
- 追踪属性书使用状态
- 作为条件判断依据（如"已使用所有属性书"成就）

**注意事项**：
- 这些修饰器仅提供标记功能
- 实际属性提升需要在物品 `OnSpellStart` 中手动实现
- 未指定 `duration` 时默认为 -1（永久持续）

---

## 扩展指南

发现新的实用原生修饰器时，按以下格式添加：

```markdown
## [修饰器名称]

**作用**：[一句话描述]

**使用场景**：
- [场景 1]
- [场景 2]

**代码示例**：

```lua
[代码示例]
```

**注意事项**：
- [注意点]
```
