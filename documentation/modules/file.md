# File

`gw_utilities/modules/gw_file.rb`

Methods for reading from and writing to plain text files.

## file_read

Reads the contents of a file. This method provides a variety of ways to interpret the plain text content of the file, including specifying the class of the return value.

### Arguments

| Name   | Class(es)      | Default | Description |
| ------ | -------------- | ------- | ----------- |
| file   | String         |         | File path of the file to be read |
| opts   | Hash           | `{}`    | File reading options as defined below |
| RETURN | String / Array |

| Opt Key     | Class(es) | Default | Description |
| ----------- | --------- | ------- | ----------- |
| comment     | String    | `nil`   | If specified, exclude everything on a line after this character |
| empty_lines | boolean   | `true`  | Include lines with nothing but whitespace content |
| format      | Class     | `Array` | Whether to output a single `String`, or to separate it by line break into an `Array` |
| whitespace  | boolean   | `true`  | Include leading and trailing whitespace |

### Examples

For the purpose of these examples, a file called **file_read.txt** is being read. Here are it's contents:

```
line one
#line two
line #three

  line five
```

Default options:
```ruby
file_read("file_read.txt")
=> ["line one", "#line two", "line #three", "", "  line five"]
```

String format:
```ruby
file_read("file_read.txt", {format: String})
=> "line one\n#line two\nline #three\n\n  line five"
```

Recognising the hash `#` as a comment and excluding empty lines and whitespace:
```ruby
file_read("file_read.txt", {comment: "#", empty_lines: false, whitespace: false})
=> ["line one", "line", "line five"]
```
