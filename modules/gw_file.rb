# encoding: utf-8

module GW_file

  # Methods for reading and writing text from files


  def file_read( file, opts = {} )
    # Reads the contents of a file as defined by opts
    # IN  file            String    Filepath of the file to be read
    # IN  opts            Hash      File reading options as defined below
    # OUT                 Str/Arr   Specified format file contents

    # Opts default & merge

    default_opts = {
      comment:     nil,   # String  Character to exclude everything after per line
      empty_lines: true,  # boolean Include lines with only whitespace
      format:      Array, # Class   Whether to return Array or String
      whitespace:  true   # boolean 
    }

    opts = default_opts.merge(opts)

    comment = opts[:comment]

    # Read each line of the file

    lines = []

    File.open(file, "r").each_line do |line|

      if comment
        next if line.start_with?(comment)
        line = line.split(comment).first
      end

      next if !opts[:empty_lines] && line.strip.empty?

      line.strip! unless opts[:whitespace]

      lines << line.chomp

    end

    # Return specified format

    opts[:format] == String ? lines.join("\n") : lines

  end


  def file_write( file, mode, *content )
    # Write a string or array of lines to a file
    # IN  file            String    Filepath of the file to be read
    # IN  mode            String    Write mode to use, either [w]rite or [a]ppend
    # IN  content         Str/Arr   String(s) to write to the file

    # Ensure mode is valid

    mode = "a" unless %w(w a).include?(mode)

    # Convert array to line separated string

    content.flatten!
    content = content.map { |line| line.chomp << "\n" }.join

    # Write content to file

    File.open(file, mode) { |output| output.write(content) }

  end


end
