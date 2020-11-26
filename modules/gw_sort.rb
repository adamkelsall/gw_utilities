# encoding: utf-8

module GW_sort

  # Custom sorting algorithms for various purposes


  def windows_sort( strings, digits = 20 )
    # Sorts files using Windows-like human logic number recognition
    # In other words, leading zeroes do not factor into sorting
    # IN  strings         Array     Strings to be sorted
    # IN  digits          Fixnum    Amount of digits to pad all numbers to
    # OUT                 Array     Windows-sorted strings

    strings.sort do |x,y|

      x_padded, y_padded =
        [x, y].map do |string|
          string.to_s.gsub(/\d+/) { |num| num.rjust(digits, "0") }
        end

      diff = x_padded <=> y_padded
      diff.zero? ? x <=> y : diff

    end

  end


end
