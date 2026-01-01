--[[
--\\
DOG = DOG or {}
--//

--\\
neural_net = {
	[1] = {
		[1] = {1, 0.5},
	},
}
--//

--\\Test
local mouse_x = 1
local mouse_y = 1
local eye_angles_x = 0
local eye_angles_y = 0
local eye_angles_z = 0
local to_target_angles_x = 0
local to_target_angles_y = 0
local to_target_angles_z = 0
local input_1 = Matrix({
	{mouse_x},
	{mouse_y},
	{eye_angles_x},
	{eye_angles_y},
	{eye_angles_z},
	{to_target_angles_x},
	{to_target_angles_y},
	{to_target_angles_z},
})

--//
]]