
todo

#before_action :name, :unless => true?



# Foo.new.public_methods(false)
# Foo.new.private_methods(false)


        #@__actions ||= []
        #@__actions << actions
        actions
      end

      #@before_actions ||= []
      #@before_actions << actions

      if @before_actions.count > 1
        b = @before_actions.last.fetch(:only, '') == name
      else
        b = true
      end
      a || !b

class TestClass3
  include Callback
  before_action :before3, :only => :b

  attr_accessor :ivar

  def initialize
    @ivar = ""
  end

  def before3
    @ivar << "before-"
  end

  def a
    @ivar << "a"
  end

  def b
    @ivar << "b"
  end
end

describe "False callbacks" do
  subject(:testclass) { TestClass3.new }

  it "should not call methods if only defined" do
    testclass.a.should == "a"
    testclass.ivar.should == "a"
  end

  it "should call methods in only list" do
    testclass.b.should == "b"
    testclass.ivar.should == "before-bar"
  end
end

