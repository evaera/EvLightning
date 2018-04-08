# EvLightning

EvLightning is a Roblox Lua library that aims to generate realistic-looking lightning bolts. This could be used to easily add lightning strike effects to your game.

<p align="center">
  <img src="https://thumbs.gfycat.com/ClumsyAdolescentCollie-size_restricted.gif" alt="Lightning demo" height="500">
</p>

## Usage

```lua
local LightningBolt = require(path.to.EvLightning)

local myBolt = LightningBolt.new(Vector3.new(0, 400, 0), Vector3.new(0, 0, 0), {
  color = BrickColor.new("Really red");
  -- More options are available, see below...
})
myBolt:Draw(workspace)
```

A lightning bolt is split into lines, and where the lines meet is considered to be a "bend". At each bend, there is a chance to create a fork, which will create another bolt with its own bends, which in turn have chances to create their own forks, etc. You can control how many bends are in the bolt and the chance of creating a fork at each bend.

## API

### *LightningBolt* LightningBolt.new(*Vector3* from, *Vector3* to[, *dictionary* options])
Returns an instance of *LightningBolt*. Automatically generates in the constructor, but further methods must be called on the returned instance to render the bolt.

#### Options

There are a number of options that you can pass in a third argument to `LightningBolt.new` in the form of a table dictionary. All options are optional, and have default values.

| Option name | Description | Default value | Type |
| ----------- | ----------- | ------------- | ---- |
| seed | A numerical seed which could be used to generate the same lightning bolt across a network.| *Random* | Number
| bends | The number of bends the main bolt should have. | 6 | Integer
| fork_bends | The number of bends to put into forks off of the main bolt. | 2 | Integer
| fork_chance | The chance to create a new fork off of each bend. (0-100) | 50 | Number
| transparency | The transparency of the main bolt. Transparency is reduced at every fork. | 0.4 | Number
| thickness | The thickness of the main bolt. Thickness is reduced at every fork. | 1 | Number
| max_depth | The maximum depth that forks can reach off the main bolt, which is depth 0. | 3 | Integer
| color | The color of the bolt | White | BrickColor or Color3
| material | The material of the bolt | Enum.Material.Neon | Enum.Material
| decay | The number of seconds for the bolt to exist after being drawn. | *Infinite* | Number

Note that the `fork_chance` option is not an equal chance for every bend in the bolt. The chance is distributed in a gradient down the length of the bolt, meaning that if the fork_chance is 50, then at the very top it will be 0, at the middle it will be 25, and at the very bottom it will be 50. This is done so that less forks are generated towards the top, which makes the bolt look more realistic. If you need to create upwards-forking lightning, then simply reverse the to and from arguments.

### *void* bolt:Draw([*Instance* parent = Workspace])
Draws the lightning bolt in the world with the given options. An optional argument, *parent*, can be passed, which will be the parent of the generated lightning bolt parts. If this argument is omitted, there will be a new model created in Workspace containing the bolt parts.

### *array* bolt:GetLines()
Returns a table of tables, containing the line information. The member tables have the keys origin, goal, and depth. This is only necessary if you want to draw the lightning bolt manually (i.e. not calling Draw).

```lua
{
	{
		origin 	= Vector3 origin,
		goal 	= Vector3 endpoint,
		depth	= Number depth
	},
	{
		origin 	= Vector3 origin,
		goal 	= Vector3 endpoint,
		depth	= Number depth
	},
	-- ...
}
```

### *void* bolt:Destroy()
If the lightning bolt has been drawn, this method will destroy the model that was created.

### *dictionary* bolt:GetOptions()
Returns a table of the options that were passed into the constructor. Default values are not applied here.

### *bool* bolt:IsDestroyed()
Returns true if the lightning bolt has either been destroyed or has decayed.

### *bool* bolt:IsDrawn()
Returns true of the `Draw` method has been called on this particular instance.
