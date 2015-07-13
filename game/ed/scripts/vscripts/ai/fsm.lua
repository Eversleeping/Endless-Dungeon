-- ============================================
-- [[ 有限状态机 for DOTA2 ]]
-- Author: XavierCHN
--
-- Email: Xavier_CHN@live.com
-- Version: 1.0 July 10, 2015
-- ============================================
--[[
        有限状态机中的每一个状态都使用四个量来声明：
        旧状态oldState，事件event，新状态newState，动作action
        使用一个table来储存所有的状态
        statesTable = {
            {state1, event1, state2, action1},
            {state1, event2, state3, action2},
            {state1, event3, state1, action3}
            ...
        }
        其中，state与event不能为nil，action最好不为nil

        范例：
        在你的ai_creature.lua中
        ---------------------------------------------------------------------
        local FSM = require "fsm"
        function action1() print("Performing action 1") end
        function action2() print("Performing action 2") end

        local statesTable = {
            {"state1", "event1", "state2", action1}, -- 在状态1碰到事件1则切换到状态2
            {"state2", "event2", "state3", action2}, -- 在状态2碰到事件2则切换到状态3
            {"*"          , "event3", "state2", action1}, -- 在任意状态碰到事件3则切换到状态2
            {"*"          , "*",           , "state4", action2}  -- 在碰到没有写明的状况的时候，切换到状态4
        }
        -- 实际使用的话那就需要大家举一反三了

        thisEntity.fsm = FSM.new(statesTable) -- 初始化状态机
        thisEntity.fsm:set("state2") -- 设置状态，切换为state2
        thisEntity.fsm:fire("event2") -- 触发事件state2.event2，切换至state3
        thisEntity.fsm:setlock(true) -- 锁定状态
        thisEntity.fsm:fire("event3") -- 由于锁定，不会有响应
        thisEntity.fsm:setlock(false) -- 解除锁定
        thisEntity.fsm:fire("event3") -- 响应state3.event3，未找到，*.event3有效，切换state2，并作action1
]]

if FSM == nil then FSM = class({}) end

--[ [  常量  ] ]
SILENCE = false
SEPERATOR = '.'
ANY = '*'
ANY_STATE = ANY  ..  SEPERATOR
ANY_EVENT = SEPERATOR  ..  ANY
UNKNOWN = ANY_STATE  ..  ANY

--[ [  初始化  ] ]
function FSM:new( e, t )
    local this = {}

    this.state = t[ 1 ][ 1 ]  -- 当前状态，默认状态机第一个
    this.stt = {} -- 状态转换表
    this.silence = SILENCE -- silence的话则不打印消息
    this.lock = false -- 锁定状态
    this.srt = "" -- 临时变量
    this.ent = e -- DOTA2 设置FSM 实体实例

    -- 获取当前状态
    function this:get() return this.state end
    -- 设置不打印消息
    function this:setsilence(s) this.silence = s end
    -- 设置状态锁定
    function this:setlock(l) this.lock = l end
    -- 设置当前状态
    function this:set(s)
        if this.lock then
            this:telllock()
            return
        end
        this:tellstatechange(this.state, s)
        this.state = s
    end

    -- 无此状态的action
    function this:exception()
        this:tell("xFSM: unknown combination"  ..  this.str)
        return false
    end

    -- 打印消息相关
     function this:tell( msg )
        if this.silence == false then
            print( msg )
        end
    end
    function this:telllock()
        this:tell("xFSM: [STATE IS LOCKED!] ")
    end
    function this:tellstatechange( o, n)
        this:tell("xFSM: [State Changed] " .. o .. " ==> " .. n)
    end

    -- 方法 ： 事件触发 - 事件触发之后，将状态设置为新状态
    function this:fire(event)
        -- 处理锁定状态
        if this.lock == true then this:telllock() return end

        -- 获取newState与action
        local act = this.stt[ this.state .. SEPERATOR .. event ] -- 当前状态，有对应事件，则切换到对应新状态
        if act == nil then
            act = this.stt[ ANY_STATE .. event ] -- 有通用事件，则切换到对应新状态
            if act == nil then
                act = this.stt[this.state .. ANY_EVENT] -- 当前状态对于任何事件均切换到新状态，则切换
                if act == nil then
                    act = this.stt[UNKNOWN]
                    this.str = this.state .. SEPERATOR .. event -- 状态与事件无对应，则返回未知，状态切换到默认状态
                end
            end
        end
        local newState = act.newState
        this:set(newState)
        if act.action and type(act.action)=="function" then act.action( ent ) end
    end

    -- 方法 ：添加状态组
    function this:add(t)
        for k,v in ipairs(t) do
            local oldState, event, newState, action = v[1], v[2], v[3], v[4]
            if oldState and event then
                this.stt[oldState .. SEPERATOR .. event] = {newState = newState, action = action}
            else
                this:tell("xFSM:[FAIL] add state failed at table indexed " .. k)
            end
        end
    end

    -- 方法 ： 删除状态组
    function this:delete(t)
        for _,v in ipairs(t) do
            local oldState, event = v[1], v[2]
            if oldState == ANY and event == ANY then
                this:tell( "xFSM: you should not delete the this:exception handler" )
            else
                this.stt[oldState .. SEPERATOR .. event] = nil
            end
        end
    end

    -- 碰到未知的状态和事件组合，切换到初始状态并打印消息
    -- 这个UNKNOWN也可以在t中重写
    this.stt[UNKNOWN] = {newState = state, action = this.exception}

    -- 把所有的状态设定加进去
    this:add(t)

    -- 在fsm中启动循环
    e:SetContextThink(DoUniqueString("unit_fsm_think"), function()
        if (not IsValidEntity(e)) or (not e:IsAlive()) then
            return nil
        else
            return e:FSMThink( this , e )
        end
    end, 0)

    return this
end

return FSM
