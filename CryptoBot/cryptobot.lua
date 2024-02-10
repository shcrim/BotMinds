-- loadstring(game:HttpGet("https://raw.githubusercontent.com/shcrim/BotMinds/main/CryptoBot/cryptobot.lua"))()

--[[ CREDITS

Original idea made by Aiden123407 and The Bot Company
Ported to TextChatService, simplified and reduced length by me
Hybrid is a mix of both :shrug:

-- END CREDITS]]

-- Current Version: 1.1.5

-- While I'd love to have this included in a Github Call, I can't really get it to work without taking upwards of a minute :sob:
local symbolTable = {
	bitcoin = "BTC",
	ethereum = "ETH",
	solana = "SOL",
	tether = "USDT",
	cardano = "ADA",
	xrp = "XRP",
	polkadot = "DOT",
	avalanche = "AVAX",
	chainlink = "LINK",
	litecoin = "LTC",
	algorand = "ALGO",
	polygon = "MATIC",
	stellar = "XLM",
	cosmos = "ATOM",
	tezos = "XTZ",
	filecoin = "FIL",
	tron = "TRX",
	vechain = "VET",
	bittorrent = "BTT",
	aave = "AAVE",
	monero = "XMR",
	maker = "MKR",
	pancakeswap = "CAKE",
	eos = "EOS",
	compound = "COMP",
	fantom = "FTM",
	klaytn = "KLAY",
	okb = "OKB",
	quant = "QNT",
	elrond = "EGLD",
	harmony = "ONE",
	sushiswap = "SUSHI",
	thorchain = "RUNE",
	chiliz = "CHZ",
	waves = "WAVES",
	dash = "DASH",
	decred = "DCR",
	revain = "REV",
	zcash = "ZEC",
	nano = "NANO",
	telcoin = "TEL",
	decentraland = "MANA",
	gala = "GALA",
	flow = "FLOW",
	holo = "HOT",
	celo = "CELO",
	uma = "UMA",
	nem = "XEM",
	zilliqa = "ZIL",
	ontology = "ONT",
	bancor = "BNT",
	ren = "REN",
	siacoin = "SC",
	terra = "LUNA",
	iotex = "IOTX",
	amp = "AMP",
	husd = "HUSD",
	horizen = "ZEN",
	wazirx = "WRX",
	sapphire = "SAPP",
	quantstamp = "QSP",
	audius = "AUDIO",
	status = "SNT",
	chia = "XCH",
	synthetix = "SNX",
	wax = "WAXP",
	skale = "SKL",
	civic = "CVC",
	balancer = "BAL",
	vethortoken = "VTHO",
	safemoon = "SAFEMOON",
	zkswap = "ZKS",
	singularitynet = "AGIX",
	digibyte = "DGB",
	sora = "XOR",
	serum = "SRM",
	ampleforth = "AMPL",
	orbs = "ORBS",
	coti = "COTI",
	tellor = "TRB",
	syscoin = "SYS",
	divi = "DIVI",
	ardor = "ARDR",
	zeroswap = "ZEE",
	swipe = "SXP",
	dodo = "DODO",
	stratis = "STRAX",
	raydium = "RAY",
}

local TextChatService = game:GetService("TextChatService")
local LocalPlayer = game.Players.LocalPlayer
local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
local tunedOutUsers = {}
local toggle = true
local defaultCooldown = 2 -- This is to avoid Roblox bot detection, etc
local maxDistance = 12 -- in studs
local channel
local Players = game:GetService("Players")
local iLink = "https://api.coinbase.com/v2/exchange-rates?currency=" -- Unformatted, needs the symbol added on to the end to work

local HttpService = game:GetService("HttpService")

local mode -- Mode 1 is the new system (using TextChatService), mode 2 is the older, regular Chat version

local function createPriceString(price, currency)
	price = tonumber(price)
	price = math.round(price)
	price = tostring(price)
	return ("The current price of "..currency.." is $"..price.."!")
end

local function capitalize(str)
	str=(string.upper(string.sub(str, 1, 1))..string.sub(str, 2, -1)) 
	return str
end

local function getName(symbol)
	for i, key in pairs(symbolTable) do
		if key == symbol then
			return capitalize(i)
		end
	end
end

local function sendRequest(apiLink)
	local origTime = tick()
	local response = HttpService:RequestAsync({
		Method = "GET",
		Url = apiLink
	})
	local timeTook = tick() - origTime
	print("Request took "..timeTook.." seconds!")
	return response
end

local function findRate(rateTab, term)
	for i, key in pairs(rateTab) do
		if i == term then
			return key
		end
	end
end

local function modifyLink(link, adder)
	local newLink = link.."%s"
	newLink = string.format(newLink, adder)
	return newLink
end

repeat task.wait() until LocalPlayer.Character -- Hard to avoid this in terms of mode detection, make sure everything is loaded in etc.

local vers = TextChatService.ChatVersion

if vers == Enum.ChatVersion.TextChatService then
	channel = TextChatService:FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral")
	mode = 1
else
	mode = 2
end

local function getSymbol(name)
	return symbolTable[name]
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

local function formatPrice(original)
	original = string.lower(original)
	
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
					sendMessage("!price (sign) -> Returns price. !help -> Info about this bot. !cmds -> Sends this message. !list -> Connected Currencies.")
					cooldown()
				elseif findCommand(msgString, "!list") then
					sendMessage(symbolTable)
					cooldown(1)
				end
				if findCommand(msgString, "!price") then
					local symbol
					local foundCurrency = removeCommand(msgString, "!price")
					if foundCurrency then
						if string.len(foundCurrency) > 4 then
							foundCurrency = formatPrice(foundCurrency)
							symbol = getSymbol(foundCurrency)
						else
							symbol = formatPrice(foundCurrency)
							symbol = string.upper(symbol) -- This is so you don't have to type out the full name
						end

						local modLink = modifyLink(iLink, symbol)
						
						local response = sendRequest(modLink).Body
						response = HttpService:JSONDecode(response)
						
						local rates = response["data"]["rates"]
						local price = findRate(rates, "USD")
						
						sendMessage(createPriceString(price, getName(symbol)))
					end
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
				local symbol
				local foundCurrency = removeCommand(msgString, "!price")
				if foundCurrency then
					if string.len(foundCurrency) > 4 then
						foundCurrency = formatPrice(foundCurrency)
						symbol = getSymbol(foundCurrency)
					else
						symbol = formatPrice(foundCurrency)
						symbol = string.upper(symbol) -- This is so you don't have to type out the full name
					end

					local modLink = modifyLink(iLink, symbol)

					local response = sendRequest(modLink).Body
					response = HttpService:JSONDecode(response)

					local rates = response["data"]["rates"]
					local price = findRate(rates, "USD")

					sendMessage(createPriceString(price, getName(symbol)))
				end
			end
		end
	end)
end

sendMessage("Bot is online!")
