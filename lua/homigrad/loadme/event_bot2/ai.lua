if(!SERVER)then return nil end

DOG=DOG or {}
DOG.ACrash=DOG.ACrash or {}
DOG.ACrash.AI=DOG.ACrash.AI or {}

DOG.ACrash.AI.EntriesPath="hmcd_dog_entries/"


DOG.ACrash.AI.EntryTemplateAnte={}

DOG.ACrash.AI.EntryTemplateAnte["UnScrew"]=980
DOG.ACrash.AI.EntryTemplateAnte["Phys"]=1100
DOG.ACrash.AI.EntryTemplateAnte["Effective"]=1250
DOG.ACrash.AI.EntryTemplateAnte["CleanUp"]=1300
DOG.ACrash.AI.EntryTemplateAnte["Restart"]=1400

DOG.ACrash.AI.EntryTemplate=util.Compress(util.TableToJSON(DOG.ACrash.AI.EntryTemplateAnte))

function DOG.ACrash.AI:SaveEntry(name,content,compress)
	name = name or game.GetMap()
	if(compress and content)then
		content = util.Compress(util.TableToJSON(content))
	end
	file.CreateDir(DOG.ACrash.AI.EntriesPath)
	file.Write(DOG.ACrash.AI.EntriesPath..name..".dat",content or DOG.ACrash.AI.EntryTemplate)
end

function DOG.ACrash.AI:ReadEntry(name,tablify)
	name = name or game.GetMap()
	if(!file.Exists(DOG.ACrash.AI.EntriesPath..name..".dat","DATA"))then
		DOG.ACrash.AI:SaveEntry(name)
	end
	local content = file.Read(DOG.ACrash.AI.EntriesPath..name..".dat")
	if(tablify)then
		content = util.JSONToTable(util.Decompress(content))
	end
	return content
end

function DOG.ACrash.AI:Guess(name,mode,power)
	name = name or game.GetMap()
	local content = DOG.ACrash.AI:ReadEntry(name,true)
	local max = content["Restart"]
	local shift = 0
	if(mode=="up")then
		shift=math.random(50,150)*(power or 1)
	end
	if(mode=="down")then
		shift=math.random(-10,-100)*(power or 1)
	end	
	
	for id,val in pairs(content)do
		content[id]=val+shift
	end
	
	DOG.ACrash.AI:SaveEntry(name,content,true)
	DOG.ACheat:NotifyAdmins("Guessing next values\n"..util.TableToJSON(content,true))
end

function DOG.ACrash.AI:RefreshValues()
	local name = game.GetMap()
	local content = DOG.ACrash.AI:ReadEntry(name,true)
	for id,val in pairs(content)do
		//DOG.ACrash.Values[id]=val
	end	
end
DOG.ACrash.AI:RefreshValues()