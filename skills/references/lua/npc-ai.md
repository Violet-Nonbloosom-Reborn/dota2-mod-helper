# NPC AI 系统

## 概述

Dota 2 自定义游戏的 NPC AI 通过 **KV 配置 + Lua 脚本** 实现。只有需要自主行为的单位（怪物、敌人）才需要配置 AI，静态单位（宝箱、装饰物）无需配置。

## 何时需要 AI

| 单位类型 | 是否需要 AI | 说明 |
|---------|-----------|------|
| 怪物/敌人 | ✅ 需要 | 主动攻击、巡逻、技能释放 |
| 中立生物（原生刷新点） | ❌ 不需要 | 从原生中立生物刷新点刷新的单位自带 AI |
| 中立生物（手动生成） | ✅ 需要 | 通过 CreateUnitByName 手动生成的中立生物需要配置 AI |
| 宝箱 | ❌ 不需要 | 静态物体，通过修饰器交互 |
| 装饰物 | ❌ 不需要 | 纯视觉效果 |
| 召唤物 | ⚠️ 视情况 | 可继承主人 AI 或独立行为 |

## KV 配置

### 基础结构

```kv
"npc_dota_creature_ghost"
{
    // 指定 AI 脚本（无此字段则无 AI）
    "vscripts"    "units/ai/ai_generic.lua"
    
    // 基础属性
    "BaseClass"   "npc_dota_creature"
    "Model"       "models/creeps/neutral_creeps/ghost.vmdl"
    
    // AI 行为参数
    "Creature"
    {
        "DefaultState"    "Invade"
        
        "States"
        {
            "Invade"
            {
                "Name"          "Invade"
                "Aggression"    "100.0"    // 攻击性 (0-100)
                "Avoidance"     "0.0"      // 回避性
                "Support"       "0.0"      // 支援性
                "RoamDistance"  "150.0"    // 游荡距离
            }
        }
        
        "DisableClumpingBehavior"    "1"    // 禁用聚集行为
    }
}
```

### Creature 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `DefaultState` | string | 默认 AI 状态名称 |
| `States` | block | AI 状态定义 |
| `DisableClumpingBehavior` | boolean | 禁用单位聚集行为 |

### States 参数说明

| 参数 | 范围 | 说明 |
|------|------|------|
| `Aggression` | 0-100 | 攻击性，越高越主动攻击 |
| `Avoidance` | 0-100 | 回避性，越高越倾向躲避 |
| `Support` | 0-100 | 支援性，越高越倾向帮助队友 |
| `RoamDistance` | float | 游荡距离（单位：像素） |

## Lua 脚本

### 基本结构

```lua
-- units/ai/ai_generic.lua

function Spawn(entityKeyValues)
    -- 单位生成时自动调用
    -- 初始化 AI 逻辑
    thisEntity:SetContextThink("AI_Think", AIThink, 1.0)
end

function AIThink()
    -- 主 AI 循环
    -- 返回下次执行间隔（秒）
    
    if not thisEntity:IsAlive() then
        return nil  -- 停止 Think
    end
    
    -- AI 逻辑
    local target = FindTarget()
    if target then
        AttackTarget(target)
    end
    
    return 0.5  -- 每 0.5 秒执行一次
end
```

### 关键 API

```lua
-- 设置定时执行
thisEntity:SetContextThink(contextName, thinkFunction, interval)

-- 移动指令
ExecuteOrderFromTable({
    UnitIndex = thisEntity:entindex(),
    OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    Position = Vector(x, y, z),
})

-- 攻击指令
ExecuteOrderFromTable({
    UnitIndex = thisEntity:entindex(),
    OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
    TargetIndex = hTarget:entindex(),
})

-- 释放技能
ExecuteOrderFromTable({
    UnitIndex = thisEntity:entindex(),
    OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
    AbilityIndex = hAbility:entindex(),
    TargetIndex = hTarget:entindex(),
})
```

## 常用 AI 模式

### 1. 追踪并攻击最近敌人

```lua
function AIThink()
    local enemies = FindUnitsInRadius(
        thisEntity:GetTeamNumber(),
        thisEntity:GetAbsOrigin(),
        nil,
        800,  -- 搜索半径
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )
    
    if #enemies > 0 then
        ExecuteOrderFromTable({
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = enemies[1]:entindex(),
        })
    end
    
    return 0.5
end
```

### 2. 巡逻并返回出生点

```lua
function Spawn()
    thisEntity.vSpawnPos = thisEntity:GetAbsOrigin()
    thisEntity:SetContextThink("PatrolThink", PatrolThink, 1.0)
end

function PatrolThink()
    local distance = (thisEntity:GetAbsOrigin() - thisEntity.vSpawnPos):Length2D()
    
    if distance > 500 then
        -- 返回出生点
        ExecuteOrderFromTable({
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = thisEntity.vSpawnPos,
        })
    else
        -- 巡逻逻辑
        local patrolPos = thisEntity.vSpawnPos + RandomVector(200)
        ExecuteOrderFromTable({
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = patrolPos,
        })
    end
    
    return 2.0
end
```

### 3. 技能释放逻辑

```lua
function AIThink()
    -- 检查技能是否可用
    local hAbility = thisEntity:FindAbilityByName("creature_fireball")
    
    if hAbility and hAbility:IsFullyCastable() then
        local target = FindTarget()
        if target then
            ExecuteOrderFromTable({
                UnitIndex = thisEntity:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                AbilityIndex = hAbility:entindex(),
                TargetIndex = target:entindex(),
            })
            return 1.0  -- 释放后等待
        end
    end
    
    -- 普通攻击
    AttackNearestEnemy()
    return 0.5
end
```

## 注意事项

1. **性能优化**：Think 间隔不宜过短（建议 ≥ 0.2 秒），避免过多计算
2. **空值检查**：始终检查单位和目标是否有效
3. **状态管理**：使用 `thisEntity` 存储 AI 状态（如 `bReturning`、`vSpawnPos`）
