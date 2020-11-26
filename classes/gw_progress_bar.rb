# encoding: utf-8

class GW_progress_bar

  # Displays a single-line progress bar
  # Overwrites itself on the line to give the appearance of an updating bar
  # Only updates when configurable conditions are met


  def initialize( opts = {} )
    # IN  opts            Hash      Additional argument symbol keys and values

    extend GW_parse

    # Create inintial @opts values (defaults)

    @opts = {
      bar_length:         20,    # Fixnum    Amount of empty/filled characters long the bar is
      char_empty:         "-",   # String    Empty bar character
      char_filled:        "=",   # String    Filled bar character
      char_left:          "[",   # String    Left side bar "border" character
      char_right:         "]",   # String    Right side bar "border" character
      display_percentage: false, # boolean   Print the percentage after the progress bar
      display_value:      false, # boolean   Print the value (X of Y) after the progress bar
      max_value:          1,     # Fixnum    Positive upper limit (100%) of the progress bar
      update_bar:         false, # boolean   Print the progress bar if the amount of "filled" characters changes
      update_percentage:  false, # boolean   Print the progress bar if the percentage changes
      update_value:       1,     # Fixnum    Print the progress bar every X values. 0 for disabled
    }

    # Merge opts and create class variables

    update_opts(opts)

    @last_bar, @last_percentage, @last_value = -1, -1.0, -1

  end


  def update_opts( new_opts )
    # Updates @opts and applies values to class variables
    # IN  new_opts        Hash      Option symbol keys and values to update

    # Merge new_opts into @opts

    @opts.merge!(new_opts) { |_key, _opt, new_opt| new_opt }

    # Set class variables from @opts

    @opts.each do |variable, value|
      instance_variable_set( format( "@%s", variable ), value )
    end

    # Ensure internal bar char variables are only 1 character long

    @char_empty  = "-" unless @char_empty.size == 1
    @char_filled = "=" unless @char_filled.size == 1

    # Calculate the maximum length of progress bar components

    @length_value = thousands(@max_value).size

  end


  def value( new_value )
    # Prints an updated progress bar over the existing line if an update is necessary
    # IN  new_value       Fixnum    Value to attempt to reflect on the progress bar

    # Set @this class variables

    @this_value                 = new_value
    @this_bar, @this_percentage = nil, nil

    # Stop processing if the bar doesn't need updating

    print_bar if update?

  end


  def first
    # Prints the progress bar with the lowest value possible (0%)

    @this_bar, @this_value, @this_percentage = 0, 0, 0

    print_bar

  end


  def last
    # Prints the progress bar with the highest possible value (100%)

    @this_bar        = @bar_length
    @this_value      = @max_value
    @this_percentage = 100

    print_bar
    print "\n"

  end


  protected

  def print_bar
    # Assembles the progress bar and prints it over the existing line

    # Initialise @this variables that weren't needed by update? method

    @this_bar        ||= percentage(:bar)
    @this_percentage ||= percentage(:percentage)

    # Create bar

    empty = @bar_length - @this_bar
    bar   = format( "%s%s%s%s", @char_left, @char_filled * @this_bar, @char_empty * empty, @char_right )

    # Create percentage

    percentage = format( "%4s%", @this_percentage ) if @display_percentage

    # Create value

    value =
      if @display_value
        format(
          " %#{@length_value}s / %#{@length_value}s",
          thousands(@this_value),
          thousands(@max_value)
        )
      end

    # Output progress bar

    print format( "\r%s%s%s", bar, percentage, value )

    # Set last variables to current variables

    @last_bar, @last_percentage, @last_value = @this_bar, @this_percentage, @this_value

  end


  def update?
    # Determines if the new bar value merits a re-print of the bar
    # Uses criteria set in @opts to determine refresh

    # Nothing to do if value hasn't changed

    return false if @this_value == @last_value

    # Update if value is divisible by @update_value

    if @update_value > 0
      return true if @this_value % @update_value == 0
    end

    # Update if percentage has changed

    if @update_percentage
      @this_percentage = percentage(:percentage)
      return true unless @this_percentage == @last_percentage
    end

    # Update if bar length has changed

    if @update_bar
      @this_bar = percentage(:bar)
      return true unless @this_bar == @last_bar
    end

    false

  end


  def percentage( purpose )
    # Displays @this_value as a percentage
    # Used for generating percentages for bar length and percentage display
    # IN  purpose         Symbol    Which value to divide by. :bar or :percentage
    # OUT                 Fixnum    Percentage of the value specified

    divider =
      case purpose
      when :bar        then @bar_length
      when :percentage then 100.0
      end

    # Cap percentages at 100%

    return divider if @this_value > @max_value

    # Calculate and return flat percentage
    
    ((@this_value / @max_value.to_f) * divider).floor

  end


end
