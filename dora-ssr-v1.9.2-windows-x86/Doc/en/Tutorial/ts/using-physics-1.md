# Using Physics Nodes I

In this tutorial, we will learn how to create physics rigid body node objects in the Dora SSR game engine and set up groups and collision relationships between different physics objects. By following the steps below, you'll be able to implement basic gravity movements, shape setups, and collision detection in the physics world.

## 1. Creating the Physics World with Gravity

First, we need to define a physics world and set its gravity direction and magnitude. In this example, gravity is defined as vertical downward, with a magnitude of `-10`.

```ts
import { Vec2, PhysicsWorld } from "Dora";

const gravity = Vec2(0, -10); // Define gravity direction and magnitude
const world = PhysicsWorld(); // Create the physics world
world.y = -200; // Adjust the y-axis position of the world
```

## 2. Defining Physics Rigid Bodies

Physics rigid bodies can be static, dynamic, or kinematic. Static bodies are used for immovable objects (e.g., ground), dynamic bodies for movable objects (e.g., characters or obstacles), and kinematic bodies for objects with infinite mass that can be controlled to move.

### 2.1 Defining Static Terrain Bodies

Static bodies are commonly used for ground or walls and are typically unaffected by gravity. In the example below, we create a static terrain body with an 800x10 polygon shape.

```ts
import { BodyDef, BodyMoveType } from "Dora";

const terrainDef = BodyDef();
terrainDef.type = BodyMoveType.Static; // Set as a static body
terrainDef.attachPolygon(800, 10, 1, 0.8, 0.2); // Attach a polygon with width 800 and height 10
// Note: The parameters 1, 0.8, 0.2 are density, friction coefficient, and elasticity coefficient, respectively
```

### 2.2 Defining Dynamic Polygon Bodies

Dynamic bodies are affected by gravity and move according to the forces in the physics world. We can define a polygon body, and in the example below, we define a hexagon.

```ts
import { BodyDef, Vec2, BodyMoveType } from "Dora";

const polygonDef = BodyDef();
polygonDef.type = BodyMoveType.Dynamic; // Set as a dynamic body
polygonDef.linearAcceleration = gravity; // Apply gravity
polygonDef.attachPolygon([
	Vec2(60, 0),
	Vec2(30, -30),
	Vec2(-30, -30),
	Vec2(-60, 0),
	Vec2(-30, 30),
	Vec2(30, 30)
], 1, 0.4, 0.4); // Define a hexagon
```

### 2.3 Defining Dynamic Circular Bodies

Circular bodies are similar to polygons, but with a circular shape, and are also affected by gravity.

```ts
import { BodyDef, BodyMoveType } from "Dora";

const diskDef = BodyDef();
diskDef.type = BodyMoveType.Dynamic; // Set as a dynamic body
diskDef.linear

Acceleration = gravity; // Apply gravity
diskDef.attachDisk(60, 1, 0.4, 0.4); // Attach a disk with a radius of 60
```

## 3. Setting Groups and Collision Relationships

We can define collision rules between objects by setting groups. In this example, we create three groups and use the `setShouldContact` method to establish collision rules between the groups.

```ts
const groupZero = 0;
const groupOne = 1;
const groupTwo = 2;

world.setShouldContact(groupZero, groupOne, false); // No collision between group 0 and group 1
world.setShouldContact(groupZero, groupTwo, true); // Collision between group 0 and group 2
world.setShouldContact(groupOne, groupTwo, true); // Collision between group 1 and group 2
world.showDebug = true; // Show debug information
```

:::tip Best Practices for Physics Grouping
In actual game development, setting physics groups properly can greatly enhance performance and reduce unnecessary calculations. It's recommended to assign different groups to static elements, dynamic objects, and player characters, adjusting collision relationships as needed.
:::

## 4. Creating and Adding Bodies to the Physics World

Finally, we instantiate the defined physics body objects and add them to the physics world. Each body can be assigned to a different group and have its initial position set within the world.

```ts
import { Body } from "Dora";

// Create and add static terrain body
const terrain = Body(terrainDef, world, Vec2.zero);
terrain.group = groupTwo; // Set group 2 for this body
world.addChild(terrain);

// Create and add dynamic polygon body
const polygon = Body(polygonDef, world, Vec2(0, 500), 15);
polygon.group = groupOne; // Set group 1 for this body
world.addChild(polygon);

// Create and add dynamic circular body
const disk = Body(diskDef, world, Vec2(50, 800));
disk.group = groupZero; // Set group 0 for this body
disk.angularRate = 90; // Set rotation speed
world.addChild(disk);
```

## 5. Conclusion

In this tutorial, you've learned how to create physics rigid bodies in the Dora SSR game engine and control collisions between objects through grouping. By flexibly setting body properties, shapes, and groups, you can achieve complex physical effects and add more fun to your game.

We hope this tutorial helps you better understand the physics system of Dora SSR. Happy developing!