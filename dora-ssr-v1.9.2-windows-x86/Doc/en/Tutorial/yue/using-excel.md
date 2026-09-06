# Loading Data from Excel Files

In game development, configuration data is often stored in tables, and Excel files are commonly used due to their intuitive nature and ease of editing. These files allow game designers or team members responsible for character design to maintain data efficiently. This article will introduce how to use the `Content.loadExcel` and `Content.loadExcelAsync` functions provided by the Dora SSR engine to load Excel `.xlsx` files and convert them into Lua tables for use in games.

## 1. Function Overview

The Dora SSR engine provides two functions to load Excel files:

- `Content.loadExcel`: Synchronous loading of Excel files.
- `Content.loadExcelAsync`: Asynchronous loading of Excel files.

Both functions work similarly, with the key difference being whether the current thread is blocked.

### 1.1 Function Signatures

### 1.2 Parameter Descriptions

- `filename`: The name of the Excel file to read (string).
- `sheetNames`: Optional parameter, a list of sheet names to read from the Excel file. If not provided, all sheets are read by default.

### 1.3 Return Values

- Returns a Lua table on success, with keys as sheet names and values as the data rows.
- Returns `nil` on failure.

## 2. Step-by-Step Guide

### 2.1 Preparing the Excel File

Ensure that your Excel file is located in the game's resource directory or an accessible path. Assume the file to load is named `config.xlsx` and contains two sheets, with the first row of each sheet being the header that defines the meaning of each column. In practice, you can add more columns and rows as needed for your game.

* **Enemies** sheet (Enemy Configuration):

	| EnemyID | EnemyName | Health | Attack |
	|---------|-----------|--------|--------|
	| 1 | Goblin | 100 | 10 |
	| 2 | Orc | 200 | 20 |
	| 3 | Troll | 300 | 30 |
	| 4 | Dragon | 1000 | 100 |

	- **EnemyID**: The unique identifier for the enemy.
	- **EnemyName**: The name of the enemy.
	- **Health**: The health points of the enemy.
	- **Attack**: The attack power of the enemy.

* **Items** sheet (Item Configuration):

	| ItemID | ItemName | Type | Value |
	|--------|----------|------|-------|
	| 101 | Health Potion | Consumable | 50 |
	| 102 | Mana Potion | Consumable | 30 |
	| 103 | Sword | Weapon | 150 |
	| 104 | Shield | Armor | 100 |

	- **ItemID**: The unique identifier for the item.
	- **ItemName**: The name of the item.
	- **Type**: The type of the item (e.g., consumable, weapon, armor).
	- **Value**: The item's value or effect.

### 2.2 Using `loadExcel` for Synchronous Loading

```yue
_ENV = Dora

-- Load the specified Excel file
if excelData := Content\loadExcel "config.xlsx"
	-- Access data from the "Enemies" sheet
	if enemiesData := excelData["Enemies"]
		for [enemyID, enemyName] in *enemiesData
			print "Enemy ID: {enemyID}, Name: {enemyName}"

	-- Access data from the "Items" sheet
	if itemsData := excelData["Items"]
		for [itemID, itemName] in *itemsData
			print "Item ID: {itemID}, Name: {itemName}"
else
	print "Failed to load Excel file."
```

#### Parsing the Returned Data Table

The returned `excelData` is a nested Lua table with the following structure:

```yue
{
	"Enemies": [
		[ "EnemyID", "EnemyName", "Health", "Attack" ],
		[ 1, "Goblin", 100, 10 ],
		[ 2, "Orc", 200, 20 ],
		[ 3, "Troll", 300, 30 ],
		[ 4, "Dragon", 1000, 100 ],
	],
	"Items": [
		[ "ItemID", "ItemName", "Type", "Value" ],
		[ 101, "Health Potion", "Consumable", 50 ],
		[ 102, "Mana Potion", "Consumable", 30 ],
		[ 103, "Sword", "Weapon", 150 ],
		[ 104, "Shield", "Armor", 100 ],
	],
}
```

### 2.3 Using `loadExcelAsync` for Asynchronous Loading

If you want to avoid blocking the current thread, you can use asynchronous loading:

```yue
_ENV = Dora

thread ->
	-- Asynchronously load the Excel file
	if excelData := Content\loadExcelAsync "config.xlsx"
		-- The logic for processing data is the same as in synchronous loading
		if enemiesData := excelData["Enemies"]
			-- ...
	else
		print "Failed to asynchronously load Excel file."
```

Note: `loadExcelAsync` must be called within a coroutine, so we use the `thread` module to create a new coroutine and execute the asynchronous load operation within it.

### 2.4 Loading Specific Sheets

If you only want to load specific sheets, you can use the `sheetNames` parameter:

```yue
_ENV = Dora

-- Load only the "Enemies" sheet
if excelData := Content\loadExcel "config.xlsx", ["Enemies"]
	if enemiesData := excelData["Enemies"]
		-- ...
else
	print "Failed to load data from the specified sheet."
```

### 2.5 Error Handling

Always check if the return value is `nil` to handle potential loading failures:

```yue
_ENV = Dora

unless excelData := Content\loadExcel "nonexistent.xlsx"
	print "Failed to find or load Excel file."
```

## 3. Full Example

Below is a complete example that demonstrates how to load an Excel file and convert its data into game configuration tables:

```yue
_ENV = Dora

-- Define a function to parse Excel data
parseExcelData = (excelData): config ->
	config = {}

	-- Parse the "Enemies" sheet
	if excelData["Enemies"]
		config.enemies = []
		enemiesData = excelData["Enemies"]
		-- Skip the first row as it's the header
		for rowIndex = 2, #enemiesData
			row = enemiesData[rowIndex]
			config.enemies[] =
				id: row[1],
				name: row[2],
				health: row[3],
				attack: row[4],

	-- Parse the "Items" sheet
	if excelData["Items"]
		config.items = []
		itemsData = excelData["Items"]
		-- Skip the first row as it's the header
		for rowIndex = 2, #itemsData
			row = itemsData[rowIndex]
			config.items[] =
				id: row[1],
				name: row[2],
				type: row[3],
				value: row[4],

-- Synchronously load the Excel file
if excelData := Content\loadExcel "config.xlsx"
	gameConfig = parseExcelData(excelData)
	-- Now gameConfig contains the parsed configuration data
	print "Game configuration successfully loaded."
else
	print "Failed to load game configuration."
```

## 4. Notes

- The first row of an Excel sheet is typically used as the header, containing the field names. You can dynamically map fields based on the header during data parsing.
- Ensure the Excel file path and name are correct, the file exists, and the format is valid.
- For large Excel files, asynchronous loading can help avoid blocking the main thread and improve performance.
- For Excel files with a large amount of data (over tens of thousands of rows), consider importing the data into a database for better query and processing efficiency. Refer to the tutorial [Using SQLite Database](using-database#7-importing-excel-data-into-the-database) for more details.

## 5. Summary

By using the `loadExcel` and `loadExcelAsync` functions in the Dora SSR engine, you can easily load configuration data from Excel files into Lua tables for use in your game. With proper parsing and encapsulation, these data can be transformed into the configuration structures needed for your game.

We hope this tutorial helps you manage configuration data in your game development process.