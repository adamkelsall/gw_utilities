# encoding: utf-8

module GW_directory

  # Provides methods that interact with directories and their contents


  def directory_contents( directory, blacklist: [], files: true, directories: false, levels: 0, error: false )
    # Returns the file/folder contents of the directory and its children
    # IN  directory       String    Absolute path of the directory to process
    # IN  blacklist       Array     Regexp when matched excludes files/directories
    # IN  files           boolean   Return Array includes files
    # IN  directories     boolean   Return Array includes directories
    # IN  levels          Fixnum    Directory levels to recurse into. 0 for no limit, 1 for directory only
    # IN  error           boolean   Exit Ruby execution if a directory cannot be read
    # OUT                 Array     Absolute paths of files/directories found

    # Read directory contents or provide error handling

    directory_contents = Dir.entries( directory, {encoding: "UTF-8"} ) - %w(. ..)

    # Iterate over directory contents

    valid_contents = []
    levels        -= 1

    directory_contents.each do |item|

      item = File.join(directory, item)

      # Blacklist validation

      invalid = false
      blacklist.each do |regex|
        invalid = item =~ regex
        break if invalid
      end

      next if invalid

      # Item is valid - add to list
      # Run recursively on valid directories

      if File.file?(item)
        valid_contents << item if files
      else
        valid_contents << item if directories
        valid_contents += directory_contents(
          item, blacklist: blacklist, files: files, directories: directories, levels: levels, error: error
        ) unless levels.zero?
      end

    end

    valid_contents

  rescue SystemCallError

    return error ? error_out( 1, "The following directory could not be read or does not exist:", directory ) : []

  end


  def directory_parts( path, range, delimiter = "/" )
    # Returns a range of a directory path, as viewed as an Array of files/directories
    # IN  path            String    Filepath to return a portion of
    # IN  range           Range     Parts of path to return when viewed as an Array
    # IN  delimiter       String    Character to split path by to create an Array

    path_array = path.split(delimiter)[range]
    path_array.is_a?(Array) ? path_array.join(delimiter) : path_array

  end


end
