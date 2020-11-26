# encoding: utf-8

class GW_arguments

  # UNIX-style command line argument processor
  # Validates arguments against @valid_arguements if not empty
  # Creates a hash of @processed_arguments and accompanying methods for querying it

  attr_accessor :auto_help           # boolean  Include --help arg and display when called
  attr_accessor :prefix_short        # String   Required preceeding character in front of short-form args
  attr_accessor :prefix_long         # String   Required preceeding character in front of long-form args
  attr_accessor :arguments_valid     # Array    Accepted arguments hashes, quantity restrictions & --help text
  attr_accessor :arguments_processed # Hash     Processed arguments, grouped into arguments => values


  def initialize( argv, arguments_valid = [], opts = {} )
    # IN  argv            Array     Command line arguments to be validated & processed
    # IN  opts            Hash      Additional argument symbol keys and values

    extend GW_column
    extend GW_directory
    extend GW_error
    extend GW_parse

    # Opts default & merge

    default_opts = {
      auto_help:    true,
      prefix_short: "-",
      prefix_long:  "--"
    }

    opts = default_opts.merge(opts)

    # Create class variables

    @auto_help, @prefix_short, @prefix_long =
      opts.values_at(
        :auto_help, :prefix_short, :prefix_long
      )

    @argv                = argv
    @arguments_valid     = arguments_valid
    @arguments_processed = {}

  end


  def process
    # Attempts to interpret UNIX-like ARGV
    # Accepts multiple argument syntaxes and standardises them
    # Stores arguments in Ruby-friendly format in @arguments_processed

    # Add --help argument if @auto_help

    if @auto_help && !@arguments_valid.map { |arg| arg[:short] }.include?("?")
      @arguments_valid <<
        { short: "?", long: "help", quantity: 0, value: nil, description: "Show all arguments instead of executing" }
    end

    validate_arguments_valid
    validate_argv

    # Create long argument keys and empty arrays

    @arguments_valid.each { |argument| @arguments_processed[argument[:long]] = [] }

    # First argument cannot be a value

    unless @argv.empty? || @argv.first.start_with?(@prefix_long)
      error_out( 1, format( "Argument value %s must be preceeded by an --argument.", @argv.first.inspect ) )
    end

    # Process arguments as groups of arguments and optional values

    argv           = @argv
    argument_group = []

    loop do

      # Once an argument group has been identified, set in @arguments_processed

      if !argument_group.empty? && ( argv.empty? || argv.first.start_with?(@prefix_long) )

        argument_group[0] = argument_group.first.sub(@prefix_long, "")
        argument_group << nil if argument_group.size < 2

        @arguments_processed[argument_group.first] ||= [] if @arguments_valid.empty?
        @arguments_processed[argument_group.shift] += argument_group

        argument_group = []

      end

      break if argv.empty? && argument_group.empty?

      argument_group << argv.shift

    end

  end


  def validate
    # Checks that argument value quantities match :quantity constraints
    # If not, errors out with a useful explanation

    # Print help instead if --help is called

    if @auto_help && called?("help")
      print_help
      exit(0)
    end

    quantity_error = [ nil, "one value", "two or more values", "one or more values" ]

    # Iterate @arguments_valid and check :quantity against values

    unless @arguments_valid.empty?
      @arguments_valid.each do |argument|

        long     = argument[:long]
        quantity = argument[:quantity]

        valid =
          case quantity
          when 0  then true
          when 1  then once?(long)
          when 2  then many?(long)
          when 3  then once?(long) || many?(long)
          when -1 then once?(long) || !value?(long)
          when -2 then many?(long) || !value?(long)
          end

        # Display helpful message and exit if invalid

        unless valid

          quantity_message =  quantity_error[quantity.abs]
          quantity_message << " if specified" if quantity < 0

          error_out(
            1,
            "Incorrect quantity of values for the following argument:",
            format( "%s%s : %s", @prefix_long, long, quantity_message )
          )
          exit(1)

        end

      end
    end

  end


  def print_help
    # Ouputs argument information including :value and :description

    ruby_file = directory_parts($PROGRAM_NAME, -1)

    puts " "

    unless @arguments_valid.empty?

      puts format( "%s specifies the following valid arguments. Any other arguments will cause an error:\n ", ruby_file )

      rows     = []
      dividers = ["  "] * 3
      
      # Create row / column nested array

      @arguments_valid.each do |argument|

        value =
          if argument[:value]
            format( " <%s>", argument[:value].upcase )
          end

        rows << [
          format( "%s%s", @prefix_short, argument[:short] ),
          format( "%s%s%s", @prefix_long, argument[:long], value ),
          argument[:description]
        ]

      end

      # Format as columns and output

      column_format( rows, dividers ).each { |line| puts line }

    else

      puts format(
        "%s does not specify a set of valid arguments. Any arguments preceeded with \"%s\" can be used.",
        ruby_file, @prefix_long
      )

    end

  end


  # The following arguments analyse a specific argument in @arguments_processed
  # All methods use the following method argument:
  # IN  argument        String    Argument key in @arguments_processed

  def called?( argument )
    # The argument has been called, regardless of value inclusion

    !@arguments_processed.fetch(argument) { return nil }.empty?
  end

  def value?( argument )
    # The argument has been called with at least one value

    !( @arguments_processed.fetch(argument) { return nil } - [nil] ).empty?
  end

  def once?( argument )
    # The argument has been called with a value once

    @arguments_processed.fetch(argument) { return nil }.size == 1
  end

  def many?( argument )
    # The argument has been called with a value more than once

    @arguments_processed.fetch(argument) { return nil }.size > 1
  end

  def quantity( argument )
    # The amount of argument values specified (excludes nil)

    ( @arguments_processed.fetch(argument) { return nil } - [nil] ).size
  end

  def values( argument )
    # The non-nil values specified for this argument

    @arguments_processed.fetch(argument) { return nil } - [nil]
  end

  def empty?
    # No arguments were called

    @arguments_processed.values.flatten.empty?
  end

  def none?
    # No arguments were called with values

    (@arguments_processed.values.flatten - [nil]).empty?
  end


  protected

  def validate_arguments_valid
    # Ensures that @arguments_valid contains valid keys/values
    # In particular, :short values must be single-character strings and unique

    @arguments_valid.map! do |argument|

      # Require base Hash symbols

      if !argument.is_a?(Hash) || !argument.key?(:short) || !argument.key?(:long)
        error_out(
          1,
          "Each @arguments_valid must be a Hash and contain the following symbol keys at minimum:",
          ":prefix_short, :prefix_long"
        )
      end

      # :prefix_short must be a single string character

      argument[:short] = argument[:short].to_s
      argument[:long]  = argument[:long].to_s

      unless argument[:short].size == 1
        error_out(
          1,
          "Each @arguments_valid[:prefix_short] must be a single character only.",
          format( "%s is not valid.", argument[:short].inspect )
        )
      end

      # Add default values for optional keys

      argument[:quantity]    ||= 0
      argument[:value]       ||= nil
      argument[:description] ||= "No description"

      argument

    end

    # :short keys must be unique

    arguments_short = @arguments_valid.map { |argument| argument[:short] }
    
    if arguments_short.size > arguments_short.uniq.size
      error_out( 1, "@arguments_valid :prefix_short must be unique" )
    end

    # :long keys must be unique

    arguments_long = @arguments_valid.map { |argument| argument[:long] }

    if arguments_long.size > arguments_long.uniq.size
      error_out( 1, "@arguments_valid :prefix_long must be unique" )
    end

  end


  def validate_argv
    # Standardises @argv syntax for processing
    # Expands chained arguments and ensures all arguments are :long

    # Expand chained :short arguments
    # e.g. -abc => -a -b -c

    @argv.map! do |argument|

      if !argument.start_with?(@prefix_long) && argument.start_with?(@prefix_short)

        argument      = argument.split(//) - [@prefix_short]
        argument.map! { |arg| format( "%s%s", @prefix_short, arg ) }

      end

      argument

    end

    @argv.flatten!

    # Convert all :short arguments to :long

    unless @arguments_valid.empty?

      short_long = {}
      @arguments_valid.each do |argument|
        short_long[argument[:short]] = argument[:long]
      end

      @argv.map! do |argument|
        if !argument.start_with?(@prefix_long) && argument.start_with?(@prefix_short)

          argument = argument.sub(@prefix_short, "")

          if short_long.key?(argument)
            argument = format( "%s%s", @prefix_long, short_long[argument] )
          else
            error_out( 1, format( "The argument \"%s%s\" is not a valid argument", @prefix_short, argument ) )
          end

        end
        argument
      end

    else

      @argv.map! do |argument|
        argument.start_with?(@prefix_short) ? argument.sub(@prefix_short, @prefix_long) : argument
      end

    end

  end
  

end
