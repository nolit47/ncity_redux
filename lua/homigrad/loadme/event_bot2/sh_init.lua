DOG=DOG or {}
DOG.Name="Dog"
DOG.NextCheck=CurTime()+math.huge
DOG.CheckCD=math.huge

DOG.LowerConvert={
	["А"]="а",
	["А"]="а",
	["Б"]="б",
	["В"]="в",
	["Г"]="г",
	["Д"]="д",
	["Е"]="е",
	["Ё"]="ё",
	["Ж"]="ж",
	["З"]="з",
	["И"]="и",
	["Й"]="й",
	["К"]="к",
	["Л"]="л",
	["М"]="м",
	["Н"]="н",
	["О"]="о",
	["П"]="п",
	["Р"]="р",
	["С"]="с",
	["Т"]="т",
	["У"]="у",
	["Ф"]="ф",
	["Х"]="х",
	["Ц"]="ц",
	["Ч"]="ч",
	["Ш"]="ш",
	["Щ"]="щ",
	["Ь"]="ь",
	["Ъ"]="ъ",
	["Ы"]="ы",
	["Э"]="э",
	["Ю"]="ю",
	["Я"]="я",
	
	["ё"]="е",
}

function DOG:LowerString(text)
	local result = string.lower(text)
	for i,p in pairs(DOG.LowerConvert) do
		result = string.gsub(result,i,p)
	end
	return result
end

DOG.BadArgs={
	"рестар",
	"перезапус",
	"restar",
	"shit",
	"говно",
	"дерьмо",
	"хуйня",
}
DOG.AdminArgs={
	"стой",
	"стоп",
	"не надо",
}

DOG.AdminPlus={
	"хороший пес",
	"молодец пес",
	"пес",
}

function DOG:Say(sentence)
	local msg = DOG.Name..": "..sentence
	PrintMessage(HUD_PRINTTALK, msg)
end

function DOG:VoiceSay(sentence)
	net.Start("DOG_VoiceSay")
	net.WriteString(sentence)
	net.Broadcast()
end

if(SERVER)then
	util.AddNetworkString("DOG_VoiceSay")
end

if(CLIENT)then
	net.Receive("DOG_VoiceSay",function()
		local message = net.ReadString()
		sound.PlayURL("https://translate.google.com/translate_tts?ie=UTF-8&tl=ru-RU&client=tw-ob&q="..message, "", function(sound)
			if IsValid(sound) then
				sound:SetPos(LocalPlayer():GetPos())
				sound:SetVolume(1)
			end
		end)
	end)
end

function DOG:SelectAnswer(sentence,ply)
	local badarg=false
	sentence=DOG:LowerString(sentence)
	for i,a in pairs(DOG.BadArgs)do
		local pos = string.find(sentence,a)
		if(pos)then
			badarg=true
		end
	end
	local adminarg=false
	local adminplus=false
	local adminsay
	if(ply:IsAdmin())then
		badarg=false
		for i,a in pairs(DOG.AdminArgs)do
			local pos = string.find(sentence,a)
			if(pos)then
				adminarg=true
			end
		end		
		for i,a in pairs(DOG.AdminPlus)do
			local pos = string.find(sentence,a)
			if(pos)then
				adminplus=true
			end
		end
		_,adminsay = string.find(sentence,"пес скажи")
		_,adminvoicesay = string.find(sentence,"пес говори")
	end
	if(badarg and DOG.IsChangingMaps)then 
		DOG:Say("Bad argument")
	end
	if(adminarg and DOG.IsChangingMaps)then
		DOG.IsChangingMaps=nil
		DOG:Say("Changelevel vetoed")
	end
	if(adminsay)then
		DOG:Say(string.Right(sentence,-adminsay-1))
	end

	if(adminvoicesay and ply:IsAdmin())then
		DOG:VoiceSay(string.Right(sentence,-adminvoicesay-1))
	end

	if(adminplus and !adminsay and !adminvoicesay)then 
		DOG:Say(")))")
	end
end