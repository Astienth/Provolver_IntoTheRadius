--[[ Default values sent "intensity": 1, "duration": 1 "offsetAngleX": 180, "offsetY": 0
Message format : string "method,kickpower,rumblepower,rumbleDuration"
params: string method, Byte kickPower, Byte rumblePower, float rumbleDuration
values : 
	method: kick,rumble,shoot
	kickpower: 0 to 255
	rumblepower: 0 to 125 (one motor) 126 to 255 (two motors)
	rumbleduration: 100 equals one second / 0 means rumble never stops
]]--

local udpClient
local health = 100
local hand = "R"
local loopStarted = false

function CreateUDPClient()
	local socket = require("socket")
	-- the address and port of the server
	local address, port = "127.0.0.1", 5005
	udpClient = assert(socket.udp())
	udpClient:settimeout(1)
	assert(udpClient:setsockname("*",5005))
	assert(udpClient:setpeername(address, port))
	assert(udpClient:send("shoot,210,210,50"))
end

function RegisterHooks()
	--[[ Receive Damage ]]--
	RegisterHook("/Game/Blueprints/Player/AE_PlayerCharacter.AE_PlayerCharacter_C:ReceiveAnyDamage", function()
	    assert(udpClient:send("Impact"))
	end)
	--[[ Death ]]--
	RegisterHook("/Game/Blueprints/Player/AE_PlayerCharacter.AE_PlayerCharacter_C:Death", function()
	    assert(udpClient:send("Death"))
	end)
	--[[ Weapon in left hand ]]--
	RegisterHook("/Game/VR/Weapons/VRWeapon.VRWeapon_C:InpActEvt_GripLeft_K2Node_InputActionEvent_2", function()
	    hand = "L"
	end)
	--[[ Weapon in right hand ]]--
	RegisterHook("/Game/VR/Weapons/VRWeapon.VRWeapon_C:InpActEvt_GripRight_K2Node_InputActionEvent_0", function()
	    hand = "R"
	end)
	--[[ Weapon Attack ]]--
	RegisterHook("/Game/VR/Weapons/VRWeapon.VRWeapon_C:PlayHapticForWeapon", function(Context)
	    assert(udpClient:send("RecoilVest_" .. hand))
	    assert(udpClient:send("RecoilArm_" .. hand))
	end)
	--[[ Weapon Shoot ]]--
	--[[
	RegisterHook("/Game/Blueprints/Weapon/BP_WeaponBase.BP_WeaponBase_C:EventWeapon_Attack", function(Context)
	    assert(udpClient:send("RecoilVest_" .. hand))
	    assert(udpClient:send("RecoilArm_" .. hand))
	end)
	]]--
	--[[ SoulModeEnabled ]]--
	RegisterHook("/Game/Blueprints/Weapon/BP_WeaponBase.BP_WeaponBase_C:SoulModeEnabled_Event_0", function()
	    assert(udpClient:send("Superpower_L"))
	    assert(udpClient:send("Superpower_R"))
	    assert(udpClient:send("Superpower"))
	end)
	--[[ SoulModeEnded ]]--
	RegisterHook("/Game/Blueprints/Weapon/BP_WeaponBase.BP_WeaponBase_C:SoulModeEnded", function()
	    assert(udpClient:send("SingularityFast"))
	end)
	--[[ LandAfterJump ]]--
	RegisterHook("/Game/Blueprints/Player/AE_PlayerCharacter.AE_PlayerCharacter_C:OnLanded", function()
	    assert(udpClient:send("LandAfterJump"))
	end)
	--[[ On jump ]]--
	RegisterHook("/Game/Blueprints/Player/AE_PlayerCharacter.AE_PlayerCharacter_C:InpActEvt_Jump_K2Node_InputActionEvent_29", function()
	    assert(udpClient:send("OnJump"))
	end)
	--[[ Healing ]]--
	RegisterHook("/Game/Blueprints/Player/AE_PlayerCharacter.AE_PlayerCharacter_C:ModifyHealth", function(Context)
	    newHealth = Context:get().PlayerHealth
	    if newHealth > health then
	    	assert(udpClient:send("Heal"))
	    end
	    health = newHealth		
		--[[ Low Health ]]--
		if not loopStarted then
			LoopAsync(1000, checkHealth)
			loopStarted = true
		end
	end)
end

function checkHealth()
	if health <= 0 then
		loopStarted = false
		return true
	end
	if health < 20 then
		assert(udpClient:send("HeartBeat"))
		return false
	end
	loopStarted = false
	return true
end

function checkPlayerSpawned()
	RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
		RegisterHooks()
	end)
end

CreateUDPClient()
checkPlayerSpawned()