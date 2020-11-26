# Error

`gw_utilities/modules/gw_error.rb`

Standardised methods for breaking code execution with an error, with the intention of making error outputs easily noticeable and consistent.

## error_out

Generic method for breaking code execution with a formatted error message and a custom error code / exit code (Bash `$?` variable).

### Arguments

| Name           | Class(es) | Default | Description |
| -------------- | --------- | ------- | ----------- |
| error_code     | Fixnum    |         | Error code to return on program exit |
| *error_strings | *String   |         | Lines of text explaining the error |

### Examples

Single line error message:
```ruby
error_out(1, "Generic exception encountered.")
```
```
$ ./example.rb
ERROR: Generic exception encountered.
```

Multiple line error message:
```ruby
error_out(
  1,
  "Generic exception encountered.",
  "This script has been terminated."
)
```
```
$ ./example.rb
ERROR: Generic exception encountered.
       This script has been terminated.
```
