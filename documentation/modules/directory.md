# Directory

`gw_utilities/modules/gw_directory.rb`

A collection of methods that interact with directories and their contents.

## directory_contents

Returns an `Array` of files and/or directories starting with the directory argument. This method can run recursively including up to a limited depth.

### Arguments

| Name        | Class(es) | Default | Description |
| ----------- | --------- | ------- | ----------- |
| directory   | String    |         | File path of the directory used as the starting point |
| blacklist   | Array     | `[]`    | `Regexp` collection. When matched, files and directories are omitted. An omitted directory is not searched deeper |
| files       | boolean   | `true`  | Whether to include file paths in the return Array |
| directories | boolean   | `false` | Whether to include directory paths in the return Array |
| levels      | Fixnum    | 0       | How many levels deep to return directory contents for. `0` means all levels |
| error       | boolean   | `false` | Throw an error and exit code execution when a directory cannot be accessed. If false the directory is instead ignored |
| RETURN      | Array     |         | |

### Examples

For the purpose of these examples, the following directory structure is being queried:

```
C:/toplevel
- secondlevel
- - image.jpg
- - system_file.dat
- - text_file.txt
- secondlevel2
- - thirdlevel
- - - deep_file.txt
```

Default arguments. This lists all files with no limitations:
```ruby
directory_contents("C:/toplevel")
=> [
  "C:/toplevel/secondlevel/image.jpg",
  "C:/toplevel/secondlevel/system_file.dat",
  "C:/toplevel/secondlevel/text_file.txt",
  "C:/toplevel/secondlevel2/thirdlevel/deep_file.txt"
]
```

Return directories only, not files:
```ruby
directory_contents("C:/toplevel", files: false, directories: true)
=> [
  "C:/toplevel/secondlevel",
  "C:/toplevel/secondlevel2",
  "C:/toplevel/secondlevel2/thirdlevel"
]
```

Using regular expression to exclude `.txt` files:
```ruby
regexps = [/\.txt$/i]
directory_contents("C:/toplevel", blacklist: regexps)
=> [
  "C:/toplevel/secondlevel/image.jpg",
  "C:/toplevel/secondlevel/system_file.dat"
]
```

Limiting the amount of levels to recursively search:
```ruby
directory_contents("C:/toplevel", levels: 2)
=> [
  "C:/toplevel/secondlevel/image.jpg",
  "C:/toplevel/secondlevel/system_file.dat",
  "C:/toplevel/secondlevel/text_file.txt"
]
```

## directory_parts

Treat a path as an Array and return a specified range as a `String`.

### Arguments


| Name      | Class(es)      | Default | Description |
| --------- | -------------- | ------- | ----------- |
| path      | String         |         | Path to return a portion of |
| range     | Range / Fixnum |         | Parts of path to return when viewed as an Array |
| delimiter | String         | `"/"`   | Character to split path by to create an Array
| RETURN    | String         |         | |

### Examples

The following path will be used in the following examples:
```ruby
path = "C:/Users/test/Documents/ruby/test.rb"
```

Return the first 2 parts of the path using a Range:
```ruby
directory_parts(dir, 0..1)
=> "C:/Users"
```

Return the last part of the path using a Fixnum index:
```ruby
directory_parts(dir, -1)
=> "test.rb"
```

Using a Range which will return no parts:
```ruby
directory_parts(dir, 2..1)
=> ""
```
