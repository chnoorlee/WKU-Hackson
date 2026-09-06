# Loading and Running Yarn Scripts

Welcome to the YarnRunner library usage tutorial. In this guide, we'll show you how to load and run the Yarn narrative script you wrote in the [previous tutorial](/docs/tutorial/Writing%20Game%20Dialogue/introduction-to-yarn).

## 1. Initializing YarnRunner

First, make sure you have imported all the necessary modules.

```yue title="init.yue"
_ENV = Dora
import "YarnRunner"
```

To ensure we can locate the Yarn script, we need to set the correct search path. If the Yarn script and program modules are in the same directory, you can add the following code:

```yue title="init.yue"
path = Path\getScriptPath ...
Content\insertSearchPath 1, path
```

Next, assuming our Yarn file is named "tutorial.yarn" and the starting node title is "Start", we write the following code:

```yue title="init.yue"
runner = YarnRunner "tutorial.yarn", "Start"
```

## 2. Executing and Displaying Narrative Content

We define an `advance` function that can read and display text or options from the Yarn script. Based on the content, it can also display the character's name:

```yue title="init.yue"
-- The advance function takes an optional integer representing the player's choice index.
-- For the first call or when no choice is needed, we pass nil.
advance = (option) ->

	-- First, call runner\advance to get the next part of the Yarn script.
	-- This returns two values: an action type and a result.
	action, result = runner\advance option

	-- Handle the result based on the action type.
	switch action when "Text"

		-- If the action is "Text", the result will be a TextResult object,
		-- containing the text and any associated markers (e.g., character names).
		-- Check the markers, extract the character's name (if present), and print the text.
		charName = ""
		if result.marks
			for mark in *result.marks
				switch mark when {name: attr, attrs: {:name}}
					charName = "#{name}: " if attr == "char"
		print charName .. result.text

	when "Option"

		-- If the action is "Option", the result will be an OptionResult object,
		-- containing one or more options. Iterate over the options and print them,
		-- allowing the player to select them later.
		for i, op in ipairs result
			print "[#{i}]: #{op.text}" if op

	else

		-- For other actions (like errors), print the result directly.
		print result
```

## 3. Starting the Narrative

To start the narrative, simply call the `advance` function without any arguments:

```yue title="init.yue"
advance!
```

## 4. Handling User Input

To enable player interaction, we need a node to capture and respond to user input. We create a node and assign it a signal slot named "go". When this signal is triggered, it will call the `advance` function again, passing the player's choice:

```yue title="init.yue"
with Node!
	\gslot "go", (option) -> advance option
	\addTo Director.entry
```

Here, we registered a global event listener for quick testing. In actual game development, you'd need to write the UI interaction logic. Once this "go" global event listener is set, you can use the Dora SSR console to input `emit 'go'` to continue the dialogue, or `emit 'go', 1` to select dialogue branches for interactive test runs.

## 5. Adding Custom Commands and State

You can add custom commands and initial state variables by passing the `command` and `state` parameters to `YarnRunner`. The `command` parameter is a Lua table containing callback functions for commands, and `state` is a table with predefined variables. Here's an example:

```yue title="init.yue"
runner = YarnRunner "tutorial.yarn", "Start", {
	playerScore: 100
}, {
	print: print
}
```

Then, in the Yarn script, you can modify initial variable values using `<<set $variable = expression>>` and print variables using the custom command `<<print $variable>>`:

```html title="Test Dialogue Node"
<<set $playerScore = $playerScore + 200>>
<<print $playerScore>>
```

## 6. Debugging and Troubleshooting

Yarn scripts are usually edited many times while the story is still changing. Dora SSR provides two quick feedback paths: Web IDE syntax checking while editing, and Yarn Tester for running through a saved `.yarn` file.

### 6.1 Check Yarn Files in the Web IDE

When you edit a `.yarn` file as text, the Web IDE checks the file with the Yarn compiler and marks syntax errors in the editor. The error result includes a message, line, column, and node name, so the marker can point back to the source text.

When you use the visual Yarn editor, the editor checks each node body separately. If a node has invalid Yarn syntax, the check result is reported with the node title before the compiler message, making it easier to find the broken node.

### 6.2 Run a File with Yarn Tester

Open **Yarn Tester** from Dora SSR's development tools after saving your `.yarn` file. The tester scans the writable project path for files ending in `.yarn`. If you add a new Yarn file while the tester is already open, reload the tester so the file list is scanned again.

In Yarn Tester:

- Use **Filter** to narrow the file list.
- Use **File** to select the `.yarn` file to run.
- Use **Reload** to recreate the runner after changing and saving the file.
- The tester starts from the `Start` node.
- Text output appears in the scroll area, options appear as numbered choices, and commands are displayed as `[command]: commandName args`.
- The **Variables** area shows the runner state. During testing, initial variables can be loaded from leading `// variables:` comments in the Yarn file.

### 6.3 Common Error Symptoms

**Missing node**: If a script jumps to a node that does not exist, `YarnRunner` returns an error like `node "MissingNode" is not exist`. Check the target of `<<jump ...>>` and make sure a node with the same `title:` exists. Node titles are matched by name, so spelling matters.

**Choice out of range**: If your code calls `runner:advance(3)` while the current option list has only two choices, the runner returns `choice 3 is out of range`. Display the options returned by the `"Option"` action and only pass one of the shown indexes.

**Choosing when there is no option**: If your code passes a choice while the story is showing plain text, the runner returns `there is no option to choose`. Call `advance()` without an argument to continue normal text, and pass a number only after the runner returns `"Option"`.

**Continuing past a required option**: If the story is waiting for a choice and your code calls `advance()` without one, the runner returns `required a choice to continue`. Keep the option UI active until the player selects one of the available branches.

**Script syntax error**: Invalid Yarn syntax is reported by the editor check or by Yarn Tester when it reloads the file. In Yarn Tester, load failures appear as `failed to load file ...` followed by the compiler error. Fix the reported node and line first, save the file, then use **Reload**.

### 6.4 How Runtime Error Lines Map Back to Yarn Text

Some errors happen after a node has already been compiled and the story is running. Internally, `YarnRunner` compiles each Yarn node body to Lua. The generated Lua keeps comments that record the original Yarn line numbers. When a Lua runtime error happens, `YarnRunner` rewrites the Lua error line back to the Yarn node line and returns an error in this shape:

```text
NodeTitle:line: message
```

For example, `Start:5: attempt to call a nil value` means line 5 inside the `Start` node body, not necessarily line 5 of the whole `.yarn` file. To locate it, find `title: Start`, then count from the first line after that node's `---` separator. Web IDE file checks may also include the full source line, column, and node name when they validate the whole `.yarn` file.

### 6.5 Minimal Broken Example

This file has two problems: it jumps to a missing node, and it has two options. If game code later tries to choose option `3`, the choice is out of range.

```html title="broken.yarn"
title: Start
---
You see a locked door.
-> Open it
	<<jump OpenDoor>>
-> Leave
	You step away.
===
```

What you may see:

- After choosing option `1`: `node "OpenDoor" is not exist`.
- If code calls `advance(3)` on the option list: `choice 3 is out of range`.

Here is the fixed version:

```html title="fixed.yarn"
title: Start
---
You see a locked door.
-> Open it
	<<jump OpenDoor>>
-> Leave
	You step away.
===

title: OpenDoor
---
The door opens with a soft click.
===
```

After saving the fixed file, reload it in Yarn Tester and choose option `1` again. The story should now continue into `OpenDoor`.

## 7. Conclusion

Now, you have set up all the necessary code to load and run Yarn narrative scripts. You can run the above script to begin your interactive narrative, where players can interact by selecting options. Happy creating!