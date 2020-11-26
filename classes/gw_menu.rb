# encoding: utf-8

class GW_menu

  # Cretes and displays a user input controlled menu
  # Presents the user with multiple options to select from
  # Provides option selection validation and looping
  # Returns the selected option values once done


  def initialize( options, opts = {} )
    # IN  options         Arr/Hsh   Strings to present as options. Hash keys used as indexes
    # IN  opts            Hash      Additional argument symbol keys and values

    extend GW_column
    extend GW_parse

    # Create inintial @opts values (defaults)

    @opts = {
      default:      nil,             # String    Option value to select unless :multiple. nil for no default
      description:  [],              # Str/Arr   Lines shown above options detailing what they are
      explanation:  [],              # Str/Arr   Lines shown below options detailing what selecting them does
      multiple:     false,           # boolean   Whether multiple options can be selected, line separated
      numeric:      true,            # boolean   Whether to reference options by numeric indexes
      prompt:       "Select option", # String    Shown next to each user input prompt
      columns:      {
        max:   1,                    # Fixnum    Maximum amount of columns to display options in
        width: 100                   # Fixnum    Character width to fit columns within
      },
      indent:       {
        column:      3,              # Fixnum    Whitespace quantity between each options column
        description: 2,              # Fixnum    Whitespace quantity preceeding :description
        explanation: 4,              # Fixnum    Whitespace quantity preceeding :explanation
        option:      6,              # Fixnum    Whitespace quantity preceeding each option row
        prompt:      6               # Fixnum    Whitespace quantity preceeding :prompt
      }
    }

    # Merge opts and create class variables

    update_opts(opts)

    @options = options

  end


  def update_opts( new_opts )
    # Updates @opts and applies values to class variables
    # IN  new_opts        Hash      Option symbol keys and values to update

    # Merge new_opts into @opts

    @opts.merge!(new_opts) do |_key, opt, new_opt|
      opt.is_a?(Hash) ? opt.merge(new_opt) : new_opt
    end

    # Set class variables from @opts

    @default, @default_type, @description, @explanation, @multiple, @numeric, @prompt, @columns, @indent =
      @opts.values_at(
        :default, :default_type, :description, :explanation, :multiple, :numeric, :prompt, :columns, :indent
      )

  end


  def show
    # Shows the menu and requests a user input
    # Loops if input is invalid or all input is gathered
    # Returns @options value(s)

    convert_variables


    # Set variables used within user input loop

    # description : Apply indentation and line break

    unless @description.empty?
      description =
        @description.map do |line|
          get_indent(:description) << line
        end
      description << ""
    end

    # options : Prefix @options indexes if :numeric

    options =
      if @numeric

        width = @options.keys.last.to_s.size

        @options.map do |index, option|
          format( "%#{width}s. %s", index, option )
        end

      else
        @options.values
      end

    # option_rows : Apply column formatting

    option_rows = column_list(
      options, @columns[:max], @columns[:width],
      [ get_indent(:option), get_indent(:column), "" ]
    )
    option_rows << ""

    # explanation : Create default explanation & apply indentation

    explanation =
      if @explanation.empty?

        exp_object      = @numeric ? " number" : ""
        exp_quantity    = @multiple ? "(s)" : ""
        exp_instruction = @multiple ? ", one per line. Enter empty line when done" : ""

        [ format(
          "Enter option%s%s%s.",
          exp_object, exp_quantity, exp_instruction
        ) ]

      else
        @explanation
      end

    explanation.map! do |line|
      get_indent(:explanation) << line
    end
    explanation << "" unless explanation.empty?

    # default: Ensure the default option is a valid index / value

    default =
      if @default && !@multiple
        @options.value?(@default) ? @default : @options.values.first
      else
        nil
      end

    default = @options.key(default) if @numeric

    # prompt : Apply indentation & default value

    prompt  = get_indent(:prompt) << @prompt
    prompt << format( " [%s]", default ) if default
    prompt << ": "


    # Output menu

    puts ""
    puts description unless @description.empty?
    puts option_rows
    puts explanation

    output = []

    # User input loop

    loop do

      # Print user prompt and get user input

      print prompt
      input = $stdin.gets.strip

      # Handle purposeful input loop exits
      
      break      if @multiple && input.empty?
      return nil if %w(exit quit).include?(input.downcase)

      # Apply default value if applicable
      input = default if input.empty? && default

      # Check validity of input

      valid =
        if @numeric
          @options.keys.include?(input.to_i)
        else
          @options.values.include?(input)
        end

      unless valid
        puts format(
          "%s'%s' is not a valid option, try again.",
          get_indent(:prompt), input
        )
        next
      end

      # Convert @numeric index to value
      input = @options[input.to_i] if @numeric

      # Ensure that the input is unique if @multiple

      if @multiple && output.include?(input)
        puts format(
          "%s'%s' has already been selected, try again.",
          get_indent(:prompt), input
        )
        next
      end

      # Input is valid - add it to output
      output << input

      # Continue accepting input if @multiple
      break if !@multiple || @options.size == output.size

    end

    # Return output
    @multiple ? output : output.first

  end


  protected

  def convert_variables
    # Ensures that all class variables are of the correct type
    # Attempts conversions where possible if incorrect

    # @options indexes must all be Fixnums (drop keys if not)

    if @options.is_a?(Hash) && @options.keys.map(&:class).uniq != [Fixnum]
      @options = @options.values
    end

    # @options must be a hash

    if @options.class == Array

      temp_options = {}
      @options.each_with_index { |option, index| temp_options[index + 1] = option }
      @options = temp_options

    end

    # @options must be sorted by key

    @options = Hash[@options.sort]

    # @options values must be Strings

    @options.each { |key, value| @options[key] = value.to_s }

    # @description and @explanation must be Arrays

    @description = [@description] if @description.class == String
    @explanation = [@explanation] if @explanation.class == String

  end


  def get_indent(symbol)
    # Returns the ccrresponding amount of spaces from @indent
    # IN  symbol          Symbol    @indent key reference
    # OUT                 String    Quantity of spaces matching symbol

    " " * @indent[symbol]

  end


end
