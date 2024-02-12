--[[

MADE BY SHCRIM, STOP STEALING MY CODE PLS :pray:

Most of the code is forked from my original project, CryptoBot (mainly the message sending, mode switching etc)

]]

local ver = "0.0.3"

--[[ TODO:

Write the function for pathfinding to player
Handle edge cases for said function
Post to GitHub

]]

-- IMPORTANT BOT STUFF / SERVICES
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = game.Players.LocalPlayer
local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

-- CONFIG
local tunedOutUsers = {}
local toggle = true
local defaultCooldown = 128 -- This is to avoid Roblox bot detection, etc
local maxDistance = 4 -- in studs
local channel
local mode -- 1/2
local state = "Idle"

-- MAIN FUNCTIONS

local function pathfindTo(username, callback)
	local player = Players:FindFirstChild(username)
	print(player)
	if player then
		local character = player.Character
		print(character)
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			print(humanoid)
			if humanoid then
				local path = PathfindingService:CreatePath({
					AgentRadius = humanoid.HipWidth,
					AgentHeight = humanoid.HipHeight,
					AgentCanJump = humanoid:GetState() == Enum.HumanoidStateType.Physics,
					AgentJumpHeight = humanoid.JumpHeight,
					-- Adjusting path parameters for R6 and R15 compatibility
					SelectRandomWaypoint = false,
					SmoothPath = true
				})
				print(path)
				path:ComputeAsync(character.HumanoidRootPart.Position, humanoid:GetTargetPosition())
				
				-- Update path periodically
				local connection
				connection = RunService.Heartbeat:Connect(function()
					if player and player.Parent and player.Character then
						if path.Status == Enum.PathStatus.Success then
							connection:Disconnect() -- Stop checking when pathfinding is done
							callback(true) -- Callback with true indicating pathfinding is done
						else
							path:ComputeAsync(character.HumanoidRootPart.Position, humanoid:GetTargetPosition())
							print("Path Updated!")
						end
					else
						connection:Disconnect() -- Stop checking when player is no longer in game
						callback(false) -- Callback with false indicating player left the game
					end
				end)
			end
		end
	end
end

local function sendMessage(msg)
	if mode == 1 then
		channel:SendAsync(msg)
	elseif mode == 2 then
		game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
	end
end

local function findPlayerFromUser(user)	
	for I, V in pairs(Players:GetPlayers()) do
		if user:lower() == (V["Name"]:lower()):sub(1, #user) then
			return V 
		end 
	end
end

local function sendPrivateMessage(msg, userName)
	local formatted = string.format("/w %s %s", userName, msg)
	sendMessage(formatted)
end

local function cooldown(amount)
	if amount then
		toggle = false
		task.wait(amount)
		toggle = true
	else
		toggle = false
		task.wait(defaultCooldown)
		toggle = true
	end
end

local function removeCommand(input, command)
	local preFormat = string.gsub(input, command, "")

	if string.find(preFormat, " ") then
		return string.gsub(preFormat, " ", "")
	else
		return preFormat
	end
end

local function formatString(original)
	if string.find(original, " ") then
		return string.gsub(original, " ", "")
	else
		return original
	end
end

local function findCommand(message, command)
	if string.find(message, command) then
		return true
	else
		return false
	end
end

-- ETC / VARIABLE DEFINITION
repeat task.wait() until LocalPlayer.Character -- Hard to avoid this in terms of mode detection, make sure everything is loaded in etc.

local vers = TextChatService.ChatVersion

if vers == Enum.ChatVersion.TextChatService then
	channel = TextChatService:FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral")
	mode = 1
else
	mode = 2
end

-- MAIN LOOP

local function handleChatRecieved(playerWhoSent, msgString)
	if toggle == true then
		-- Player Variable Definition
		local char = Players:FindFirstChild(playerWhoSent.Name).Character
		local hrp = char:WaitForChild("HumanoidRootPart")
		local userName = playerWhoSent.Name

		if (hrp.Position - HumanoidRootPart.Position).Magnitude > maxDistance then
			sendPrivateMessage("Sorry, you're too far away to execute a command.", playerWhoSent.Name)
			return
		end

		if userName == LocalPlayer.Name then
			return
		end

		if toggle == true then
			task.wait(0.1)
			if findCommand(msgString, "!help") then
				sendPrivateMessage("PathBot is a bot made by BotMinds Collective. Try saying !goto (username), and watch him go!", userName)
				cooldown(1)
			elseif findCommand(msgString, "!cmds") then
				sendPrivateMessage("!help -> Info about the bot and how to use it. !goto -> Sends the bot to a specific player. !random -> Sends the bot to a random player.", userName)
				cooldown(1)
			elseif findCommand(msgString, "!version") then
				sendMessage("The bot's current version is "..ver)
				cooldown(1)
			end

			if findCommand(msgString, "!goto") then
				local temp = removeCommand(msgString, "!goto")
				temp = formatString(temp)
				
				local user = findPlayerFromUser(temp)
				
				print(user)
				
				if user ~= "" and user ~= nil and user ~= userName and user ~= LocalPlayer.Name then
					print("Pathfinding began!")
					toggle = false
					pathfindTo(user, function(pathfound)
						if pathfound then
							-- Pathfinding was succesful!
							sendMessage("I was sent here by "..userName.." using !goto "..user)
							cooldown(5)
						else
							-- Player left game or other weird error.
							sendMessage("Player "..user.." left the game before I could reach them! What a shame...")
							cooldown(5)
						end
					end)
				end
			end
		end
	end
end

-- Handling Recieved Chats Using Function (this is the hybrid part of the new script)
if mode == 1 then
	TextChatService.OnIncomingMessage = function(message)
		if message.Status == Enum.TextChatMessageStatus.Success then
			local userName = message.TextSource
			local playerWhoSent = Players:FindFirstChild(tostring(userName))
						
			handleChatRecieved(playerWhoSent, message.Text)
		end	
	end
elseif mode == 2 then
	game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(message)
		local userName = message.FromSpeaker
		local playerWhoSent = Players:FindFirstChild(tostring(userName))
		
		handleChatRecieved(playerWhoSent, message.Message)
	end)
end
