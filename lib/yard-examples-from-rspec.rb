# -*- coding: utf-8 -*-
require 'yard'

##
# This class will hold a map that associates the method descriptions with its source code
class RSpecExampleRegistry  
  def self.example_map
    @example_map ||= {}
  end
end

EXAMPLE_MATCHERS = [ "works this way" ]

## 
# Handler that will set up the method <-> example map
class RSpecItHandler < YARD::Handlers::Ruby::Base

  handles method_call(:it)

  def process
    param = statement.parameters.first.jump(:string_content).source
    if param =~ Regexp.union(*EXAMPLE_MATCHERS)
      RSpecExampleRegistry.example_map[RSpecDescribeHandler.current_path] =  statement.last.last.source.gsub("\n      ","\n")
    end
  end

end

##
# Handler used to inspect the rspec describe call 
# used, to catch the class describe declarations and method declarations
class RSpecDescribeHandler < YARD::Handlers::Ruby::Base

  class << self
    attr_accessor :current_class,:current_method
    
    def current_path
      return "#{@current_class}##{@current_method}"
    end
    
  end

  handles method_call(:describe) 

  def process
    param = statement.parameters.first

    # A class is being declared
    if param.type == :var_ref && param.children.first.type == :const
      self.class.current_class = param.children.first.source  
    end

    # A class is being declared (with a nested name)
    if param.type == :const_path_ref 
      self.class.current_class = param.children.map{|i| i.source}.join("::")
    end

    # A method is being declared
    if param.type == :string_literal && param.source =~ /^"#/      
      self.class.current_method = param.source.delete('#|"|\ ')
    end

    parse_block(statement.last.last)
  end
end

module YARD
  module Tags
    ##
    # A new type of tags has to be used cause we need to intercept the 
    # text call and generate its contents (in generation time, after everything was parsed)
    class RSpecExampleTag < Tag
      def text
        @text =RSpecExampleRegistry.example_map[object.path]
      end
    end

    class DefaultFactory
      def parse_tag_with_rspec_example_tag(tagname,text)
        RSpecExampleTag.new(:example,"")
      end
    end
  end
end

YARD::Tags::Library.define_tag("Rspec Example",:rspec_example,:with_rspec_example_tag)
