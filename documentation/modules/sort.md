# Sort

`gw_utilities/modules/sort.rb`

Custom sorting methods that make use of the Ruby `.sort` block functionality.

## windows_sort

A `String` sorting algorithm designed to mimic the Windows style file display order. Its primary feature is that it interprets numbers in Strings as a number and not a sequence of characters, making leading zeroes irrelevant to the sort order.

### Arguments

| Name    | Class(es) | Default | Description |
| ------- | --------- | ------- | ----------- |
| strings | Array     |         | Strings to be sorted |
| digits  | Fixnum    | `20`    | Amount of digits to pad all numbers to |
| RETURN  | String    |

### Rules

Outside of Windows, files are ordered based on the characters in their name. The following two file names will be used in this example:

```
05.jpg
1.zip
```

String sorting looks at the String one character a time. In this case, `05.jpg` will be sorted above `1.zip` as it starts with a zero. This can be counter-intuitive as to a human observer, `05` is simply `5`, and should appear below `1.zip`.

To get around this, **windows_sort** applies the following logic when sorting Strings:
- Grouped number characters are identified in the String.
- Each set of numbers is padded to the value of the `digits` argument, for example `12` becomes `0000000012`.
- The Strings are compared with the padded numbers.
- If the Strings are identical at this point, the original Strings are used to make a final comparison.

### Examples

Standard Ruby sorting of file names:
```ruby
["9.jpg", "8.jpg", "10.jpg"].sort
=> ["10.jpg", "8.jpg", "9.jpg"]
```

Sorting with windows_sort:
```ruby
windows_sort(["9.jpg", "8.jpg", "10.jpg"])
=> ["8.jpg", "9.jpg", "10.jpg"]
```
