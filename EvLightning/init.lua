-- Name: EvLightning
-- Repository and Docs: https://github.com/evaera/EvLightning
-- Author: Eryn Lynn <eryn.io>
-- Username: evaera
-- Release Date: 3/23/2016
-- Updated Date: 4/7/2018
-- Version: 1.2

--[[
	Options:
		seed: The numerical seed for the lightning bolt
		depth: Initial depth to start at
		bends: Number of bends to put into the bolt
		fork_bends: Number of bends to put into forks
		fork_chance: Chance to fork
		transparency: Initial transparency
		max_depth: max fork depth
		color: brickcolor
		decay: seconds
		material: Enum.Material

	Changelog:
		- 4/7/2018
			- Updated to use Random
			- Check for Vector3 with typeof
			- Change API to allow for .new instantiation
		- 3/9/2018
			- Added material option
			- Changed default material to Neon
--]]

local Debris = game:GetService("Debris")
local class = require(script.Class)

local LightningBolt = class() do
	LightningBolt._version = 1

	function LightningBolt:init(origin, goal, options)
		if typeof(origin) ~= "Vector3" then
			error("LightningBolt: `from` must be a Vector3")
		end
		if typeof(goal) ~= "Vector3" then
			error("LightningBolt: `to` must be a Vector3")
		end

		self.options = options or {}

		if self.options.seed then
			self.random = Random.new(self.options.seed)
		else
			self.random = Random.new()
		end

		self.depth = self.options.depth or 0
		self.origin = origin
		self.goal = goal
		self.rep = self.options.bends or 6

		self.branches = {}
		self.lines = {
			{
				origin = origin;
				goal = goal;
				transparency = self.options.transparency or 0.4;
				depth = self.depth;
			}
		}

		self:generateBolt()
	end

	function LightningBolt:GetOptions()
		local options = {}
		for k, v in pairs(self.options) do
			options[k] = v
		end
		return options
	end

	function LightningBolt:GetLines()
		local lines = {}
		for _, line in pairs(self.lines) do
			lines[#lines+1] = line
		end
		for _, branch in pairs(self.branches) do
			for _, line in pairs(branch:GetLines()) do
				lines[#lines+1] = line
			end
		end
		return lines
	end

	function LightningBolt:IsDestroyed()
		return self.destroyed or false
	end

	function LightningBolt:IsDrawn()
		return self.drew or false
	end

	function LightningBolt:generateBolt()
		for run = 1, self.rep do
			self:bend()
		end
	end

	function LightningBolt:displace(point, goal, radius, rotations)
		return (CFrame.new(point, goal) * CFrame.new(math.sin(math.pi * rotations * 2) * radius, math.cos(math.pi * rotations * 2) * radius, 0)).p
	end

	function LightningBolt:bend()
		local runLines = {}
		for _, line in pairs(self.lines) do
			runLines[#runLines + 1] = line
		end
		for _, line in pairs(runLines) do
			local origGoal = line.goal

			local mid = line.origin+((line.goal-line.origin).unit * (line.goal-line.origin).magnitude) * self.random:NextInteger(40, 60) / 100
			line.goal = self:displace(mid, line.goal, self.random:NextInteger(-530, 530) / 100, self.random:NextNumber())

			self.lines[#self.lines + 1] = {
				origin = line.goal;
				goal = origGoal;
				transparency = line.transparency;
				depth = line.depth;
			}
			if line.depth <= (self.options.max_depth or 3) then
				local perc = (self.origin - line.goal).magnitude / (self.origin - self.goal).magnitude
				if self.random:NextInteger(1, 100) < (self.options.fork_chance or 50) * perc then
					local options = self:GetOptions()
					options.depth = line.depth + 1
					options.bends = options.fork_bends or 2
					local branch = LightningBolt(line.goal, line.goal + ((line.goal - line.origin).unit * self.random:NextInteger(20, 40)), options)
					self.branches[#self.branches + 1] = branch
				end
			end
		end
	end

	function LightningBolt:Draw(parent)
		local model = parent or Instance.new("Model", game.Workspace)
		self.model = model
		model.Name = "LightningBolt"

		for _, line in pairs(self.lines) do
			local part = Instance.new("Part", model)

			part.FormFactor = "Custom"
			part.Anchored = true
			part.CanCollide = false
			part.BrickColor = self.options.color or BrickColor.new("White")
			part.Material = self.options.material or Enum.Material.Neon
			part.TopSurface = "Smooth"
			part.BottomSurface = "Smooth"

			part.Size = Vector3.new(1-line.depth*2*0.1, 1-line.depth*2*0.1, (line.origin-line.goal).magnitude+0.5)
			part.CFrame = CFrame.new((line.goal+line.origin)/2, line.goal)
			part.Transparency = line.transparency
		end

		for _, branch in pairs(self.branches) do
			branch:Draw(model)
		end

		self.drew = true

		if self.options.decay then
			Debris:AddItem(model, tonumber(self.options.decay))
			self.destroyed = true
		end
	end

	function LightningBolt:Destroy()
		if self.model then
			self.model:Destroy()
			self.destroyed = true
		end
	end
end

return setmetatable({ new = LightningBolt }, {
	__call = function (_, ...)
		return LightningBolt(...)
	end
})
