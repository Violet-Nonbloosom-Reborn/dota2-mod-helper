--[[
    遭遇战派生类示例
    
    展示如何通过 class({}, {}, BaseClass) 继承基类
    
    关键点：
    1. 使用 require() 加载基类
    2. class({}, {}, CCavernEncounter) 第三个参数指定基类
    3. 重写方法时，可调用 CCavernEncounter.MethodName(self) 访问父类实现
]]

require("cavern_encounter")

-- 派生类定义：继承 CCavernEncounter
if encounter_combat_ghosts == nil then
    encounter_combat_ghosts = class({}, {}, CCavernEncounter)
end

-- 重写：返回遭遇战类型
function encounter_combat_ghosts:GetEncounterType()
    return CAVERN_ROOM_TYPE_MOB
end

-- 重写：返回可用等级
function encounter_combat_ghosts:GetEncounterLevels()
    return { 2, 3 }  -- 可在 2-3 级房间出现
end

-- 重写：启动逻辑
function encounter_combat_ghosts:Start()
    -- 调用父类方法（必须显式传递 self）
    CCavernEncounter.Start(self)
    
    -- 子类特定逻辑：生成幽灵
    self.nNumUnitsToSpawn = 15
    self:SpawnCreepsRandomlyInRoom("npc_dota_creature_ghost", self.nNumUnitsToSpawn, 0.63)
    
    return true
end
