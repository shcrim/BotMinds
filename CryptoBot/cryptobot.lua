local TextChatService = game:GetService("TextChatService")
local LocalPlayer = game.Players.LocalPlayer
local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
local tunedOutUsers = {}
local toggle = true
local defaultCooldown = 2 -- This is to avoid Roblox bot detection, etc
local channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
local maxDistance = 12 -- in studs
local Players = game:GetService("Players")

local symbols = {
	Bitcoin = "BTC",
	Ethereum = "ETH",
	["Binance Coin"] = "BNB",
	Solana = "SOL",
	Tether = "USDT",
	Cardano = "ADA",
	XRP = "XRP",
	Polkadot = "DOT",
	Avalanche = "AVAX",
	Chainlink = "LINK",
	Litecoin = "LTC",
	["Bitcoin Cash"] = "BCH",
	Algorand = "ALGO",
	Polygon = "MATIC",
	Stellar = "XLM",
	["Theta Network"] = "THETA",
	Cosmos = "ATOM",
	Tezos = "XTZ",
	["Ethereum Classic"] = "ETC",
	Filecoin = "FIL",
	TRON = "TRX",
	["Crypto.com Coin"] = "CRO",
	VeChain = "VET",
	["FTX Token"] = "FTT",
	BitTorrent = "BTT",
	["Shiba Inu"] = "SHIB",
	["The Sandbox"] = "SAND",
	["NEAR Protocol"] = "NEAR",
	Aave = "AAVE",
	Monero = "XMR",
	["Bitcoin SV"] = "BSV",
	Maker = "MKR",
	PancakeSwap = "CAKE",
	EOS = "EOS",
	Compound = "COMP",
	["Internet Computer"] = "ICP",
	Fantom = "FTM",
	["Axie Infinity"] = "AXS",
	Klaytn = "KLAY",
	["UNUS SED LEO"] = "LEO",
	OKB = "OKB",
	Quant = "QNT",
	Elrond = "EGLD",
	Harmony = "ONE",
	SushiSwap = "SUSHI",
	["Huobi Token"] = "HT",
	THORChain = "RUNE",
	Chiliz = "CHZ",
	Waves = "WAVES",
	Dash = "DASH",
	["The Graph"] = "GRT",
	Decred = "DCR",
	Revain = "REV",
	Zcash = "ZEC",
	["Enjin Coin"] = "ENJ",
	["Hedera Hashgraph"] = "HBAR",
	["Bitcoin Gold"] = "BTG",
	Kusama = "KSM",
	Ravencoin = "RVN",
	Nano = "NANO",
	Telcoin = "TEL",
	["Curve DAO Token"] = "CRV",
	Decentraland = "MANA",
	["yearn.finance"] = "YFI",
	Gala = "GALA",
	["Voyager Token"] = "VGX",
	Flow = "FLOW",
	Holo = "HOT",
	Celo = "CELO",
	UMA = "UMA",
	["Bitcoin Diamond"] = "BCD",
	NEM = "XEM",
	["Basic Attention Token"] = "BAT",
	Zilliqa = "ZIL",
	Ontology = "ONT",
	Bancor = "BNT",
	Ren = "REN",
	Siacoin = "SC",
	Terra = "LUNA",
	["BitTorrent Token"] = "BTT",
	IoTeX = "IOTX",
	["Perpetual Protocol"] = "PERP",
	["OMG Network"] = "OMG",
	Amp = "AMP",
	["Bitcoin Cash ABC"] = "BCHA",
	["Ankr"] = "ANKR",
	["Energy Web Token"] = "EWT",
	["Kava.io"] = "KAVA",
	["FEG Token"] = "FEG",
	HUSD = "HUSD",
	Horizen = "ZEN",
	REN = "REN",
	WazirX = "WRX",
	Sapphire = "SAPP",
	Quantstamp = "QSP",
	Audius = "AUDIO",
	Status = "SNT",
	["Reserve Rights Token"] = "RSR",
	["Mirror Protocol"] = "MIR",
	Chia = "XCH",
	["Raiden Network Token"] = "RDN",
	Synthetix = "SNX",
	["Ocean Protocol"] = "OCEAN",
	WAX = "WAXP",
	["Band Protocol"] = "BAND",
	SKALE = "SKL",
	["Reef Finance"] = "REEF",
	Civic = "CVC",
	Balancer = "BAL",
	VeThorToken = "VTHO",
	SafeMoon = "SAFEMOON",
	ZKSwap = "ZKS",
	SingularityNET = "AGIX",
	["DigiByte"] = "DGB",
	["FIO Protocol"] = "FIO",
	Sora = "XOR",
	Serum = "SRM",
	Ampleforth = "AMPL",
	["SKALE Network"] = "SKL",
	["Celer Network"] = "CELR",
	["WOO Network"] = "WOO",
	Orbs = "ORBS",
	["Fetch.ai"] = "FET",
	["JustLiquidity"] = "JUL",
	Arweave = "AR",
	COTI = "COTI",
	Tellor = "TRB",
	Syscoin = "SYS",
	Divi = "DIVI",
	Ardor = "ARDR",
	["Mina Protocol"] = "MINA",
	ZeroSwap = "ZEE",
	["Injective Protocol"] = "INJ",
	["Ampleforth Governance Token"] = "FORTH",
	["Immutable X"] = "IMX",
	["Pax Dollar"] = "USDP",
	Lisk = "LSK",
	Radix = "EXRD",
	["OceanEX Token"] = "OCE",
	["Orion Protocol"] = "ORN",
	["iExec RLC"] = "RLC",
	["STASIS EURO"] = "EURS",
	["SXP Token"] = "SXP",
	Venus = "XVS",
	Frontier = "FRONT",
	["Insight Protocol"] = "INX",
	Utrust = "UTK",
	Verge = "XVG",
	Prometeus = "PROM",
	["Neutrino USD"] = "USDN",
	Gnosis = "GNO",
	Swipe = "SXP",
	["Alpha Finance Lab"] = "ALPHA",
	["Akash Network"] = "AKT",
	DODO = "DODO",
	Stratis = "STRAX",
	["PERL.eco"] = "PERL",
	Raydium = "RAY",
}

local function sendMessage(msg)
	if string.len(msg) <= 90 then
		channel:SendAsync(msg)
	else
		local chunks = {}
		local currentIndex = 1
		while currentIndex <= string.len(msg) do
			local chunk = string.sub(msg, currentIndex, currentIndex + 89)
			table.insert(chunks, chunk)
			currentIndex = currentIndex + 90
		end
		for _, chunk in ipairs(chunks) do
			channel:SendAsync(chunk)
		end
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
				sendMessage("CryptoBot is a bot made by BotMinds Collective. This bot is made to send requests to a Cryptocurrency API and send back some info in Roblox.")
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

sendMessage("Bot is online!")

