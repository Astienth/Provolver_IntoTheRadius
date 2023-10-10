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
local hookIds = {}

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
	-- force unregister all hooks
	for k,v in pairs(hookIds) do
		UnregisterHook("/Game/ITR/BPs/Items/Weapons/BP_FirearmItem.BP_FirearmItem_C:OnBulletFired", k, v)
	end
	hookIds = {}

	--[[ BP_FirearmItem OnBulletFired ]]--
	local hook1, hook2 = RegisterHook("/Game/ITR/BPs/Items/Weapons/BP_FirearmItem.BP_FirearmItem_C:OnBulletFired", function(Context)
		currWeaponClass = Context:get():GetClass():GetFullName()
		handleWeaponClass(currWeaponClass)	
	end)
	hookIds[hook1] = hook2
end

function handleWeaponClass(currWeaponClass)	
	weaponName = split(currWeaponClass, "/")
	--print(weaponName[8])
	if weaponName[7] == "Secondary" then
		assert(udpClient:send("kick,255,0,0"))
		return
	end
	assert(udpClient:send(createStringMessageFromWeaponType(weaponName[8])))
end

function split(str, sep)
	assert(type(str) == 'string' and type(sep) == 'string', 'The arguments must be <string>')
	if sep == '' then return {str} end
	
	local res, from = {}, 1
	repeat
	  local pos = str:find(sep, from)
	  res[#res + 1] = str:sub(from, pos and pos - 1)
	  from = pos and pos + #sep
	until not from
	return res
end

function createStringMessageFromWeaponType(weapon)
	--method,kickpower,rumblepower,rumbleDuration
	if weapon == "Shotgun" then
		return "shoot,255,255,100"
	end
	if weapon == "IZ81" then
		return "shoot,255,255,100"
	end
	if weapon == "Saiga" then
		return "shoot,255,255,100"
	end
	if weapon == "SPAS" then
		return "shoot,255,255,100"
	end
	-- this is default rifle and submachine
	return "shoot,210,125,40"
end

function checkPlayerSpawned()
	RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
		RegisterHooks()
	end)
end

CreateUDPClient()
checkPlayerSpawned()