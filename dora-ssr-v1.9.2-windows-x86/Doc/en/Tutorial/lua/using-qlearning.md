# Developing Gameplay with Q-Learning

## 1. Introduction

Welcome to this tutorial! Here, we'll walk you through how to use the Q-Learning reinforcement learning algorithm to develop gameplay in the Dora SSR game engine. Don't worry if you're new to machine learning and game development; this tutorial is designed to be easy to understand.

## 2. What is Reinforcement Learning and Q-Learning?

**Reinforcement Learning** is a type of machine learning in which an agent takes actions in an environment to earn rewards or penalties, learning to maximize cumulative rewards.

**Q-Learning** is a model-free reinforcement learning algorithm. It estimates the maximum expected reward for an action \( a \) taken in a state \( s \) by learning a state-action value function \( Q(s, a) \).

### 2.1 Applying Q-Learning in Game Development

In a game, the game character can be seen as the agent, and the game world is the environment. Through Q-Learning, the character can gradually learn the best actions to maximize rewards, like defeating enemies or collecting items, based on different states.

## 3. Understanding the QLearner Object

The Dora SSR engine provides a `QLearner` object, which includes the methods needed to implement Q-Learning. Here are the main methods and properties:

- **pack(hints, values)**: Combines multiple conditions into a unique state value.
- **QLearner(gamma, alpha, maxQ)**: Creates a QLearner instance.
- **update(state, action, reward)**: Updates Q-values based on the reward.
- **getBestAction(state)**: Retrieves the best action for a given state.
- **matrix**: A matrix storing state, action, and corresponding Q-values.
- **load(values)**: Loads Q-values from a known state-action pair matrix.

### 3.1 QLearner:pack() Detailed Explanation

#### Function Overview

The `QLearner.pack()` method combines multiple discrete conditions into a unique state value. It accepts two parameters:

- **hints**: An integer array indicating the number of possible values for each condition.
- **values**: An integer array representing the current value for each condition.

#### Why is pack() Necessary?

In reinforcement learning, states are often made up of multiple features. To store and retrieve these states in a Q-table efficiently, we need to combine these features into a unique state identifier. The `pack()` method serves this purpose.

#### Working Principle

Imagine we have two conditions:

1. Weather conditions with three possibilities: sunny (0), cloudy (1), and rainy (2).
2. Number of enemies with two possibilities: few (0) and many (1).

Thus, `hints = {3, 2}` represents three values for the first condition and two for the second.

If it's currently cloudy and there are many enemies, then `values = {1, 1}`.

Using `pack(hints, values)`, we can convert `values` into a unique state integer. For example:

```lua
local ML = require("ML")
local state = ML.QLearner:pack({3, 2}, {1, 1})
print(state) -- Outputs a unique integer representing the current state
```

#### Mathematical Principle

The `pack()` method combines multiple conditions by encoding each as a binary number and performing bitwise operations to produce a unique integer.

## 4. Step-by-Step Implementation

### 4.1 Importing the QLearner Module

First, import the `ML` module and create a `QLearner` instance:

```lua
local ML = require("ML")
local qLearner = ML.QLearner(0.5, 0.5, 100.0) -- Adjust gamma, alpha, maxQ as needed
```

Let's assume we want the game character to learn which weapon to use in different environments. Our conditions and actions might look like this:

- **Conditions (State Features)**:
  - Environment type (3 types): Forest (0), Desert (1), Snow (2)
  - Enemy type (2 types): Infantry (0), Tank (1)
- **Actions**:
  - Use handgun (1)
  - Use rocket launcher (2)
  - Use sniper rifle (3)

### 4.3 Constructing State Values with the pack() Method

```lua
local hints = {3, 2} -- Number of values for each condition
local environment = 1 -- Desert
local enemy = 0 -- Infantry
local stateValues = {environment, enemy}
local state = ML.QLearner:pack(hints, stateValues)
```

### 4.4 Choosing an Action

```lua
local action = qLearner:getBestAction(state)
if action == 0 then -- 0 indicates no best action
	-- Choose a random action if no best action exists
	action = math.random(1, 3)
end
```

### 4.5 Performing the Action and Receiving Rewards

```lua
local reward = 0
if action == 1 then
	-- Logic for using the handgun
	reward = 10 -- Hypothetical reward value
elseif action == 2 then
	-- Logic for using the rocket launcher
	reward = 20
elseif action == 3 then
	-- Logic for using the sniper rifle
	reward = 15
end
```

### 4.6 Updating Q-Values

```lua
qLearner:update(state, action, reward)
```

### 4.7 Training Loop

Place the steps above in a loop to allow the agent to continually learn and update its strategy. A typical Q-Learning training process can be illustrated with the following flowchart:

```mermaid
graph TD
	A[Start] --> B[Observe Environment<br>Input Random Condition Combination]
	B --> C[Use pack to Create State]
	C --> D[Select Best Action for Current State]
	D --> E{Is there a Best Action?}
	E -- Yes --> F[Perform Best Action]
	E -- No --> G[Randomly Choose Action]
	F --> H[Receive Reward]
	G --> H
	H --> I[Update Q-Value]
	I --> J[Next Round]
	J --> B
```

## 5. Complete Code Example

Below is a complete Lua code example demonstrating how to use `QLearner` in the Dora SSR engine to implement simple reinforcement learning. This example allows an agent to learn to choose the best weapon based on different environments and enemy types.

```lua
-- Import the ML module
local ML = require("ML")

-- Create a QLearner instance with gamma, alpha, and maxQ set
local qLearner = ML.QLearner(0.5, 0.5, 100.0)

-- Define the number of possible values for each condition (hints)
-- Environment types: Forest (0), Desert (1), Snowy (2) => 3 types
-- Enemy types: Infantry (0), Tank (1) => 2 types
local hints = {3, 2}

-- Define action set
-- Use Handgun (1), Use Rocket Launcher (2), Use Sniper Rifle (3)
local actions = {1, 2, 3}

-- Simulate multiple learning iterations
for episode = 1, 1000 do
	-- Randomly generate the current environment and enemy type
	local environment = math.random(0, 2) -- 0: Forest, 1: Desert, 2: Snowy
	local enemy = math.random(0, 1) -- 0: Infantry, 1: Tank

	-- Use pack() method to combine current conditions into a unique state value
	local stateValues = {environment, enemy}
	local state = ML.QLearner:pack(hints, stateValues)

	-- Attempt to get the best action for the given state
	local action = qLearner:getBestAction(state)

	-- If there is no best action, randomly select an action (exploration)
	if action == 0 then
		action = actions[math.random(#actions)]
	else
		-- With a certain probability, choose a random action to explore new strategies (ε-greedy strategy)
		local explorationRate = 0.1 -- 10% chance to explore
		if math.random() < explorationRate then
			action = actions[math.random(#actions)]
		end
	end

	-- Execute the action and get a reward based on the current environment and enemy type
	local reward = 0
	if action == 1 then -- Use Handgun
		if enemy == 0 then -- Against Infantry (advantage)
			reward = 20
		else -- Against Tank (disadvantage)
			reward = -10
		end
	elseif action == 2 then -- Use Rocket Launcher
		if enemy == 1 then -- Against Tank (advantage)
			reward = 30
		else -- Against Infantry (disadvantage)
			reward = 0
		end
	elseif action == 3 then -- Use Sniper Rifle
		if environment == 2 then -- In Snowy environment (advantage)
			reward = 25
		else
			reward = 10
		end
	end

	-- Update Q value
	qLearner:update(state, action, reward)
end

-- Test learning results
print("Learning complete, starting tests...")

-- Define test scenarios
local testScenarios = {
	{environment = 0, enemy = 0}, -- Forest, against Infantry
	{environment = 1, enemy = 1}, -- Desert, against Tank
	{environment = 2, enemy = 0}, -- Snowy, against Infantry
}

for i, scenario in ipairs(testScenarios) do
	local stateValues = {scenario.environment, scenario.enemy}
	local state = ML.QLearner:pack(hints, stateValues)
	local action = qLearner:getBestAction(state)

	-- Display test results
	local envNames = {"Forest", "Desert", "Snowy"}
	local enemyNames = {"Infantry", "Tank"}
	local actionNames = {"Handgun", "Rocket Launcher", "Sniper Rifle"}

	print(string.format("Scenario %d: Environment-%s, Enemy-%s => Recommended Use %s",
		i,
		envNames[scenario.environment + 1],
		enemyNames[scenario.enemy + 1],
		actionNames[action]))
end
```

### 5.1 Code Explanation

#### 1. Import Modules and Create a QLearner Instance

```lua
local ML = require("ML")
local qLearner = ML.QLearner(0.5, 0.5, 100.0)
```

Create a QLearner instance and set gamma, alpha, and maxQ.

- **gamma**: The discount factor, influencing the weight of future rewards.
- **alpha**: The learning rate, determining the influence of new information on Q-value updates.
- **maxQ**: The maximum limit of Q-values to prevent them from growing indefinitely.

#### 2. Define State Features and Action Set

```lua
local hints = {3, 2}
local actions = {1, 2, 3}
```

Define the number of possible values for each condition (hints) and the action set. Note that the minimum action number starts from 1.

#### 3. Run Learning Iterations

```lua
for episode = 1, 1000 do
	-- Learning process
end
```

Use loops to simulate multiple episodes, allowing the agent to learn from different states. You can set the number of episodes to 1000 or adjust it based on needs—more episodes can help the agent gain more experience.

#### 4. Randomly Generate Environment and Enemy Type

```lua
local environment = math.random(0, 2)
local enemy = math.random(0, 1)
```

Simulate different game scenarios where the environment and enemy types are randomly generated. This simulates diverse situations, helping the agent gain more experience.

#### 5. Construct State Value Using `pack()` Method

```lua
local stateValues = {environment, enemy}
local state = ML.QLearner:pack(hints, stateValues)
```

Combine multiple conditions generated in this episode into a unique state integer for storage and retrieval in the Q-table.

#### 6. Choose an Action

```lua
local action = qLearner:getBestAction(state)
if action == 0 then
	action = actions[math.random(#actions)]
else
	local explorationRate = 0.1
	if math.random() < explorationRate then
		action = actions[math.random(#actions)]
	end
end
```

Use the `getBestAction(state)` method to get the known best action for the current state and employ an `ε-greedy strategy` for exploration. This strategy balances exploiting known information and exploring new options.

#### 7. Execute Action and Get Reward

```lua
local reward = 0
if action == 1 then
	-- Calculate reward based on action and current state
end
```

Set the reward based on game logic. In a real game, the reward might be calculated after a series of actions.

#### 8. Update Q Value

```lua
qLearner:update(state, action, reward)
```

Update the Q value with the received reward to improve strategy, allowing the agent to select optimal actions in different states.

#### 9. Test the Learning Outcome

```lua
for i, scenario in ipairs(testScenarios) do
	-- Test different scenarios to view agent decisions
end
```

Perform tests and display the agent's decisions across different scenarios. Note that the decisions may vary due to randomly generated scenarios.

### 5.2 Sample Output

```
Learning completed, starting tests...
Scenario 1: Environment-Forest, Enemy-Infantry => Suggested weapon: Pistol
Scenario 2: Environment-Desert, Enemy-Tank => Suggested weapon: Rocket Launcher
Scenario 3: Environment-Snow, Enemy-Infantry => Suggested weapon: Sniper Rifle
```

## 6. Summary

With this complete code example, we achieved the following goals:

- **Using the QLearner:pack() Method**: Combined multiple conditions into a unique state value for easy storage and retrieval in the Q-table.
- **Built a Reinforcement Learning Loop**: Allowed the agent to try actions, gain rewards, and update its strategy across different states.
- **Implemented ε-greedy Strategy**: Balanced following known best strategies while maintaining exploration.
- **Tested Learning Outcomes**: Validated whether the agent learned to select optimal actions in predefined scenarios.

We hope this example helps you understand how to use the Q-Learning algorithm in the Dora SSR engine to develop game mechanics. For any questions, feel free to join our community for discussion!