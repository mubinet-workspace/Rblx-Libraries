--	Author  :  Mubinet (@mubinets | 5220307661)
--	Date    :  9/14/2024
--	Version :  1.2.0a

--!strict

------------ [[ ROBLOX SERVICES ]] ------------
local RunService = game:GetService("RunService")

------------ [[ USER MODULE ]] ------------
local RblxTimer = {} :: RblxTimer

------------ [[ USER TYPES ]] ------------
export type TimerStatus = "Pending" | "Running" | "Complete" | "Stopped" | "Paused"

--[[
    An object that provides information about the result of the Timer object.
]]
export type TimerState = {
    --[[
        The value that is provided if the Timer object is either paused or stopped in time.
    ]]
	remainingTime   :  number,

    --[[
        The status value describing the current state of the Timer object.
    ]]
	timerStatus : TimerStatus
}

--[[
    An object representing the date time.
]]
export type RblxDateTime = {
    --[[
        The value representing the year.
    ]]
    year             :     number,
    
    --[[
        The value representing the amount of months in number
    ]]
    month            :     number,

    --[[
        The value representing the amount of days in number
    ]]
    day              :     number,

    --[[
        The value representing the amount of hours of the day in number
    ]]
    hour             :     number,

    --[[
        The value representing the amount of minutes in number
    ]]
    minute           :     number,

    --[[
        The value representing the amount of seconds in number
    ]]
    second           :     number,

    --[[
        The value representing the amount of milliseconds in number
    ]]
    millisecond      :     number,

    --[[
        Generates a string from the DateTime value interpreted as Universal Coordinated Time (UTC) and a format string.
    ]]
    formatDateTime   : (any, string, string) -> string
}

--[[
    An object representing the time.
]] 
export type Timer = {
    --[[
        The inital value in seconds in the construction of the Timer object.
    ]]
	initalTime             : number?,

    --[[
        The event which fires on the completion of the timer, an TimerState object which provides information about the result will be given.
    ]]
	onFinished             : RBXScriptSignal<TimerState>,

    --[[
        The event which fires every interval of specified time. Defaults to 1 second internal if not specified
    ]]
	onElapsed              : RBXScriptSignal<TimerState>,

    --[[
        The event which fires when the Timer object has been stopped
    ]]
    onStopped              : RBXScriptSignal<TimerState>,

    
    --[[
        The event which fires when the Timer object has been paused
    ]]
    onPaused              : RBXScriptSignal<TimerState>,

    --[[
        The event which fires when the Timer object has been resumed
    ]]
    onResumed              : RBXScriptSignal<TimerState>,

    --[[
        The event which fires when the Timer object has started
    ]]
    onStarted              : RBXScriptSignal<TimerState>,

    --[[
        Returns the remaining time of the Timer object.
    ]]
	getRemainingTime       : (any) -> DateTime,

    --[[
        Stops the Timer object if not stopped already.
    ]]
	stop                   : (any) -> TimerState,

    --[[
        Resumes the Timer object if it has been paused. 
    ]]
	resume                 : (any) -> TimerState,

    --[[
        Pauses the Timer object if not paused already.
    ]]
	pause                  : (any) -> TimerState,

    --[[
        Starts the Timer object if not stopped already.
    ]]
	start                  : (any) -> TimerState,

    --[[
        Set the duration of the timer.
    ]]
    setDuration            : (any, number) -> (),

    --[[
        Clean up the object.
    ]]
    destroy         : (any) -> (),

    --[[
        Return a boolean, indicating whether the timer is currently running or not.
    ]]
    isRunning       : boolean
}

--[[
    An object that provides information about the current clock time from the specific clock object.
]]
export type ClockRecord = {
    --[[
        A value which has the current time in seconds since the Unix epoch (1 January 1970, 00:00:00) under current UTC time.
    ]]
    clockTime       :   number,

    --[[
        A value which has the current date in UTC time.
    ]]
    clockDate       :   RblxDateTime
}

--[[
    An object representing the clock.
]]
export type Clock = {
    --[[
        The event which fires every interval of specified time. Defaults to 1 second internal if not specified
    ]]
	onElapsed              : RBXScriptSignal<ClockRecord>,

    --[[
        Returns the current time in seconds since the Unix epoch (1 January 1970, 00:00:00) under current UTC time.
    ]]
    getClockTime           : () -> number,

    --[[
        Returns the current time formatted in date in UTC time.
    ]]
    getClockDate           : () -> RblxDateTime,

    --[[
        Clean up the object.
    ]]
    destroy         : (any) -> ()
}

--[[
    A user service for working with a timer object. 
]] 
export type RblxTimer = {
	createTimer  :   (number, number?)  ->  Timer,
    createClock  :   (number)           ->  Clock,
}

------------ [[ MAIN ]] ------------
local function createRblxDateTime(seconds : number) : RblxDateTime
    local rblxDateTime          = {}                                    :: RblxDateTime
    local dateTimeFromSeconds   = DateTime.fromUnixTimestamp(seconds)   :: DateTime
    local dateTime              = dateTimeFromSeconds:ToUniversalTime() :: any

    rblxDateTime.year   = dateTime.Year
    rblxDateTime.month  = dateTime.Month
    rblxDateTime.day    = dateTime.Day
    rblxDateTime.hour   = dateTime.Hour
    rblxDateTime.minute = dateTime.Minute
    rblxDateTime.second = dateTime.Second
    rblxDateTime.millisecond = dateTime.Millisecond

    rblxDateTime.formatDateTime = function(self : any, format : string, locale : string) : string
        return dateTimeFromSeconds:FormatUniversalTime(format, locale)
    end

    return rblxDateTime
end

--[[
    Creates a new object Timer with specified amount of time and optional interval in seconds.
]]
function RblxTimer.createTimer(seconds : number?, interval: number?) : Timer

	-- Definitions
	local newTimerObject             = {}                            :: Timer
	local newElaspedBindableEvent    = Instance.new("BindableEvent") :: BindableEvent
	local newFinishedBindableEvent   = Instance.new("BindableEvent") :: BindableEvent
    local newStoppedBindableEvent    = Instance.new("BindableEvent") :: BindableEvent
    local newResumedBindableEvent    = Instance.new("BindableEvent") :: BindableEvent
    local newPausedBindableEvent     = Instance.new("BindableEvent") :: BindableEvent
    local newStartedBindableEvent    = Instance.new("BindableEvent") :: BindableEvent

	newTimerObject.onElapsed    = newElaspedBindableEvent.Event
	newTimerObject.onFinished   = newFinishedBindableEvent.Event
    newTimerObject.onStarted    = newStartedBindableEvent.Event
    newTimerObject.onPaused     = newPausedBindableEvent.Event
    newTimerObject.onStopped    = newStoppedBindableEvent.Event
    newTimerObject.onResumed    = newResumedBindableEvent.Event

	-- Object Private Constants
	local DEFAULT_INTERVAL = 1 :: number

	-- Object Private Properties
	local _initalTime        = seconds                            :: number
    local _updatedTime       = seconds                            :: number
	local _currentTime       = seconds                            :: number
	local _timeElapsed       = 0                                  :: number
	local _interval          = interval or DEFAULT_INTERVAL       :: number
	local _currentTimerState = {}                                 :: TimerState
	local _isTicking         = false                              :: boolean
    local _stopTicking       = false                              :: boolean

	-- Object Private Methods
    --[[
        A main private function for the regular operation of the timer.
    ]]
	local function _tick()
        task.spawn(function()
            local heartbeatConnection : RBXScriptConnection do
                heartbeatConnection  = RunService.Heartbeat:Connect(function(deltatime : number)                    
                    if not (_isTicking) then
                        if (newTimerObject.isRunning) then newTimerObject.isRunning = false end
                        return
                    end
                    
                    -- Stop the timer when the ticking has been disabled.
                    if (_stopTicking) then
                        newTimerObject.isRunning = false
                        heartbeatConnection:Disconnect()
                        
                        return
                    end

                    _currentTime -= deltatime
                    _timeElapsed += deltatime
                    
                    if (_currentTime <= 0) then
                        _currentTimerState.remainingTime = 0
                        _currentTimerState.timerStatus   = "Complete"
                        _isTicking                       = false
                        newTimerObject.isRunning         = false
                        
                        newElaspedBindableEvent:Fire(_currentTimerState)
                        newFinishedBindableEvent:Fire(_currentTimerState)
                        heartbeatConnection:Disconnect()
                    end
        
                    if (_timeElapsed >= _interval) then
                        _currentTimerState.remainingTime = math.round(_currentTime)
                        newElaspedBindableEvent:Fire(_currentTimerState)
    
                        _timeElapsed = 0
                    end
                end)
            end
        end)
	end

    --[[
        A private function which toggles either enabling the ticking of the timer or disabling the ticking of the timer.
    ]]
	local function _toggleTick(tickingToggle : boolean)
		if (_isTicking ~= tickingToggle) then
            _isTicking = tickingToggle

            if (_isTicking) and not (_currentTime) then error("[RBLX EXCEPTION]: Attempted to start the timer without any set duration.") end
            if (tickingToggle == true) then
                newTimerObject.isRunning = true
                _tick()
            else
                newTimerObject.isRunning = false
            end
		end
	end

	-- Object Private Properties Initalization
	_currentTimerState.remainingTime = _currentTime
	_currentTimerState.timerStatus   = "Pending"

	-- Object Initalization
	newTimerObject.initalTime = seconds
    newTimerObject.isRunning  = false

	-- Methods Definition
	newTimerObject.getRemainingTime = function() : DateTime
		return DateTime.fromUnixTimestamp(_currentTime)
	end

	newTimerObject.start = function() : TimerState
		if (_currentTimerState.timerStatus == "Pending") or (_currentTimerState.timerStatus == "Complete") or (_currentTimerState.timerStatus == "Stopped") then
            _currentTime = _initalTime or _updatedTime
			_currentTimerState.remainingTime = _initalTime or _updatedTime
			_currentTimerState.timerStatus = "Running"

            _toggleTick(true)

            newStartedBindableEvent:Fire(_currentTimerState)
            newElaspedBindableEvent:Fire(_currentTimerState)

			return _currentTimerState
		end

		return _currentTimerState
	end

	newTimerObject.resume = function() : TimerState
		if (_currentTimerState.timerStatus == "Paused") then
			_toggleTick(true)

			_currentTimerState.timerStatus = "Running"
            newResumedBindableEvent:Fire(_currentTimerState)

			return _currentTimerState
		end

		return _currentTimerState
	end

	newTimerObject.pause = function() : TimerState
		if (_currentTimerState.timerStatus == "Running") then
			_toggleTick(false)

			_currentTimerState.timerStatus = "Paused"
            newPausedBindableEvent:Fire(_currentTimerState)

			return _currentTimerState
		end

		return _currentTimerState
	end

	newTimerObject.stop = function() : TimerState
		if (_currentTimerState.timerStatus == "Running") or (_currentTimerState.timerStatus == "Paused") then
			_toggleTick(false)

			_currentTimerState.timerStatus = "Stopped"
            newStoppedBindableEvent:Fire(_currentTimerState)

			return _currentTimerState
		end

		return _currentTimerState
	end

    newTimerObject.setDuration = function(self, newDuration : number) : ()
        _updatedTime = newDuration
    end

    newTimerObject.destroy = function() : ()
        newElaspedBindableEvent:Destroy()
        newElaspedBindableEvent:Destroy()
	    newFinishedBindableEvent:Destroy()
        newStoppedBindableEvent:Destroy()
        newResumedBindableEvent:Destroy()
        newPausedBindableEvent:Destroy()
        newStartedBindableEvent:Destroy()

        _stopTicking = true
    end

	return newTimerObject
end

--[[
    Creates a new object Clock with specfified amount of interval in seconds.
]]
function RblxTimer.createClock(interval : number) : Clock
    -- Definitions
	local newClockObject             = {}                            :: Clock
	local newElaspedBindableEvent    = Instance.new("BindableEvent") :: BindableEvent

	newClockObject.onElapsed         = newElaspedBindableEvent.Event

    -- Object Private Constants
	local DEFAULT_INTERVAL = 1 :: number

    -- Object Private Properties
    local _clockRunTime      = os.time()                          :: number
	local _timeElapsed       = 0                                  :: number
	local _interval          = interval or DEFAULT_INTERVAL       :: number
    local _stopTicking       = false                              :: boolean

    local function clockTick()
        task.spawn(function()
            local heartbeatConnection : RBXScriptConnection do
                    heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime : number)
                    if (_stopTicking) then
                        heartbeatConnection:Disconnect()
                        heartbeatConnection = nil :: any

                        return
                    end

                    _clockRunTime = os.time()
                    _timeElapsed += deltaTime

                    if (_timeElapsed >= _interval) then
                        local clockRecord = {} :: ClockRecord
                        clockRecord.clockTime = _clockRunTime
                        clockRecord.clockDate = createRblxDateTime(_clockRunTime)

                        newElaspedBindableEvent:Fire(clockRecord)
                        _timeElapsed = 0
                    end
                end)
            end
        end)
    end

    newClockObject.getClockTime = function()           : number
        return _clockRunTime
    end

    newClockObject.getClockDate = function()           : RblxDateTime
        return createRblxDateTime(_clockRunTime)
    end

    newClockObject.destroy = function()                : ()
        _stopTicking = true

        newElaspedBindableEvent:Destroy()
    end

    clockTick()

    return newClockObject
end

return RblxTimer