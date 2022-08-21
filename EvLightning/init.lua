-- Name: EvLightning
-- Repository and Docs: https://github.com/evaera/EvLightning
-- Author: Eryn L. K. <eryn.io>
-- Username: evaera
-- Original Written Date: 3/23/2016
--]]

local Debris = game:GetService("Debris")
local class = require(script.Class)

local LightningBolt = class() do
	local partTemplate = Instance.new("Part")
	partTemplate.Anchored = true
	partTemplate.CanCollide = false
	partTemplate.TopSurface = Enum.SurfaceType.Smooth
	partTemplate.BottomSurface = Enum.SurfaceType.Smooth

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

		self.origin = origin
		self.goal = goal
		self.depth = self.options.depth or 0
		self.thickness = self.options.thickness or 1
		self.rep = self.options.bends or 6

		if self.options.color then
			if typeof(self.options.color) == "Color3" then
				self.color = self.options.color
			elseif typeof(self.options.color) == "BrickColor" then
				self.color = self.options.color.Color
			else
				error("LightningBolt: `Options.color` must be a Color3 or BrickColor")
			end
		else
			self.color = BrickColor.new("White").Color
		end

		self.material = self.options.material or Enum.Material.Neon

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
		for i = 1, #self.lines do
			lines[i] = self.lines[i]
		end
		for b = 1, #self.branches do
			local branchLines = self.branches[b]:GetLines()
			for i = 1, #branchLines do
				lines[#lines + 1] = branchLines[i]
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
		return (CFrame.new(point, goal) * CFrame.new(math.sin(math.pi * rotations * 2) * radius, math.cos(math.pi * rotations * 2) * radius, 0)).Position
	end

	function LightningBolt:bend()
		for i = 1, #self.lines do
			local line = self.lines[i]
			local origGoal = line.goal

			local mid = line.origin + ((line.goal - line.origin).unit * (line.goal - line.origin).magnitude) * self.random:NextInteger(40, 60) / 100
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
		local model = Instance.new("Model")
		self.model = model
		model.Name = "LightningBolt"

		local template = partTemplate:Clone()
		template.Material = self.material
		template.Color = self.color

		local lines = self:GetLines()
		for i = 1, #lines do
			local line = lines[i]
			local part = template:Clone()
			part.Size = Vector3.new(self.thickness - line.depth * 2 * 0.1, self.thickness - line.depth * 2 * 0.1, (line.origin - line.goal).magnitude + 0.5)
			part.CFrame = CFrame.new((line.goal + line.origin) / 2, line.goal)
			part.Transparency = line.transparency
			part.Parent = model
		end

		model.Parent = parent or workspace
		self.drew = true

		if self.options.decay then
			Debris:AddItem(model, tonumber(self.options.decay) or 0)
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
