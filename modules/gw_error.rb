# encoding: utf-8

module GW_error

  # Standard format for breaking code execution with an error
  # Allows error output to be predictable and easily noticeable


  def error_out( error_code, *error_strings )
    # Gracefully error out with the specified exit code
    # This includes error logging and closing up the log file
    # IN  error_code      integer   Error code to return on program exit
    # IN  *error_strings  *String   Textual lines of explanation from the error.

    error_lines = [""]

    error_strings.each_with_index do |line, index|

      prefix       = index.zero? ? "ERROR:" : ""
      error_lines << format( "%-7s%s", prefix, line )

    end

    puts error_lines

    exit(error_code)

  end


end
