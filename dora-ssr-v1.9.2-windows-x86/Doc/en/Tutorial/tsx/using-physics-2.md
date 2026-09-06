# Using Physics Nodes II

In this tutorial, we will dive into the advanced functionalities of physical nodes, including:

1. **Sensor Functionality**: Detects objects entering or leaving a specified area without participating in physical collisions.
2. **One-Way Platforms**: Create platforms that only allow objects to pass through from one direction using the `onContactFilter` callback.
3. **Handling Collision Events**: How to listen to and handle object collision events.

With the following example code and explanations, you'll learn how to implement these features in Dora SSR.

## 1. Creating a Physical World

First, initialize the physical world and set the basic parameters.

```ts
import { Vec2, PhysicsWorld } from "Dora";

const gravity = Vec2(0, -10); // Define gravity direction and magnitude

const world = PhysicsWorld(); // Create the physical world
world.setShouldContact(0, 0, true); // Set collision rules between groups
world.showDebug = true; // Show debug information
```

## 2. Creating a Sensor

A sensor is a special physical object that doesn't participate in collisions but can detect other objects entering or leaving its area.

### 2.1 Defining a Sensor

```ts
import { BodyDef, Vec2 } from "Dora";

const terrainDef = BodyDef();
const count = 50;
const radius = 300;
const vertices: Vec2.Type[] = [];

for (let i = 1; i <= count + 1; i++) {
	const angle = 2 * math.pi * i / count;
	vertices.push(Vec2(radius * math.cos(angle), radius * math.sin(angle)));
}

// Add a closed chain shape static body definition
terrainDef.attachChain(vertices, 0.4, 0);

// Add a circular sensor area with label number 99
terrainDef.attachDiskSensor(99, Vec2(80, 80), 100);
```

- `attachChain`: Creates a chain shape made of multiple vertices.
- `attachDiskSensor`: Adds a circular sensor at the specified location that doesn't participate in collisions but can detect objects entering the area.

### 2.2 Listening to Sensor Events

```ts
import { BodyDef, Vec2 } from "Dora";

const terrain = Body(terrainDef, world);
terrain.onBodyEnter((other, sensorTag) => {
	if (sensorTag == 99) {
		// Triggered when an object enters the sensor area
		other.velocity = other.velocity.mul(0.5); // Halve the object's speed
	}
});
terrain.addTo(world);
```

- `onBodyEnter`: Called when another object enters the sensor area.
- Callback function parameters:
	- `other`: The object that entered the sensor.
	- `sensorTag`: The sensor's label used to distinguish between different sensors.

## 3. Creating a One-Way Platform

Using `onContactFilter`, we can control the collision behavior and create a platform that only allows objects to pass through from one direction.

### 3.1 Defining the Platform Body

```ts
import { BodyDef, Vec2 } from "Dora";

const platformDef = BodyDef();
// Add a rectangular platform definition
platformDef.attachPolygon(
	Vec2(0, -80), // Position
	120, 30, // Width and height
	0, // Angle
	1, 0, 1.0 // Density, friction coefficient, restitution coefficient
);
```

### 3.2 Setting the Collision Filter

```ts
import { Body } from "Dora";

const platform = Body(platformDef, world);
platform.onContactFilter(body => {
	return body.velocityY < 0; // Only collide when the object is moving downward
});
platform.addTo(world);
```

- `onContactFilter`: Custom collision detection rules.
- The callback function returns `true` to allow the collision and `false` to ignore it.
- By checking the object's vertical speed (`velocityY`), we achieve a one-way collision effect.

## 4. Handling Collision Events

Listening to collision events allows specific logic to be executed, such as playing sound effects or triggering animations.

### 4.1 Creating a Dynamic Body

```ts
import { BodyDef, Vec2, BodyMoveType } from "Dora";

const diskDef = BodyDef();
diskDef.type = BodyMoveType.Dynamic;
diskDef.linearAcceleration = gravity;
diskDef.attachDisk(20, 5, 0.8, 1); // Create a circular body with a radius of 20

const disk = Body(diskDef, world, Vec2(100, 200));
disk.angularRate = -1800; // Set the rotation speed
disk.addTo(world);
```

- `type`: Set to dynamic body, affected by the physics engine.
- `attachDisk`: Creates a circular-shaped body.

### 4.2 Listening to Collision Events

```ts
import { Line, App } from "Dora";

// Create a marker to draw at the collision point
const drawNode = Line([
	Vec2(-20, 0),
	Vec2(20, 0),
	Vec2.zero,
	Vec2(0, -20),
	Vec2(0, 20)
], App.themeColor);
drawNode.addTo(world);

disk.onContactStart((other, point) => {
	// Set the marker's position to the collision point
	drawNode.position = point;
});
```

- `onContactStart`: Called when the body starts colliding with another object.
- Callback function parameters:
	- `other`: The other object involved in the collision.
	- `point`: The world coordinates of the collision point.
- Use `drawNode` to display a marker at the collision location, making it easier to visualize.

## 5. Results

By running the above code, you will achieve the following effects:

- **Sensor Functionality**: When an object enters the sensor area, its speed is halved, simulating a slowing effect.
- **One-Way Platform**: Objects can only fall through the platform from above and cannot pass through from below, achieving a one-way collision.
- **Collision Events**: When the circular body collides with other objects, a marker is displayed at the collision point.

## 6. Summary

This tutorial introduced the advanced features of physical nodes, including the use of sensors, how to create one-way platforms, and how to capture and handle collision events. These features can enhance the interactivity of your game and improve the player experience.

By mastering sensors and collision events, you can:

- **Design complex trigger mechanisms**: such as traps, switches, portals, etc.
- **Optimize game physics effects**: achieving more realistic interactions like elastic collisions and speed control.
- **Enhance gameplay**: creating unique level designs and challenges.

We hope this tutorial helps you gain a deeper understanding of Dora SSR's physics system and encourages you to explore more advanced game features!

:::tip Reminder
In practical development, effectively utilizing the advanced features of the physics engine can make your game more creative and engaging. Experiment with different parameters and functions to discover more possibilities!
:::