# Column

`gw_utilities/modules/gw_column.rb`

Provides methods that allow `String` convertible values to be displayed in columns. This is particularly useful when trying to display tabulated data on the command line.

## column_width

Returns the length of the longest `String` in an `Array`. This is used to determine how wide a column would need to be to accommodate all Array elements.

## Arguments

| Name   | Class(es) | Default | Description |
| ------ | --------- | ------- | ----------- |
| rows   | Array     |         | String-like objects to be displayed as a column |
| RETURN | Fixnum    |

### Examples

Any variable Class that can be converted to a String is accepted as a content of the rows Array:
```ruby
rows = ["string", 12.23921, :symbol, false]
column_width(rows)
=> 8
```

## column_format

Converts a 2-dimensional table-like `Array` into an Array of column formatted rows.

### Arguments

| Name         | Class(es) | Default | Description |
| ------------ | --------- | ------- | ----------- |
| table        | Array     |         | Table-like Array of rows, each row an Array of columns |
| dividers     | Array     | `[]`    | Strings to separate each column with, starting before the first column |
| all_dividers | boolean   | `false` | Whether to include dividers even when the columns to the right are empty |
| RETURN       | Array     |         | |

### Rules

- The **table** argument is expected to be a 2-dimensional Array that represents the table-like structure of the data. The outermost Array elements are rows. These in turn should be Arrays which contain the String-like values for each column / cell on that row. See the examples below for more information.
- The **dividers** argument specifies unique dividers to place before each column. As a result the first String in this Array comes before the first column. If there are not enough dividers for the amount of columns, no divider is added beyond those provided.
- **all_dividers** prevents dividers from being added beyond the last column on each row. Please note that this will mean that any divider provided to be displayed on the far right on the table will be omitted.

### Examples

The following variables will be used in these examples:
```ruby
table = [
  ["one", "two", "three", "four"],
  ["alpha", "beta", "gamma", "omega"],
  ["red", "green", "mahogany"]
]
dividers = ["| ", " | ", " | ", " | ", " |"]
```

Default arguments. Note that the far-right divider is omitted due to **all_dividers** being set to false:
```ruby
column_format(table, dividers)
=> [
  "| one   | two   | three    | four",
  "| alpha | beta  | gamma    | omega",
  "| red   | green | mahogany"
]
```

With **all_dividers** set to true:
```ruby
column_format(table, dividers, true)
=> [
  "| one   | two   | three    | four  |",
  "| alpha | beta  | gamma    | omega |",
  "| red   | green | mahogany |       |"
]
```

## column_list

Displays an `Array` of String-like variables in multiple columns. This is useful when columns are a more efficient way of displaying information but it does not already have a predefined structure.

### Arguments


| Name     | Class(es) | Default | Description |
| -------- | --------- | ------- | ----------- |
| list     | Array     |         | Strings to display in columns |
| columns  | Fixnum    | `4`     | Maximum amount of columns to display
| width    | Fixnum    | `75`    | Constricting width on number of columns
| dividers | Array     | `[]`    | Left, in-between, and right column separators
| RETURN   | Array     |         | |

### Rules

- **columns** is only the maximum amount of columns that can be displayed. The **width** argument can reduce the amount of columns down to 1 at minimum. As all columns are the same width (that of the widest list String), this is calculated by seeing how wide **columns** columns and all dividers would be, and reducing the amount of columns until it's width is below **width**.

### Examples

The following variables are used in this example:
```ruby
dividers = ["| ", " : ", " |"]
list = %w(one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty)
```

**SECTION INCOMPLETE**