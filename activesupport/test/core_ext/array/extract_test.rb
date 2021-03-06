# frozen_string_literal: true

require_relative "../../abstract_unit"
require "active_support/core_ext/array"

# A. common cases:
# array: [1, 2]
# empty array: []
# no block given
# B. edge cases:
# array with mixing element type: [nil, true] <= This is not necessary since the array & the block is given by the user
class ExtractTest < ActiveSupport::TestCase
  def test_extract
    numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    array_id = numbers.object_id

    odd_numbers = numbers.extract!(&:odd?)

    assert_equal [1, 3, 5, 7, 9], odd_numbers
    assert_equal [0, 2, 4, 6, 8], numbers
    assert_equal array_id, numbers.object_id
  end

  def test_extract_without_block
    numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    array_id = numbers.object_id

    extract_enumerator = numbers.extract!

    assert_instance_of Enumerator, extract_enumerator
    assert_equal numbers.size, extract_enumerator.size

    odd_numbers = extract_enumerator.each(&:odd?)

    assert_equal [1, 3, 5, 7, 9], odd_numbers
    assert_equal [0, 2, 4, 6, 8], numbers
    assert_equal array_id, numbers.object_id
  end

  def test_extract_on_empty_array
    empty_array = []
    array_id = empty_array.object_id

    new_empty_array = empty_array.extract! { }

    assert_equal [], new_empty_array
    assert_equal [], empty_array
    assert_equal array_id, empty_array.object_id
  end
end
