# Using SQLite Database

&emsp;&emsp;Dora SSR engine provides developers with integrated [SQLite](https://www.sqlite.org) database support, which can be used to manage and query large amounts of game data, as well as store critical game data persistently. This tutorial will guide you from scratch, step by step, through the process of using Dora's database features.

## 1. Introduction

&emsp;&emsp;In game development, you often need to manage large amounts of game data such as player information, game items, and level configurations. Using a database allows you to store and retrieve this data efficiently. The Dora SSR engine integrates the SQLite database and provides a simple and easy-to-use interface for database operations.

### 1.1 Getting Started with Database Operations

&emsp;&emsp;Before we begin, make sure you understand the following concepts:

- **Database**: A system that stores and manages data.
- **Table**: The structure in a database that stores data, consisting of rows and columns.
- **Row**: A record in a table.
- **Column**: A collection of a specific attribute in the table.

## 2. Introduction to the DB Class

&emsp;&emsp;The `DB` class is the core class provided by Dora for database operations. With this class, you can perform the following actions:

- Check if a table exists
- Execute SQL queries
- Insert, update, and delete data
- Execute transactions
- Perform asynchronous operations

### 2.1 Important Concepts Related to the DB Class

- **Column**: Represents a database column type, which can be `integer`, `number`, `string`, or `boolean`.

	:::tip Special Note
	In Dora SSR, the boolean type in the database column only supports the `false` value to represent a NULL value in the database. If you need to store boolean values in the database, use the numeric types `0` and `1` to represent `false` and `true`.
	:::

- **Row**: Represents a row of data in the database, usually a Lua table containing multiple `Columns`.
- **SQL**: Represents an SQL query, which can be a string or a string with parameters in combination with a parameter table.

## 3. Basic Operation Examples

&emsp;&emsp;Let's get familiar with the usage of the `DB` class through some basic operations.

### 3.1 Checking if a Table Exists

&emsp;&emsp;Before working with the database, you typically need to confirm whether a table exists. You can use the `exist` method:

```lua
local tableExists = DB:exist("test_table")
print(tableExists and "Table exists" or "Table does not exist")
```

### 3.2 Creating and Dropping a Table

&emsp;&emsp;You can use the `exec` method to execute SQL statements to create and drop tables:

```lua
-- Drop the table named test_table if it exists
DB:exec("DROP TABLE IF EXISTS test_table")

-- Create the table named test_table
DB:exec("CREATE TABLE test_table (id INTEGER PRIMARY KEY, value TEXT)")
```

### 3.3 Inserting Data

&emsp;&emsp;You can insert data into a table using the `insert` method:

```lua
local success = DB:insert("test_table", {
	{1, "Hello"},
	{2, "World"}
})
print(success and "Insert successful" or "Insert failed")
```

### 3.4 Querying Data

&emsp;&emsp;You can query data from the table using the `query` method:

```lua
local results = DB:query("SELECT * FROM test_table")
for _, row in ipairs(results) do
	print("ID:", row[1], "Value:", row[2])
end
```

### 3.5 Updating and Deleting Data

&emsp;&emsp;You can perform updates and deletions using the `exec` method:

```lua
-- Update data
local rowsAffected = DB:exec("UPDATE test_table SET value = ? WHERE id = ?", {"Hello Dora", 1})
print("Rows updated:", rowsAffected)

-- Delete data
rowsAffected = DB:exec("DELETE FROM test_table WHERE id = ?", {2})
print("Rows deleted:", rowsAffected)
```

## 4. Transactions

&emsp;&emsp;A transaction is a set of operations that either all succeed or, if an error occurs, none are executed. In Dora SSR, you can use the `transaction` method to execute transactions:

```lua
local sqlStatements = {
	"INSERT INTO test_table (id, value) VALUES (3, 'Dora')",
	"INSERT INTO test_table (id, value) VALUES (4, 'SSR')"
}
local transactionSuccess = DB:transaction(sqlStatements)
print(transactionSuccess and "Transaction successful" or "Transaction failed")
```

## 5. Asynchronous Operations

&emsp;&emsp;To avoid blocking the main thread, Dora SSR provides asynchronous methods such as `insertAsync`, `queryAsync`, and `execAsync` to perform database operations in a background thread.

```lua
thread(function()
	-- Asynchronous insert data
	DB:insertAsync("test_table", {
		{5, "Async"},
		{6, "Operation"}
	})

	-- Asynchronous query data
	local asyncResults = DB:queryAsync("SELECT * FROM test_table")
	if asyncResults then
		for _, row in ipairs(asyncResults) do
			print("Async Query - ID:", row[1], "Value:", row[2])
		end
	end
end)
```

## 6. Creating a New Schema

&emsp;&emsp;In real-world projects, you may need to create a new schema to store and manage game data separately instead of storing everything in the same default database. A schema is a logical structure in the database, like a grouping of multiple tables. You can use the `exec` method to create schemas.

```lua
-- Define the full path of the file to store the new schema data, it must be in the engine's writable directory
local schemaFile = Path(Content.writablePath, "game_data.db")

-- Create schema,
-- the database file will be automatically created if it doesn't exist,
-- and will be added to the current database connection if it does exist
DB:exec("ATTACH DATABASE '" .. schemaFile .. "' AS game_data")

-- Create tables in the new schema and insert data
DB:exec("CREATE TABLE game_data.player (id INTEGER PRIMARY KEY, name TEXT)")
DB:insert("game_data.player", {false, "Dora"})

-- Query the data from the new schema
DB:query("SELECT * FROM game_data.player")

-- Detach schema so that the data from the new schema is no longer accessible
DB:exec("DETACH DATABASE game_data")
```

:::tip Summary
The default schema library provided by the Dora SSR engine will be stored in the file corresponding to the path `Path(Content.writablePath, "dora.db")`. When accessing tables, if you do not prefix the table name, it means accessing tables in the default schema. If you need to create a new schema and store it in a separate database file for easier migration, you can use `ATTACH DATABASE` and `DETACH DATABASE` for this operation.
:::

## 7. Importing Excel Data into the Database

&emsp;&emsp;In game development, Excel spreadsheets are often used to manage game data. When the data volume in Excel becomes large and complex queries such as data associations are needed, using a database becomes more efficient. Dora SSR engine provides convenient functionality to import Excel data into the database, making it easier for developers to manage game data.

### 7.1 Prerequisites

- **Consistent Table Structure and Excel Sheet Structure**: Ensure that the table structure (

column names and column types) in the database matches the data columns in the Excel worksheet.
- **Excel File Format**: Currently supported Excel file format is `.xlsx`.

### 7.2 Example Steps

&emsp;&emsp;Let's walk through an example of how to import Excel data into the database.

#### Create Database Table

&emsp;&emsp;Suppose we have an Excel file `data.xlsx` containing a worksheet `Items`, which records game item information, including item ID, name, and description. First, we need to create the corresponding table in the database:

```lua
DB:exec([[
	CREATE TABLE IF NOT EXISTS Items (
		id INTEGER PRIMARY KEY,
		name TEXT,
		description TEXT
	)
]])
```

#### Prepare Excel File

&emsp;&emsp;Ensure that your Excel file `data.xlsx` is located in an accessible path in the project, and that the first row of the worksheet `Items` contains the column names, corresponding to the column names in the database table:

| id | name | description |
| ---- | ------ | ------------ |
| 1 | Sword | Basic sword |
| 2 | Shield | Basic shield |
| ... | ... | ... |

#### Use `DB.insertAsync` to Import Data

```lua
thread(function()
	local success = DB:insertAsync(
		{"Items"},
		"data.xlsx",
		2
	)
	if success then
		print("Excel data imported successfully!")
	else
		print("Excel data import failed!")
	end
end)
```

#### Verify Import Results

&emsp;&emsp;You can query the database to verify that the data was imported successfully:

```lua
local items = DB:query("SELECT * FROM Items")
for _, item in ipairs(items) do
	print("ID:", item[1], "Name:", item[2], "Description:", item[3])
end
```

### 7.3 Using a Custom Worksheet Name

&emsp;&emsp;If the worksheet name in your Excel file differs from the table name in the database, you can specify the corresponding relationship:

```lua
thread(function()
	local tableSheets = {
		{"Items", "GameItems"}  -- The database table name is "Items", corresponding to the Excel worksheet name "GameItems"
	}
	local success = DB:insertAsync(
		tableSheets,
		"data.xlsx",
		2
	)
	if success then
		print("Excel data imported successfully!")
	else
		print("Excel data import failed!")
	end
end)
```

### 7.4 Notes

- **Data Type Matching**: Ensure that the data types in Excel are compatible with the column types in the database table, for example, numeric data should correspond to INTEGER or REAL types, and text data should correspond to TEXT types.
- **Handling Dates and Boolean Values**: Dates and boolean values in Excel need to be appropriately converted before importing to match the database column types.
- **Error Handling**: The `insertAsync` method will return `false` if an error occurs during the import process. It is recommended to add error logs in actual applications to capture and handle potential exceptions.

## 8. Full Sample Code

&emsp;&emsp;Below is a complete sample code, which we will break down line by line.

```lua
local DB <const> = require("DB")
local thread <const> = require("thread")

-- Use a transaction to create a table and insert initial data
local sqls = {
	"DROP TABLE IF EXISTS test",
	"CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT)",
	{
		"INSERT INTO test VALUES(?, ?)",
		{
			{false, "hello"},
			{false, "world"},
			{false, "ok"}
		}
	}
}

local result = DB:transaction(sqls)
print(result and "Success" or "Failure")

-- Check if the table exists
print(DB:exist("test"))

-- Query and print data
p(DB:query("SELECT * FROM test", true))

-- Delete and update data
print("row changed:", DB:exec("DELETE FROM test WHERE id > 1"))
print("row changed:", DB:exec("UPDATE test SET value = ? WHERE id = 1", {"hello world!"}))

-- Perform asynchronous operations
thread(function()
	-- Asynchronous insert data
	print("insert async")
	local data = {}
	local count = 1
	for k in pairs(_G) do
		data[count] = {false, k}
		count = count + 1
	end
	p(DB:insertAsync("test", data))

	-- Asynchronous query data
	print("query async...")
	local items = DB:queryAsync("SELECT value FROM test WHERE value NOT LIKE 'hello%' ORDER BY value ASC")
	local rows = {}
	if items then
		count = 1
		for i = 1, #items do
			local item = items[i]
			rows[count] = item[1]
			count = count + 1
		end
	end
	p(rows)
end)
```

### 8.1 Code Breakdown

1. **Import Modules**:

	```lua
	local DB <const> = require("DB")
	local thread <const> = require("thread")
	```

	- The `DB` module is for database operations.
	- The `thread` module is used for creating asynchronous threads.

2. **Define SQL Statement List**:

	```lua
	local sqls = {
		"DROP TABLE IF EXISTS test",
		"CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT)",
		{
			"INSERT INTO test VALUES(?, ?)",
			{
				{false, "hello"}, -- Using false as a placeholder for NULL value in the database, id will auto-increment
				{false, "world"},
				{false, "ok"}
			}
		}
	}
	```

	- Drop the table named `test` if it exists.
	- Create a table named `test` with two columns: `id` and `value`.
	- Insert three rows of data. The `id` column will auto-increment (using `false` as a placeholder for NULL), and the `value` column will have `"hello"`, `"world"`, and `"ok"` values.

3. **Execute Transaction**:

	```lua
	local result = DB:transaction(sqls)
	print(result and "Success" or "Failure")
	```

	- Use the `transaction` method to execute the SQL statements as a transaction, ensuring atomicity.
	- Print the result of the transaction.

4. **Check if Table Exists**:

	```lua
	print(DB:exist("test"))
	```

	- Check if the `test` table exists.

5. **Query and Print Data**:

	```lua
	p(DB:query("SELECT * FROM test", true))
	```

	- Query all data from the `test` table, `true` indicates that the result includes the column names.
	- Use the `p` function (a special engine-provided print function) to print the query result.

6. **Delete and Update Data**:

	```lua
	print("row changed:", DB:exec("DELETE FROM test WHERE id > 1"))
	print("row changed:", DB:exec("UPDATE test SET value = ? WHERE id = 1", {"hello world!"}))
	```

	- Delete rows where `id` is greater than 1.
	- Update the row where `id` is equal to 1, changing the `value` to `"hello world!"`.
	- Print the number of affected rows.

7. **Asynchronous Operations**:

	```lua
	thread(function()
		-- Asynchronous insert data
		print("insert async")
		local data = {}
		local count = 1
		for k in pairs(_G) do
			data[count] = {false, k}
			count = count + 1
		end
		p(DB:insertAsync("test", data))

		-- Asynchronous query data
		print("query async...")
		local items = DB:queryAsync("SELECT value FROM test WHERE value NOT LIKE 'hello%' ORDER BY value ASC")
		local rows = {}
		if items then
			count = 1
			for i = 1, #items do
				local item = items[i]
				rows[count] = item[1]
				count = count + 1
			end
		end
		p(rows)
	end)
	```

	- Create a new thread to perform asynchronous operations.
	- **Asynchronous Insert**: Insert global variable names into the `test` table.
	- **Asynchronous Query**: Query values from the `test` table that don't start with `"hello"` and sort them in alphabetical order.
	- **Process Results**: Extract the `value` from the query results and store it in the `rows` table.
	- Print the results.

## 9. Summary

&emsp;&emsp;In this tutorial, you have learned how to use Dora SSR engine's SQLite database functionality to perform basic data operations. With these interfaces, you can efficiently manage various data in your games, providing players with a richer gaming experience.

**Tips**:

- Always handle potential errors when performing database operations.
- Using transactions ensures atomicity of data operations, avoiding data inconsistency.

**Next Steps**:

- Learn more advanced SQL syntax such as JOINs and subqueries. For detailed information on SQLite SQL syntax, refer to the [official SQLite documentation](https://www.sqlite.org/lang.html).
- Learn how to optimize database queries for better performance.
- Explore how to organize and manage database code in real-world projects.