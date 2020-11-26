# encoding: utf-8

module GW_column

  # Provides methods to line up arrays as lines / rows
  # Primarily column_format and its helper method


  def column_width( rows )
    # Returns the length of the longest String in an Array, not including colours
    # IN  rows            Array     String-like objects to be displayed in a column
    # OUT                 Fixnum    Minimum width needed to accommodate all objects

    rows.map { |string| colour(string.to_s).size }.sort.last

  end


  def column_format( table, dividers = [], all_dividers = false )
    # Turns a table-like array of arrays into an array of columnised rows
    # IN  table           Array     Row arrays containing column strings
    # IN  dividers        Array     Column divider strings including left of first column
    # IN  all_dividers    boolean   Whether to show all dividers on a row with less cells

    # Get column widths

    columns       = table.map(&:size).sort.last
    column_widths = []

    columns.times do |column|
      column_widths << column_width( table.map { |row| row[column] } )
    end

    # Construct output_rows

    output_rows = []

    table.each do |row|

      row_string = ""

      columns.times do |column|

        # Only go as far as the last value unless all_dividers

        next unless all_dividers || row[column]

        # Add column's left divider and space-padded column

        row_string << dividers[column].to_s
        row_string << format( "%-#{column_widths[column]}s", row[column].to_s )

      end

      # Add to output_rows including last divider if applicable

      row_string  << dividers[columns].to_s if all_dividers
      output_rows << row_string.rstrip

    end

    output_rows

  end


  def column_list( list, columns = 4, width = 75, dividers = [] )
    # Displays a list of Strings in a number of columns
    # IN  list            Array     Strings to display in columns
    # IN  columns         Fixnum    Maximum amount of columns to display
    # IN  width           Fixnum    Constricting width on number of columns
    # IN  dividers        Array     Left, between column, and right dividers
    # OUT                 Array     Rows of column-formatted list items

    # Set default dividers
    dividers = ["", " ", ""] unless dividers.size == 3 && dividers.map(&:class).uniq == [String]

    # Get width of the largest list item
    list_width = column_width(list)

    # Determine how many columns will fit inside width (minimum 1)

    loop do

      potential_width =
        dividers.first.size + dividers.last.size +
        (list_width * columns) +
        (dividers[1].size * (columns - 1))

      break if columns == 1 || potential_width <= width

      columns -= 1

    end

    # Determine how many rows there will be
    rows, remainder = list.size.divmod(columns)

    # Group list items into columns

    column_items = []

    columns.times do |col|

      column  = list.shift(rows)
      column += list.shift(1) if col < remainder

      column_items << column

    end

    # Convert column_items into row_items

    row_items = [[]] * column_items.first.size

    column_items.each do |column|
      column.each_with_index do |item, index|
        row_items[index] += [item]
      end
    end

    # Create dividers for all columns
    dividers = [dividers.first] + ( [dividers[1]] * (columns - 1) ) + [dividers.last]

    # Invoke column_format to generate output
    column_format( row_items, dividers, true )

  end


end
