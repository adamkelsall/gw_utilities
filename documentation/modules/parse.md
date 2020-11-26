# Parse

`gw_utilities/modules/gw_parse.rb`

Provides methods designed to make values more human readable.
Typically this is used for command line outputs.

## plural

Outputs a plural suffix for a word based on the numeric value passed to the method. This allows a sentence to be formed where the singular or plural form of a word may be required.

Only numbers that are exactly `1` or `-1` (`Fixnum` or `Float`) are not plural forms.

### Arguments

| Name   | Class(es) | Default | Description |
| ------ | --------- | ------- | ----------- |
| number | Fixnum    |         | The number the plural suffix is applicable to |
| single | String    | `""`    | Return value if number is singular |
| plural | String    | `"s"`   | Return value if number is plural |
| RETURN | String    |

### Examples

Words which add "s" when plural (default):
```ruby
plural(12) => "s"
```

All other words e.g. cherry / cherries:
```ruby
plural(12, "y", "ies") => "ies"
```

**plural** can be combined with `sprintf` / `format` to create a proper sentence: 
```ruby
var_num = 12
format( "There are %d apple%s.", var_num, plural(var_num) )
=> "There are 12 apples."
```

## thousands

Converts a `Fixnum` into a `String` with commas separating the number into thousands, making the number more human readable.

This one-line method is particularly rigid and will not play well with non-Fixnum number representations such as `Float`.

### Arguments

| Name   | Class(es) | Default | Description |
| ------ | --------- | ------- | ----------- |
| number | Fixnum    |         | The number to comma separate |
| RETURN | String    |

### Examples

Converting a `Fixnum`:
```ruby
thousands(12_000) => "12,000"
```

Why converting a `Float` is a bad idea:
```ruby
thousands(123.45) => "12,3.45"
```

## title

Attempts to apply first letter capitalisation to a sentence-like `String`. This is designed to mimic an article title or similar.

### Arguments

| Name   | Class(es) | Default | Description |
| ------ | --------- | ------- | ----------- |
| string | String    |         | Title to be converted |
| RETURN | String    |

### Rules

The following processes are applied as part of this method:
- The original capitalisation is disregarded. All words are therefore lowercase or proper-case (first letter capital).
- Excess space between words, punctuation and numbers is removed.
- The first and last word of the String is always capitalised, regardless of word.

**title** uses a preset list of words which it considers to be "lesser" words and does not normally capitalise them. These are:

```
a     an    and   at   but   by   else
for   from  if    in   into  is
nor   of    off   on   or    out
over  the   then  to   when  with
```

### Examples

Converting a normal sentence-like string:
```ruby
title("this is a generic sentence")
=> "This is a Generic Sentence"
```

"Lesser" words at the beginning/end of a sentence:
```ruby
title("for the time being, the future is far off")
=> "For the Time Being, the Future is Far Off"
```

Sentences with punctuation and numbers:
```ruby
title("100% of people breathe air - are YOU one of them?")
=> "100% of People Breathe Air - Are You One of Them?"
```

## colour

Applies UNIX command line interpreted colour formatting to a `String`, providing a convenient and syntactically straightforward way of adding colour to a command line script.

### Arguments

| Name   | Class(es) | Default | Description |
| ------ | --------- | ------- | ----------- |
| string | String    |         | String to apply colour to |
| colour | Symbol    | `nil`   | Predefined colour to apply |
| RETURN | String    |

### Rules

- This method begins by removing any existing colour formatting from `string`.
- The default value for `colour` does not apply any colour formatting and instead just returns a String devoid of any existing colours.

The following Symbols are valid as values for the `colour` argument:

| Symbol   | Colour Value | Actual Usage |
| -------- | ------------ | ------------ |
| :black   | 30           | `\e[30m`     |
| :red     | 31           | `\e[31m`     |
| :green   | 32           | `\e[32m`     |
| :yellow  | 33           | `\e[33m`     |
| :blue    | 34           | `\e[34m`     |
| :magenta | 35           | `\e[35m`     |
| :cyan    | 36           | `\e[36m`     |
| :white   | 37           | `\e[37m`     |

### Examples

Applying colour to a normal String:
```ruby
colour("A green string!", :green)
=> "\e[32mA green string!\e[0m"
```

Applying colour to a String with existing colour:
```ruby
colour("This word is \e[33myellow\e[0m", :cyan)
=> "\e[36mThis word is yellow\e[0m"
```

Removing colour from a String:
```ruby
colour("\e[35mThis string is magenta.\e[0m")
=> "This string is magenta."
```

## bytes

Converts bytes represented as an `Fixnum` into a human understandable `String` consisting of the largest whole denominator (to 2 decimal places) and its unit symbol. Byte units up to Yottabytes (YB) are supported.

### Arguments

| Name   | Class(es) | Default | Description |
| ------ | --------- | ------- | ----------- |
| bytes  | Fixnum    |         | Number of bytes to represent |
| RETURN | String    |

### Examples

Whole unit conversion:
```ruby
bytes(1_024)
=> "1 KB"
```

Partial unit conversion:
```ruby
bytes(2_453_667)
=> "2.34 MB"
```

Negative number:
```ruby
bytes(-3_531_683)
=> "-3.37 MB"
```
