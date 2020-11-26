# encoding: utf-8

module GW_parse

  # Provides methods designed to make variables more human readable
  # Typically this means formatting a command line / file output


  def plural( number, single = "", plural = "s" )
    # Returns the plural suffix if applicable to number
    # IN  number          Fuxnum    The number the plural suffix is applicable to
    # IN  single          String    Return value if number is singular
    # IN  plural          String    Return value if number is plural
    # OUT                 String    Plural prefix applicable to number

    number.abs == 1 ? single : plural

  end


  def thousands( number )
    # Comma separates a number in thousand increments
    # IN  number          Fixnum/Float Number to comma separate
    # OUT                 String       Comma separated number

    number.to_s.sub(/\d+/) { |int| int.reverse.gsub(/...(?=.)/,'\&,').reverse }

  end


  def title( string )
    # Converts string case to that of a typical title
    # IN  string          String    Raw title to be converted
    # OUT                 String    Formatted title

    small_words = %w(a an and at but by else for from if in into is nor of off on or out over the then to when with)

    words =
      string.strip.split(" ").map do |word|
        small_words.include?(word) ? word : word.capitalize
      end

    words.first.capitalize!
    words.last.capitalize!

    words.join(" ")

  end


  def colour( string, colour = nil )
    # Applies UNIX colour formatting to a string
    # IN  string          String    String to apply colour to
    # IN  colour          Symbol    Colour to apply
    # OUT                 String    Colour formatted string

    colours = {
      black:   30,
      red:     31,
      green:   32,
      yellow:  33,
      blue:    34,
      magenta: 35,
      cyan:    36,
      white:   37
    }

    colourless_string = string.gsub(/\e\[\d+m/, "")

    return colourless_string unless colour

    format( "\e[%dm%s\e[0m", colours.fetch(colour), string )

  end


  def bytes( bytes )
    # Formats bytes as their largest denominator
    # Includes 2 decimal spaces and unit symbol
    # IN  bytes           Fixnum    Number of bytes to represent
    # OUT                 String    Formatted bytes representation

    units = %w(B KB MB GB TB PB EB ZB YB)

    multiples = 0
    tier      = 0

    loop do

      break unless bytes.abs >= 1024

      bytes /= 1024.0
      tier  += 1
      
    end

    bytes = bytes.round(2)
    bytes = bytes.to_i if (bytes % 1).zero?

    format( "%s %s", bytes, units[tier] )

  end


  def time( seconds, precision = 0 )
    # Formats seconds into human readable units, up to weeks
    # IN  seconds         Fixnum    Number of seconds to represent
    # IN  precision       Fixnum    Amount of non-zero units to display. 0 = all
    # OUT                 String    Formatted time representation

    return "0s" if seconds.zero?

    units = {
      "w" => 604_800,
      "d" => 86_400,
      "h" => 3_600,
      "m" => 60,
      "s" => 1,
    }

    time       = ""
    units_used = 0

    units.each do |unit, multiple|

      amount = seconds / multiple

      amount.zero? ? next : units_used += 1

      seconds -= amount * multiple
      time    << format( "%d%s ", amount, unit )

      break if units_used == precision

    end

    time.strip

  end


end
