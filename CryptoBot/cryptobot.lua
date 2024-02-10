--[[ CREDITS

Original idea made by Aiden123407 and The Bot Company
Ported to TextChatService by me
Hybrid is a mix of both :shrug:

-- END CREDITS]]

local TextChatService = game:GetService("TextChatService")
local LocalPlayer = game.Players.LocalPlayer
local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
local tunedOutUsers = {}
local toggle = true
local defaultCooldown = 2 -- This is to avoid Roblox bot detection, etc
local maxDistance = 12 -- in studs
local channel
local Players = game:GetService("Players")
local sLink = "https://raw.githubusercontent.com/shcrim/BotMinds/main/CryptoBot/symbols.lua"
local iLink = "https://api.coinbase.com/v2/exchange-rates?currency=" -- Unformatted, needs the symbol added on to the end to work

local HttpService = game:GetService("HttpService")

local mode -- Mode 1 is the new system (using TextChatService), mode 2 is the older, regular Chat version

local function sendRequest(apiLink)
	local success, response = pcall(HttpService.GetAsync, HttpService, apiLink)
	if success then
		return HttpService:JSONDecode(response)
	else
		warn("Failed to send request:", response)
		return nil
	end
end

repeat task.wait() until LocalPlayer.Character -- Hard to avoid this in terms of mode detection, make sure everything is loaded in etc.

local vers = TextChatService.ChatVersion

if vers == Enum.ChatVersion.TextChatService then
	channel = TextChatService:FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral")
	mode = 1
else
	mode = 2
end

local function sendMessage(msg)
	if mode == 1 then
		channel:SendAsync(msg)
	elseif mode == 2 then
		game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
	end
end

local function cooldown(amount)
	if amount then
		toggle = false
		wait(amount)
		toggle = true
	else
		toggle = false
		wait(defaultCooldown)
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

local function findCommand(message, command)
	if string.find(message, command) then
		return true
	else
		return false
	end
end

if mode == 1 then
	TextChatService.OnIncomingMessage = function(message)
		if message.Status == Enum.TextChatMessageStatus.Success then
			local playerWhoSent = message.TextSource
			local char = Players:FindFirstChild(playerWhoSent.Name).Character
			local hrp = char:WaitForChild("HumanoidRootPart")

			if (hrp.Position - HumanoidRootPart.Position).Magnitude > maxDistance then
				return
			end

			--local userName = playerWhoSent.Name
			--if userName == LocalPlayer.Name or tunedOutUsers[userName] then
			--	return
			--end

			local msgString = message.Text

			if toggle == true then
				task.wait(0.1)
				if findCommand(msgString, "!help") then
					sendMessage("CryptoBot is a bot made by BotMinds Collective. This bot is mamadede to send requests to a Cryptocurrency API and send back some info in Roblox.")
					cooldown()
				elseif findCommand(msgString, "!cmds") then
					sendMessage("!price (sign) -> Returns price. !help -> Info about this bot. !cmds -> Sends this message.")
					cooldown()
				end
				if findCommand(msgString, "!price") then

					print("Price command executed!")
				end
			end
		end
	end
elseif mode == 2 then
	game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(message)
		local userName = message.FromSpeaker
		local playerWhoSent = Players:FindFirstChild(tostring(userName))
		local char = playerWhoSent.Character
		local hrp = char:WaitForChild("HumanoidRootPart")

		if (hrp.Position - HumanoidRootPart.Position).Magnitude > maxDistance then
			return
		end

		--local userName = playerWhoSent.Name
		--if userName == LocalPlayer.Name or tunedOutUsers[userName] then
		--	return
		--end

		local msgString = message.Message

		if toggle == true then
			task.wait(0.1)
			if findCommand(msgString, "!help") then
				sendMessage("CryptoBot is a bot made by BotMinds Collective. This bot is mamadede to send requests to a Cryptocurrency API and send back some info in Roblox.")
				cooldown()
			elseif findCommand(msgString, "!cmds") then
				sendMessage("!price (sign) -> Returns price. !help -> Info about this bot. !cmds -> Sends this message.")
				cooldown()
			end
			if findCommand(msgString, "!price") then
				print("Price command executed!")
			end
		end
	end)
end

sendMessage("Bot is online!")
