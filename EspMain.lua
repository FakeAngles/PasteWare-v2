--[[

	Config Library by Exunys © CC0 1.0 Universal (2023 - 2024)
	https://github.com/Exunys

]]

local cloneref = cloneref or function(...)
	return ...
end

local HttpService, ConfigLibrary = cloneref(game:GetService("HttpService")), {}

ConfigLibrary.Encode = function(Table)
	assert(Table, "ConfigLibrary.Encode => Parameter \"Table\" is missing!")
	assert(type(Table) == "table", "ConfigLibrary.Encode => Parameter \"Table\" must be of type <table>. Type given: <"..type(Table)..">")

	if Table and type(Table) == "table" then
		return HttpService:JSONEncode(Table)
	end
end
ConfigLibrary.Decode = function(Content)
	assert(Content, "ConfigLibrary.Decode => Parameter \"Content\" is missing!")
	assert(type(Content) == "string", "ConfigLibrary.Decode => Parameter \"Content\" must be of type <string>. Type given: <"..type(Content)..">")

	return HttpService:JSONDecode(Content)
end

ConfigLibrary.Recursive = function(self, Table, Callback)
	assert(Table, "ConfigLibrary.Recursive => Parameter \"Table\" is missing!")
	assert(Callback, "ConfigLibrary.Recursive => Parameter \"Callback\" is missing!")
	assert(type(Table) == "table", "ConfigLibrary.Recursive => Parameter \"Table\" must be of type <table>. Type given: <"..type(Table)..">")
	assert(type(Callback) == "function", "ConfigLibrary.Recursive => Parameter \"Callback\" must be of type <string>. Type given: <"..type(Callback)..">")

	for Index, Value in next, Table do
		Callback(Index, Value)

		if type(Value) == "table" then
			self:Recursive(Value, Callback)
		end
	end
end

ConfigLibrary.EditValue = function(Value)
	if typeof(Value) == "Color3" then
		return "Color3_("..math.floor(Value.R * 255)..", "..math.floor(Value.G * 255)..", "..math.floor(Value.B * 255)..")"
	elseif typeof(Value) == "Vector3" or typeof(Value) == "Vector2" or typeof(Value) == "CFrame" then
		return typeof(Value).."_("..tostring(Value)..")"
	elseif typeof(Value) == "EnumItem" then
		return "EnumItem_("..string.match(tostring(Value), "Enum%.(.+)")..")"
	end

	return Value
end

ConfigLibrary.RestoreValue = function(Value)
	if type(Value) == "string" then
		local Type, Content = string.match(Value, "(%w+)_%((.+)%)")

		if Type == "Color3" then
			Content = string.split(Content, ", ")

			for Index, _Value in next, Content do
				Content[Index] = tonumber(_Value)
			end

			return Color3.fromRGB(table.unpack(Content))
		elseif Type == "Vector3" or Type == "Vector2" or Type == "CFrame" then
			Content = string.split(Content, ", ")

			for Index, _Value in next, Content do
				Content[Index] = tonumber(_Value)
			end

			return getfenv()[Type].new(table.unpack(Content))
		elseif Type == "EnumItem" then
			return loadstring("return Enum."..Content)()
		end
	end

	return Value
end

ConfigLibrary.CloneTable = function(self, Object, Seen)
	if type(Object) ~= "table" then return Object end
	if Seen and Seen[Object] then return Seen[Object] end

	local LocalSeen = Seen or {}
	local Result = setmetatable({}, getmetatable(Object))

	LocalSeen[Object] = Result

	for Index, Value in next, Object do
		Result[self:CloneTable(Index, LocalSeen)] = self:CloneTable(Value, LocalSeen)
	end

	return Result
end

ConfigLibrary.ConvertValues = function(self, Data, Method)
	assert(Data, "ConfigLibrary.ConvertValues => Parameter \"Data\" is missing!")
	assert(Method, "ConfigLibrary.ConvertValues => Parameter \"Method\" is missing!")
	assert(type(Data) == "table", "ConfigLibrary.ConvertValues => Parameter \"Data\" must be of type <table>. Type given: <"..type(Data)..">")
	assert(type(Method) == "string", "ConfigLibrary.ConvertValues => Parameter \"Method\" must be of type <string>. Type given: <"..type(Method)..">")

	local Passed, Stack = {[Data] = true}, {Data}

	repeat
		local Current = table.remove(Stack) -- "Pop"

		for Index, Value in next, Current do
			if type(Value) == "table" and not Passed[Value] then
				Passed[Value] = true
				Stack[#Stack + 1] = Value -- "Push" to stack
			else
				Current[Index] = self[Method.."Value"](Value)
			end
		end
	until #Stack == 0

	return Data
end

ConfigLibrary.SaveConfig = function(self, Path, Data)
	assert(Path, "ConfigLibrary.SaveConfig => Parameter \"Path\" is missing!")
	assert(Data, "ConfigLibrary.SaveConfig => Parameter \"Data\" is missing!")
	assert(type(Path) == "string", "ConfigLibrary.SaveConfig => Parameter \"Path\" must be of type <string>. Type given: <"..type(Path)..">")
	assert(type(Data) == "table", "ConfigLibrary.SaveConfig => Parameter \"Data\" must be of type <table>. Type given: <"..type(Data)..">")

	local Result = self.Encode(self:ConvertValues(self:CloneTable(Data), "Edit"))

	if select(2, pcall(function() readfile(Path) end)) then
		self.CreatePath(self, Path, Result)
	end

	writefile(Path, Result)
end

ConfigLibrary.LoadConfig = function(self, Path)
	assert(Path, "ConfigLibrary.LoadConfig => Parameter \"Path\" is missing!")
	assert(type(Path) == "string", "ConfigLibrary.LoadConfig => Parameter \"Path\" must be of type <string>. Type given: <"..type(Path)..">")

	return self:ConvertValues(self.Decode(readfile(Path)), "Restore")
end

ConfigLibrary.CreatePath = function(self, Path, Content)
	assert(Path, "ConfigLibrary.CreatePath => Parameter \"Path\" is missing!")
	assert(type(Path) == "string", "ConfigLibrary.CreatePath => Parameter \"Path\" must be of type <string>. Type given: <"..type(Path)..">")

	local Folders, Destination, File = string.split(Path, "/"), ""
	File = Folders[#Folders]; table.remove(Folders)

	for Index = 1, #Folders do
		Destination = Destination..Folders[Index].."/"

		if not isfolder(Destination) then
			makefolder(Destination)
		end
	end

	if not isfile(Destination..File) then
		writefile(Destination..File, Content or "")
	end
end

return ConfigLibrary
