local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.RenpyRuntime = __TS__Class()
local RenpyRuntime = ____exports.RenpyRuntime
RenpyRuntime.name = "RenpyRuntime"
function RenpyRuntime.prototype.____constructor(self, script, stats)
    self.script = script
    self.stats = stats
    self.cursor = 0
    self.labels = {}
    do
        local index = 0
        while index < #script do
            local statement = script[index + 1]
            if statement.kind == "label" then
                self.labels[statement.name] = index + 1
            end
            index = index + 1
        end
    end
end
function RenpyRuntime.prototype.start(self, label)
    if label == nil then
        label = "start"
    end
    self:jump(label)
    return self:nextVisible()
end
function RenpyRuntime.prototype.resume(self, cursor)
    self.cursor = math.max(
        0,
        math.min(cursor, #self.script)
    )
    return self:nextVisible()
end
function RenpyRuntime.prototype.advance(self)
    return self:nextVisible()
end
function RenpyRuntime.prototype.choose(self, choice)
    for ____, effect in ipairs(choice.effects) do
        local ____self_stats_0, ____effect_key_1 = self.stats, effect.key
        ____self_stats_0[____effect_key_1] = ____self_stats_0[____effect_key_1] + effect.amount
    end
    self:jump(choice.jump)
    return self:nextVisible()
end
function RenpyRuntime.prototype.completeMiniGame(self, statement)
    self:jump(statement.fallback)
    return self:nextVisible()
end
function RenpyRuntime.prototype.getCursor(self)
    return self.cursor
end
function RenpyRuntime.prototype.jump(self, label)
    local target = self.labels[label]
    if target == nil then
        error("剧情标签不存在: " .. label)
    end
    self.cursor = target
end
function RenpyRuntime.prototype.nextVisible(self)
    while self.cursor < #self.script do
        do
            local __continue17
            repeat
                local statement = self.script[self.cursor + 1]
                self.cursor = self.cursor + 1
                if statement.kind == "label" then
                    __continue17 = true
                    break
                end
                if statement.kind == "jump" then
                    self:jump(statement.target)
                    __continue17 = true
                    break
                end
                if statement.kind == "condition" then
                    self:jump(self.stats[statement.key] >= statement.minimum and statement.pass or statement.fail)
                    __continue17 = true
                    break
                end
                return statement
            until true
            if not __continue17 then
                break
            end
        end
    end
    return nil
end
return ____exports
