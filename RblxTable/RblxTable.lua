--[[
	Author  :  Mubinet (@mubinets | 5220307661)
	Date    :  4/27/2024
	Version :  1.0.0a

    -- RblxTable
    * RblxTable is an open source module designed to be similar to Table (which somewhat visually exists but has fewer features anyway) on Roblox.
    * With it being the open source module, anyone is free to contribute to the module!
    * Do not edit the information about the author, and date. You may edit the version if you modify the module.
--]]

--!strict

------------ [[ ROBLOX SERVICES ]] ------------


------------ [[ USER SERVICES ]] ------------


------------ [[ USER MODULE ]] ------------
local RblxTable = {}
RblxTable.__index = RblxTable

local RblxTableInstance = {}

------------ [[ USER TYPES ]] ------------
export type RblxTable<ValueType> = {
    GetValueAtKey         : (any?, key: string)                 -> (),
    RemoveElement         : (any?, key: string)                 -> (),
    GetElementsCount      : (any?)                              -> number,
    ToTable               : (any?)                              -> { [string]: ValueType },
    Where                 : (any?, (ValueType) -> boolean)      -> ValueType?,
    ForOrdered            : (any?, string, (ValueType) -> ())            -> (),
    _table                : {}                         
}

local rblxTableMemoryList = {} :: any

------------ [[ MAIN ]] ------------
--[[
    Creates new RblxTable with optional inital table.

    @param    ...rblxTableMemoryList[self]    :   { [KeyType]: ValueType }   |   The inital table to be used. (optional)
]]
function RblxTable.new<ValueType>() : RblxTable<ValueType>
    local newRblxTableInstance = {} :: RblxTable<ValueType>
    rblxTableMemoryList[newRblxTableInstance] = nil

    ------------ [ Private Properties ] ------------
    local elementsCountCache : number | nil = nil

    ------------ [ Private Functions ] ------------
    local function manuallyCountElements(self) : number
        local totalElementCount : number = 0

        if (rblxTableMemoryList[self]) then
            -- Dynamically looping to count the element :sob:
            for elementKey, elementValue in pairs(rblxTableMemoryList[self]) do
                totalElementCount += 1
            end
        end

        return totalElementCount
    end

    ------------ [ Metatable Functions ] ------------
    RblxTableInstance.__index = function(self : RblxTable<ValueType>, table : any, key : string): ValueType
        if (rblxTableMemoryList[self]) then
            return rblxTableMemoryList[self][key]
        else
            error("RblxTable Error: The table whose value is attempted to be accessed is nil.")
        end
    end
    
    RblxTableInstance.__newindex = function(self : RblxTable<ValueType>, key : string, value : ValueType) : ()
        if (rblxTableMemoryList[self]) then
            if (value ~= nil) then
                elementsCountCache = nil
                rawset(rblxTableMemoryList[self], key, value)
            end
        else
            error("RblxTable Error: The table whose value is attempted to be accessed is nil.")
        end
    end

    ------------ [ Functions ] ------------
    --[[
        Returns the actual table with the list of all elements within it.
    ]]
    function newRblxTableInstance:ToTable(): { [string] : ValueType }
        if (rblxTableMemoryList[self]) then
            return rblxTableMemoryList[self]
        else
            error("RblxTable Error: The table whose value is attempted to be accessed is nil.")
        end
    end

    --[[
        Returns the value at given key.

        @param  index   :   any     |   The index number used as the position of the array to retrieve the value
    ]]
    function newRblxTableInstance:GetValueAtKey(key : string) : ValueType
        if (rblxTableMemoryList[self]) then
            return rblxTableMemoryList[self][key]
        else
            error("RblxTable Error: The table whose value is attempted to be accessed is nil.")
        end
    end

     --[[
        Removes the element at given key.

        @param  index   :   any     |   The index number used as the position of the array to retrieve the value
    ]]
    function newRblxTableInstance:RemoveElement(key : string) : ()
        if (rblxTableMemoryList[self]) then
            rblxTableMemoryList[self][key] = nil
            elementsCountCache = nil
        else
            error("RblxTable Error: The table whose value is attempted to be accessed is nil.")
        end
    end
    
    --[[
        Returns the number of elements in the array.

        @return  number
    ]]
    function newRblxTableInstance:GetElementsCount() : number
        -- Immediately return the same element count if it has already been cached.
        -- We don't want to do some expensive looping you know right?
        if (elementsCountCache and elementsCountCache >= 0) then
            return elementsCountCache
        end

        return manuallyCountElements(self)
    end

    --[[
        Returns the specific element with matching predicate in the array.

        @return  ValueType
    ]]
    function newRblxTableInstance:Where(predicateFunction: (ValueType) -> boolean) : ValueType?
        if (rblxTableMemoryList[self]) then
            for index, element in pairs(rblxTableMemoryList[self]) do
                if (predicateFunction(element)) then
                    return element
                end
            end
        else
            error("RblxTable Error: The table whose value is attempted to be accessed is nil.")
        end

        return nil
    end

    --[[
        Iterates through the table based in the order by specified property
    ]]
    function newRblxTableInstance:ForOrdered(properyName : string, callback : (ValueType) -> ()) : ()
        if (rblxTableMemoryList[self]) then
            local orderedIndex : number = 0

            for key, subtable in pairs(rblxTableMemoryList[self]) do
                if (subtable[properyName]) then
                    orderedIndex += 1
                else
                    error("RblxTable Error: Invaild property name in ForOrdered method.")
                end
            end

            for indexCount = 1, orderedIndex, 1 do
                for key, subtable in pairs(rblxTableMemoryList[self]) do
                    if (subtable[properyName] == indexCount) then
                        callback(subtable)
                    end
                end
            end
        else
            error("RblxTable Error: The table whose value is attempted to be accessed is nil.")
        end

        return nil
    end

    ------------ [ Setup ] ------------

    return setmetatable(newRblxTableInstance, RblxTableInstance) :: any
end

function RblxTable.setTable(table: any, rblxTable : RblxTable<any>)
    rblxTableMemoryList[rblxTable] = table
end

return RblxTable