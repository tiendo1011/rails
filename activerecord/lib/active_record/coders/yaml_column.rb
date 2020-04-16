# frozen_string_literal: true

require "yaml"

module ActiveRecord
  module Coders # :nodoc:
    class YAMLColumn # :nodoc:
      attr_accessor :object_class

      def initialize(attr_name, object_class = Object)
        @attr_name = attr_name
        @object_class = object_class
        check_arity_of_constructor
      end

      def dump(obj)
        # Check obj.nil? here & inside assert_valid_value, feel that?
        return if obj.nil?

        assert_valid_value(obj, action: "dump")
        YAML.dump obj
      end

      def load(yaml)
        # disable this line doesn't raise error on test?
        # ARCONN=postgresql bundle exec ruby -Itest test/cases/coders/yaml_column_test.rb
        # return object_class.new if object_class != Object && yaml.nil?
        return yaml unless yaml.is_a?(String) && /^---/.match?(yaml)
        obj = YAML.load(yaml)

        assert_valid_value(obj, action: "load")
        obj ||= object_class.new if object_class != Object

        obj
      end

      def assert_valid_value(obj, action:)
        unless obj.nil? || obj.is_a?(object_class)
          raise SerializationTypeMismatch,
            "can't #{action} `#{@attr_name}`: was supposed to be a #{object_class}, but was a #{obj.class}. -- #{obj.inspect}"
        end
      end

      private
        def check_arity_of_constructor
          # Interesting, use load itself to check constructor arity, but why?
          load(nil)
        rescue ArgumentError
          raise ArgumentError, "Cannot serialize #{object_class}. Classes passed to `serialize` must have a 0 argument constructor."
        end
    end
  end
end
