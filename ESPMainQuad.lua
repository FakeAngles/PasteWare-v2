local Quad = {}

local CreateInstance, UpdatePosition = function(Class, Properties, Children)
    local Object = Instance.new(Class)

    for Property, Value in Properties or {} do
        Object[Property] = Value
    end

    for _, Child in Children or {} do
        Child.Parent = Object
    end

    return Object
end, function(Object, From, To, Thickness)
    local Center = (From + To) / 2
    local Offset = To - From

    Object.Position = UDim2.fromOffset(Center.X, Center.Y)
    Object.Size = UDim2.fromOffset(Offset.Magnitude, Thickness)
    Object.Rotation = math.atan2(Offset.Y, Offset.X) * 180 / math.pi
end

__OBJECT_CACHE, __ROOT = {}, CreateInstance("ScreenGui", {
    IgnoreGuiInset = true,
    DisplayOrder = 10,
    Name = game:GetService("HttpService"):GenerateGUID(false),
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = gethui()
})

function Quad.new()
    local QuadObject = setmetatable({
        __OBJECT_EXISTS = true,

        __PROPERTIES = {
            Color = Color3.new(0, 0, 0),
            PointA = Vector2.new(0, 0),
            PointB = Vector2.new(0, 0),
            PointC = Vector2.new(0, 0),
            PointD = Vector2.new(0, 0),
            Thickness = 1,
            Transparency = 1,
            ZIndex = 0,
            Filled = false,
            Visible = false
        },

        __OBJECT = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ZIndex = 0,
            Visible = false,
            Parent = __ROOT
        }, {
            CreateInstance("Frame", {
                Name = "_A",
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 0
            }),

            CreateInstance("Frame", {
                Name = "_B",
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 0
            }),

            CreateInstance("Frame", {
                Name = "_C",
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 0
            }),

            CreateInstance("Frame", {
                Name = "_D",
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 0
            })
        })
    }, Quad)

    table.insert(__OBJECT_CACHE, QuadObject)

    return QuadObject
end

function Quad:__index(Property)
    local Value = self.__PROPERTIES[Property]

    if Value ~= nil then
        return Value
    end

    return Quad[Property]
end

function Quad:__newindex(Property, Value)
    if not self.__OBJECT_EXISTS then
        return error("Attempt To modify drawing that no longer exists!", 2)
    end

    local Properties, Object = self.__PROPERTIES, self.__OBJECT

    Properties[Property] = Value

    if Property == "Color" then
        Object._A.BackgroundColor3 = Value
        Object._B.BackgroundColor3 = Value
        Object._C.BackgroundColor3 = Value
        Object._D.BackgroundColor3 = Value
    elseif Property == "Transparency" then
        Object._A.BackgroundTransparency = 1 - Value
        Object._B.BackgroundTransparency = 1 - Value
        Object._C.BackgroundTransparency = 1 - Value
        Object._D.BackgroundTransparency = 1 - Value
    elseif Property == "Thickness" then
        Object._A.BorderSizePixel = UDim2.fromOffset(Object._A.AbsoluteSize.X, math.max(Value, 1));
        Object._B.BorderSizePixel = UDim2.fromOffset(Object._B.AbsoluteSize.X, math.max(Value, 1));
        Object._C.BorderSizePixel = UDim2.fromOffset(Object._C.AbsoluteSize.X, math.max(Value, 1));
        Object._D.BorderSizePixel = UDim2.fromOffset(Object._D.AbsoluteSize.X, math.max(Value, 1));
    elseif Property == "PointA" then
        self:__UPDATE_VERTICIES({
            { Object._A, Properties.PointA, Properties.PointB },
            { Object._D, Properties.PointD, Properties.PointA }
        })
    elseif Property == "PointB" then
        self:__UPDATE_VERTICIES({
            { Object._A, Properties.PointA, Properties.PointB },
            { Object._B, Properties.PointB, Properties.PointC }
        })
    elseif Property == "PointC" then
        self:__UPDATE_VERTICIES({
            { Object._B, Properties.PointB, Properties.PointC },
            { Object._C, Properties.PointC, Properties.PointD }
        })
    elseif Property == "PointD" then
        self:__UPDATE_VERTICIES({
            { Object._C, Properties.PointC, Properties.PointD },
            { Object._D, Properties.PointD, Properties.PointA }
        })
    elseif Property == "Visible" then
        Object.Visible = Value
    elseif Property == "ZIndex" then
        Object.ZIndex = Value
    end
end

function Quad:__iter()
    return next, self.__PROPERTIES
end

function Quad:__tostring()
    return "Drawing"
end

function Quad:__UPDATE_VERTICIES(verticies)
    local Thickness = self.__PROPERTIES.Thickness

    for idx, verticy in verticies do
        UpdatePosition(verticy[1], verticy[2], verticy[3], Thickness)
    end
end

function Quad:Remove()
    self.__OBJECT_EXISTS = false
    self.__OBJECT.Destroy(self.__OBJECT)
    table.remove(__OBJECT_CACHE, table.find(__OBJECT_CACHE, self))
end

function Quad:Destroy()
    self:Remove()
end

return Quad.new

-- Made by Exunys, forked from liam0999
-- This exists only because modern day exploits have terrible drawing libraries, solara being one of them. Their quad render object is chaotic, nothing works.
