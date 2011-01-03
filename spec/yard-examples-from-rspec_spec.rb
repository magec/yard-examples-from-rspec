require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
EXAMPLE_DOC_DIR=[File.expand_path(File.dirname(__FILE__) + "/fixtures/*.rb") , File.expand_path(File.dirname(__FILE__) + "/*.rb") ]

OPTIONS = {
  :format => :html, 
  :template => :default, 
  :markup => :rdoc,
  :serializer => YARD::Serializers::FileSystemSerializer.new,
  :default_return => "Object",
  :hide_void_return => false,
  :no_highlight => false, 
  :files => []
}

describe "When we use the rspec_example tag in the method comment" do
  before(:each) do 
    YARD.parse(EXAMPLE_DOC_DIR)
    foo = YARD::Registry.all(:class).find {|i| i.to_s == "Foo" }
    @class_foo_output = YARD::Templates::Engine.render(OPTIONS.merge(:object => foo))
    bar = YARD::Registry.all(:class).find {|i| i.to_s == "Foo::Bar" }
#    YARD::Templates::Engine.generate([foo], OPTIONS)
    @class_bar_output = YARD::Templates::Engine.render(OPTIONS.merge(:object => bar))
    nested_class = YARD::Registry.all(:class).find {|i| i.to_s == "My::Nested::Class" }
    @nested_class_output = YARD::Templates::Engine.render(OPTIONS.merge(:object => nested_class))
    
  end

  it "creates an example tag in the registry" do
    @class_foo_output.should match /Examples:/
  end

  it "outputs the source code of the example of a method that reads \"works this way\" " do 
    @class_foo_output.should match /this/
  end

  it "should include the comments in the example as well" do 
    @class_foo_output.should match /With some comments/
  end

  it "should also work with nested classes" do
    @class_bar_output.should match /nested_class/
  end

  it "should also work with module/class/classs nestes classes" do
    @nested_class_output.should match /super_nested_class/
  end

end

# A bit of a hack, this is the spec that is going to be used as fixture for the plugin
describe Foo do
  describe "#foo_method" do
    it "works this way" do
      this = "is"
      just = "example code" 
      # With some comments
      [1,2,3].each do |i|
        i
      end
    end
  end
end


describe Foo::Bar do
  describe "#bar_method" do 
    it "works this way" do
      nested_class = nil
    end
  end
end

describe My::Nested::Class do
  describe "#nested_method" do 
    it "works this way" do
      super_nested_class = nil
    end
  end
end

