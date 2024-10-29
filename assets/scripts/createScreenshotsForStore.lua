
local totalTime = 0.0
local screenshotsTaken = 0

local minFishY = -100.0
local maxFishY = 100.0

local timeUntilNextStep = 0
local lastStepDistance = 0


function nextStep()
	lastStepDistance = getDistanceInMeters()
	print("createScreenshotsForStore - nextStep @", lastStepDistance)
end

function getDistanceSinceLastStep()
	local d = getDistanceInMeters()
	return d - lastStepDistance
end

function waitForDistance( distance, yieldDuration, timeout )
	local waitedTime = 0.0
	while getDistanceInMeters() < distance do
		coroutine.yield( yieldDuration )
		waitedTime = waitedTime + yieldDuration
		if waitedTime > timeout then
			return false
		end
	end
	return true
end

local takeScreenshots = coroutine.create(
	function()
		disableMusic()
		coroutine.yield( 5 )	-- wait until things have settled down
		waitForContinue()
		coroutine.yield( 0 )
		enableCheat("DONT_DIE")
--		requestScreenshot("%04d-store_shots-waiting_for_start")
		isWideScreen = getAspectRatio() > 2.0
		if isWideScreen then
			o = addOverlay("overlay-00-title", "Zoom")
		else
			o = addOverlay("overlay-00-title-square", "Zoom")
		end
		requestScreenshot("%04d-01-title")
		coroutine.yield( 0 )
		removeOverlay(o)
		addTouch( 0.0, 0.0 )
		-- STEP
		nextStep()
		coroutine.yield( 1 )
--		requestScreenshot("%04d-store_shots-started")
		-- STEP/SHOT
		coroutine.yield( 0 )
		o = addOverlay("overlay-02-help", "SE", 0.8)
		print( "Enabled overlay, got id: ", o )
		setFixedBackgroundOffset(96.0/128.0);	-- dark blue
		coroutine.yield( 0 )
		requestScreenshot("%04d-02-dark_blue")
		coroutine.yield( 0 )
		removeOverlay(o)
		-- STEP
		coroutine.yield( 1 )
		removePickups(false)
		gotoZone("8000_MarketingScreenshots")
		-- STEP
		minFishY = -50.0
		maxFishY = 150.0
		nextStep()
		waitForDistance( 50, 1, 10 )

		-- STEP
		minFishY = 1.0
		maxFishY = 30.0
		nextStep()
		setDistanceInMeters(100)
		setCoins(500)
		waitForDistance( 123, 0.1, 10 )
		y = getFishY()
		print( y )
		setFixedBackgroundOffset(16.0/128.0);	-- light blue
		coroutine.yield( 0 )
		requestScreenshot("%04d-03-coins")
		coroutine.yield( 0 )
--		OM_BREAKPOINT()

		-- STEP
		minFishY = 100.0
		maxFishY = 0.0
		nextStep()
		setDistanceInMeters(250)
		setCoins(1500)
		waitForDistance( 264, 0.1, 10 )
		o = addOverlay("overlay-01-explore", "SE", 0.8)
		print( "Enabled overlay, got id: ", o )
		setFixedBackgroundOffset(56.0/128.0);	-- medium blue
		coroutine.yield( 0 )
		requestScreenshot("%04d-04-more_coins")
		coroutine.yield( 0 )
		removeOverlay(o)
--		OM_BREAKPOINT()

		-- STEP
		coroutine.yield(0.5)
		clickUiButton("PauseResumeButton")

		--[[
		while true do
			print("taking screenshot")
			requestScreenshot("%04d-store_shots-timed")
			coroutine.yield( 5 )
		end
		--]]

		done(0)
	end
)

function initialize()
	print("createScreenshotsForStore - STARTED")
--	requestScreenshot("%04d-from_script")
	disableUserTouches()
end

function update(timeStep)
	totalTime = totalTime + timeStep

	if coroutine.status(takeScreenshots) ~= 'dead' and timeUntilNextStep ~= nil then
		if timeUntilNextStep > 0.0 then
			timeUntilNextStep = timeUntilNextStep - timeStep
		end

		if timeUntilNextStep <= 0.0 then
			rc, timeUntilNextStep = coroutine.resume(takeScreenshots)
		end
	else
		print( "script dead? or time nil", timeUntilNextStep )
	end
	local fishY = getFishY()
	if fishY > maxFishY then
		setFishYTarget( minFishY )
	elseif fishY < minFishY then
		setFishYTarget( maxFishY )
	end
end

