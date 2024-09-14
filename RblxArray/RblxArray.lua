--[[
	Author  :  Mubinet (@mubinets | 5220307661)
	Date    :  4/27/2024
	Version :  1.0.0a

    -- RblxArray
    * RblxArray is an open source module designed to be similar to Array (which does not visually exist anyway) on Roblox.
    * With it being the open source module, anyone is free to contribute to the module!
    * Do not edit the information about the author, and date. You may edit the version if you modify the module.
--]]

--!strict

------------ [[ ROBLOX SERVICES ]] ------------


------------ [[ USER SERVICES ]] ------------


------------ [[ USER MODULE ]] ------------
local RblxArray = {}
RblxArray.__index = RblxArray

local RblxArrayInstance = {}

------------ [[ USER TYPES ]] ------------


------------ [[ USER ENUMS ]] ------------


------------ [[ MAIN ]] ------------
--[[
    @param    ...items    :   any?   |   The items to be inserted in the new array. (optional)
--]]
function RblxArray.new(... : any)
    local items = { ... }

    local newRblxArrayInstance = {}

    ------------ [ Public Properties ] ------------


    ------------ [ Metatable Functions ] ------------
    RblxArrayInstance.__index = function(table, index)
        return items[index]
    end

    ------------ [ Functions ] ------------
    --[[
        @brief  Returns the value at given index.
        @param  index   :   any     |   The index number used as the position of the array to retrieve the value
    --]]
    function newRblxArrayInstance:GetValueAtIndex(index : number)
        return items[index]
    end

    --[[
        @brief  Returns boolean value, stating whether the array has fixed size.
        @param  index   :   any     |   The index number used as the position of the array to retrieve the value
    --]]
    function newRblxArrayInstance:IsFixedSize()
        if (#items > 0) then
            return true
        end

        return false
    end

    --[[
        @brief  Returns the number of elements in the array.
        @return  number
    --]]
    function newRblxArrayInstance:GetElementsCount()
        return #items
    end

    --[[
        @brief  Returns the last element of the array.
        @return  any
    --]]
    function newRblxArrayInstance:GetLastElement()
        return items[#items]
    end

    return setmetatable(newRblxArrayInstance, RblxArrayInstance)
end

return RblxArray