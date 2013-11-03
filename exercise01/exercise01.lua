-- Build one function to calculate the perimeter of a
-- geometric figure and another to compute its area.
-- Note that the function needs to identify the object
-- from its properties.

square1 = {side = 5}
square2 = {side = 7}
rectangle1 = {width = 4, height = 6}
rectangle2 = {width = 8, height = 2}
circle1 = {radius = 3}
triangle1 = {side1 = 5, side2 = 4, side3 = 3}


local function calculateArea(geometry)

        if geometry["side"] then
                return math.pow(geometry["side"], 2)

        elseif geometry["width"] and geometry["height"] then
                return geometry["width"] * geometry["height"]

        elseif geometry["radius"] then
                return math.pi * math.pow(geometry["radius"], 2)

        elseif geometry["side1"] and geometry["side2"] and geometry["side3"] then
                p = (geometry["side1"] + geometry["side2"] + geometry["side3"]) / 2
                return math.sqrt(p * (p - geometry["side1"]) * (p - geometry["side2"]) * (p - geometry["side3"]))

        else return "No geometry could be found."
        end
end

local function calculatePerimeter(geometry)

        if geometry["side"] then
                return 4 * geometry["side"]

        elseif geometry["width"] and geometry["height"] then
                return 2 * (geometry["width"] * geometry["height"])

        elseif geometry["radius"] then
                return 2 * math.pi * geometry["radius"]

        elseif geometry["side1"] and geometry["side2"] and geometry["side3"] then
                return (geometry["side1"] + geometry["side2"] + geometry["side3"])

        else return "No geometry could be found."
        end
end

print(calculateArea(square1))
print(calculateArea(rectangle1))
print(calculateArea(circle1))
print(calculateArea(triangle1))
print(calculateArea({a = "b"}))

print("\n")

print(calculatePerimeter(square1))
print(calculatePerimeter(rectangle1))
print(calculatePerimeter(circle1))
print(calculatePerimeter(triangle1))
print(calculatePerimeter({a = "b"}))
