# Using Tile Maps

In game development, tile maps are a common way to construct scenes. This article will introduce how to create tile maps using **Tiled Editor**, how to load and render these maps using the **TileNode** class in the **Dora SSR** game engine, and how to read layered data from the maps.

## 1. Introduction to Tiled Editor

[Tiled Editor](https://www.mapeditor.org) is a free, open-source, and powerful tile map editor. It supports various map formats and layers, making it convenient to create complex game scenes. Key features include:

- **Multi-platform support**: Runs on Windows, macOS, Linux, and other operating systems.
- **Flexible layer system**: Supports multi-layer map editing, including tile layers, object layers, and image layers.
- **Rich export formats**: Supports exporting to JSON, XML, TMX, and other formats for easy integration with various game engines.

## 2. Loading and Rendering Tile Maps with TileNode

### 2.1 Preparation

First, ensure that **Tiled Editor** is installed and you have created a tile map exported as a **TMX (XML format)** file. For example, we have a map file named `platform.tmx`.

### 2.2 Creating a TileNode Instance

In your Lua script, first load the `TileNode` module, then create a `TileNode` object.

```ts
import { TileNode } from "Dora";

// Load the entire map, including all layers
const tmxNode = TileNode("TMX/platform.tmx");
```

If you want to load only specific layers, you can specify the layer name when creating the `TileNode`:

```ts
// Load a specific layer
const tmxNode = TileNode("TMX/platform.tmx", "Far");
```

Or load multiple specific layers:

```ts
// Load multiple layers
const tmxNode = TileNode("TMX/platform.tmx", ["Far", "Near"]);
```

### 2.3 Adding TileNode to the Scene Tree

After creating a `TileNode` instance, you can add it to a specific scene tree and control the tile map's translation, rotation, and scaling through this node.

```ts
// Add TileNode to an existing scene
scene.addChild(tmxNode);

// Set the tile map's position and scale
tmxNode.position = Vec2(100, 100);
tmxNode.scaleX = 2.0;
tmxNode.scaleY = 2.0;
```

### 2.4 Reading Layer Data

`TileNode` provides a `getLayer` method to retrieve layer data by layer name.

```ts
// Get the layer named "Objects"
if (tmxNode !== null) {
	error("Failed to load map");
}

const layer = tmxNode.getLayer("Objects");
```

Layer data is returned as a Dictionary, and its content depends on the layer type. For example, for Tiled object layers, you can iterate through the objects like this:

```ts
import { tolua, TypeName } from "Dora";

// Iterate through objects in the object layer
const objects = tolua.cast(tmxNode.getLayer("Objects")?.objects, TypeName.Array);
objects?.each(item => {
	print(item);
	const dict = tolua.cast(item, TypeName.Dictionary);
	dict?.each((value, key) => {
		print('\t', key, value);
		return false;
	});
	return false;
});
```

### 2.5 Setting Render Properties

`TileNode` also provides properties to control the tile map's rendering effects.

- **depthWrite**: Whether to write to the depth buffer, default is `false`.
- **blendFunc**: Blend function that controls the rendering blend mode.
- **effect**: Shader effect for adding special effects to the tile map.
- **filter**: Texture filtering mode that controls texture display. Default is `"Point"`, which is suitable for pixel-style game map rendering.

For example, set the tile map's texture filtering mode to anisotropic filtering for smoother edges:

```ts
import { TextureFilter } from "Dora";

tmxNode.filter = TextureFilter.Anisotropic;
```

## 3. Complete Example

Here's a complete example demonstrating how to load a tile map, add it to a scene, read object layer data, and set rendering properties.

```ts
import { TileNode, Director, TextureFilter, tolua, TypeName } from "Dora";

// Create TileNode instance, load the entire map
const tmxNode = TileNode("TMX/platform.tmx");
if (tmxNode === null) {
	error("Failed to load map");
}

// Set texture filtering mode
tmxNode.filter = TextureFilter.Anisotropic;

// Add TileNode to the scene
// Director.entry is the engine's scene root node
// If you don't specify below code, it will be automatically added to this node by default
const scene = Director.entry;
scene.addChild(tmxNode);

// Get object layer data
const layer = tmxNode.getLayer("Objects");
if (layer !== null) {
	const objects = tolua.cast(layer.objects, TypeName.Dictionary);
	// Iterate through objects in the object layer
	objects?.each(obj => {
		const item = tolua.cast(obj, TypeName.Dictionary);
		if (item !== null) {
			print("Object name:", item.name);
			print(" Visible property:", item.visible);
			print(" Position property:", item.position);
			print(" Shape property:", item.shape);
			// Access other properties...
		}
		return false;
	});
}
```

## 4. Summary

Using the **TileNode** class from **Dora SSR**, we can easily load and render tile maps created with **Tiled Editor**. Additionally, we can access layer data using the `getLayer` method for game logic processing. With these features, developers can efficiently build complex tile map game scenes.