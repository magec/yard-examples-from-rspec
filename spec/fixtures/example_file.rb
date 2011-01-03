class Foo
  ## 
  # This is a foo method with an example
  # @rspec_example
  def foo_method
  end
end

class Foo
  class Bar
    ##
    # This is a class nested example
    # @rspec_example
    def bar_method
    end
  end
end

module My
  class Nested
    class Class
      ##
      # This is a module/class nested example
      # @rspec_example
      def nested_method
      end
    end
  end
end



