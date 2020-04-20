# GOLD
# frozen_string_literal: true

class Array
  # Splits or iterates over the array in groups of size +number+,
  # padding any remaining slots with +fill_with+ unless it is +false+.
  #
  #   %w(1 2 3 4 5 6 7 8 9 10).in_groups_of(3) {|group| p group}
  #   ["1", "2", "3"]
  #   ["4", "5", "6"]
  #   ["7", "8", "9"]
  #   ["10", nil, nil]
  #
  #   %w(1 2 3 4 5).in_groups_of(2, '&nbsp;') {|group| p group}
  #   ["1", "2"]
  #   ["3", "4"]
  #   ["5", "&nbsp;"]
  #
  #   %w(1 2 3 4 5).in_groups_of(2, false) {|group| p group}
  #   ["1", "2"]
  #   ["3", "4"]
  #   ["5"]
  def in_groups_of(number, fill_with = nil)
    # It's common that we check for valid input before processing
    if number.to_i <= 0
      raise ArgumentError,
        "Group size must be a positive integer, was #{number.inspect}"
    end

    if fill_with == false
      collection = self
    else
      # size % number gives how many extra we have;
      # subtracting from number gives how many to add;
      # modulo number ensures we don't add group of just fill. <= this part is what I'll miss if I implement this, why? (boundary issue)
      padding = (number - size % number) % number
      collection = dup.concat(Array.new(padding, fill_with))
    end

    if block_given?
      collection.each_slice(number) { |slice| yield(slice) }
    else
      collection.each_slice(number).to_a
    end
  end

  # Splits or iterates over the array in +number+ of groups, padding any
  # remaining slots with +fill_with+ unless it is +false+.
  #
  #   %w(1 2 3 4 5 6 7 8 9 10).in_groups(3) {|group| p group}
  #   ["1", "2", "3", "4"]
  #   ["5", "6", "7", nil]
  #   ["8", "9", "10", nil]
  #
  #   %w(1 2 3 4 5 6 7 8 9 10).in_groups(3, '&nbsp;') {|group| p group}
  #   ["1", "2", "3", "4"]
  #   ["5", "6", "7", "&nbsp;"]
  #   ["8", "9", "10", "&nbsp;"]
  #
  #   %w(1 2 3 4 5 6 7).in_groups(3, false) {|group| p group}
  #   ["1", "2", "3"]
  #   ["4", "5"]
  #   ["6", "7"]
  def in_groups(number, fill_with = nil)
    # size.div number gives minor group size;
    # size % number gives how many objects need extra accommodation;
    # each group hold either division or division + 1 items. <= this takes me a bit long to understand, why?
    # seems like employing visual technique will help
    # 3.div 2, 3 % 2
    # *
    # * *
    division = size.div number
    modulo = size % number

    # create a new array avoiding dup
    groups = []
    start = 0

    number.times do |index|
      length = division + (modulo > 0 && modulo > index ? 1 : 0) # <= The visual technique also help with this
      groups << last_group = slice(start, length)
      # This processing bit right here is particularly clever
      # Get the length first of the group first, then using reference
      # to insert the fill_with into group
      # that way we eliminate what change (group) from what stay the same (length)
      last_group << fill_with if fill_with != false &&
        modulo > 0 && length == division
      start += length
    end

    if block_given?
      groups.each { |g| yield(g) }
    else
      groups
    end
  end

  # Divides the array into one or more subarrays based on a delimiting +value+
  # or the result of an optional block.
  #
  #   [1, 2, 3, 4, 5].split(3)              # => [[1, 2], [4, 5]]
  #   (1..10).to_a.split { |i| i % 3 == 0 } # => [[1, 2], [4, 5], [7, 8], [10]]
  def split(value = nil)
    # Good practice, avoid mutating the original argument
    arr = dup
    result = []
    if block_given?
      while (idx = arr.index { |i| yield i })
        # This one is pretty clever
        # find idx, then shift it, so it shift exactly before the element
        result << arr.shift(idx)
        arr.shift
      end
    else
      while (idx = arr.index(value))
        result << arr.shift(idx)
        arr.shift
      end
    end
    # push the remainder to result
    # a got a hiccup here
    # Better spend more time to understand the way this method is handled
    result << arr
  end
end
