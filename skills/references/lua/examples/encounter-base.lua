--[[
    遭遇战系统基类示例
    
    展示 class() 继承的有效用法：纯 Lua 逻辑继承
    
    注意：此模式适用于 Lua 侧调用的方法（如 self:GetEncounterType()），
    不适用于引擎回调（修饰器、技能、物品的回调函数）。
]]

-- 基类定义
if CCavernEncounter == nil then
    CCavernEncounter = class({})
end

-- 构造函数
function CCavernEncounter:constructor(hRoom)
    self.hRoom = hRoom
    self.bActive = false
    self.hCreeps = {}
end

-- 可被派生类重写的方法（纯 Lua 调用，继承有效）
function CCavernEncounter:GetEncounterType()
    return CAVERN_ROOM_TYPE_INVALID
end

function CCavernEncounter:GetEncounterLevels()
    return { 1 }
end

-- 基类方法：启动遭遇战
function CCavernEncounter:Start()
    self.bActive = true
    -- 基类初始化逻辑
end

-- 基类方法：生成单位
function CCavernEncounter:SpawnCreepsRandomlyInRoom(szUnitName, nCount, flExtent)
    for i = 1, nCount do
        local vSpawnPoint = self.hRoom.vRoomCenter + RandomVector(flExtent * 100)
        local hUnit = CreateUnitByName(szUnitName, vSpawnPoint, true, nil, nil, DOTA_TEAM_BADGUYS)
        table.insert(self.hCreeps, hUnit)
    end
end

-- 基类方法：检查是否清除
function CCavernEncounter:IsCleared()
    if not self.bActive then return false end
    
    for _, hUnit in pairs(self.hCreeps) do
        if hUnit:IsAlive() then
            return false
        end
    end
    return true
end
