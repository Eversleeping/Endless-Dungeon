--[[ utility_functions.lua ]]

---------------------------------------------------------------------------
-- Handle messages
---------------------------------------------------------------------------
function BroadcastMessage( sMessage, fDuration )
    local centerMessage = {
        message = sMessage,
        duration = fDuration
    }
    FireGameEvent( "show_center_message", centerMessage )
end

function PickRandomShuffle( reference_list, bucket )
    if ( #reference_list == 0 ) then
        return nil
    end

    if ( #bucket == 0 ) then
        -- ran out of options, refill the bucket from the reference
        for k, v in pairs(reference_list) do
            bucket[k] = v
        end
    end

    -- pick a value from the bucket and remove it
    local pick_index = RandomInt( 1, #bucket )
    local result = bucket[ pick_index ]
    table.remove( bucket, pick_index )
    return result
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ShuffledList( orig_list )
    local list = shallowcopy( orig_list )
    local result = {}
    local count = #list
    for i = 1, count do
        local pick = RandomInt( 1, #list )
        result[ #result + 1 ] = list[ pick ]
        table.remove( list, pick )
    end
    return result
end

function TableContains(t,val)
    for _, v in pairs(t) do
        if val == v then return true end
    end
    return false
end

function TableCount( t )
    local n = 0
    for _ in pairs( t ) do
        n = n + 1
    end
    return n
end

function TableFindKey( table, val )
    if table == nil then
        print( "nil" )
        return nil
    end

    for k, v in pairs( table ) do
        if v == val then
            return k
        end
    end
    return nil
end

function CountdownTimer()
    nCOUNTDOWNTIMER = nCOUNTDOWNTIMER - 1
    local t = nCOUNTDOWNTIMER
    --print( t )
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer =
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "countdown", broadcast_gametimer )
    if t <= 120 then
        CustomGameEventManager:Send_ServerToAllClients( "time_remaining", broadcast_gametimer )
    end
end

function SetTimer( cmdName, time )
    print( "Set the timer to: " .. time )
    nCOUNTDOWNTIMER = time
end

function Dem2Bin(d)
    local function modf(a,b)
        return math.floor(a/b), a%b
    end
    local r = ""
    local k = nil
    while d ~= 0 do
        d,k = modf(d,2)
        r = k .. r
    end
    return r
end

function IsFacing(ea, eb)
    local v = ea:GetForwardVector()
    local oa = ea:GetAbsOrigin()
    local ob = eb:GetAbsOrigin()
    local d = (ob - oa)
    return ( v.x * d.x + v.y * d.y ) > 0
end

function stringSplit(str, sep)
    if type(str) ~= 'string' or type(sep) ~= 'string' then
        return nil
    end
    local res_ary = {}
    local cur = nil
    for i = 1, #str do
        local ch = string.byte(str, i)
        local hit = false
        for j = 1, #sep do
            if ch == string.byte(sep, j) then
                hit = true
                break
            end
        end
        if hit then
            if cur then
                table.insert(res_ary, cur)
            end
            cur = nil
        elseif cur then
            cur = cur .. string.char(ch)
        else
            cur = string.char(ch)
        end
    end
    if cur then
        table.insert(res_ary, cur)
    end
    return res_ary
end
