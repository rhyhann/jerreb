require "#{File.dirname(__FILE__)}/../lib/jerreb.rb"

class Example
  def name
    'one'
  end
end

class ExampleTest < Jerreb
  setup { Example.new }
  he('is an example') {object.kind_of?(Example)}
  # Jerreb simply tests if the block returns true or false. object is an alias for what setup returns.
  
  she.kind_of?(Example)
  # Alias for the previous example. Generates: 'The object: kind of Example'.
  
  #his.name('is one') {object == 'one'}
  # object is now what the 'name' method of what setup returns returns.
  
  her.name == 'one'
  # Alias for the previous example. Generates: "The name of the object: == 'one'"       
end

ExampleTest.run