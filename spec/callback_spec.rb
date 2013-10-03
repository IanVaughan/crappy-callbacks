require './lib/callback'

class TestClass
  include Callback
  before_action :before

  attr_accessor :ivar

  def initialize
    @ivar = ""
  end

  def before
    @ivar << "before-"
  end

  def a
    @ivar << "a"
  end
end

describe "Callback" do
  subject(:testclass) { TestClass.new }

  it "can call the aliased oringal method" do
    testclass.__a.should == "a"
    testclass.ivar.should == "a"
  end

  it "should not have an aliased callback method" do
    expect { testclass.__before }.to raise_error(NoMethodError)
  end

  it "can call the callback method" do
    testclass.before.should == "before-"
    testclass.ivar.should == "before-"
  end

  it "calls the before callback" do
    testclass.a.should == "before-a"
    testclass.ivar.should == "before-a"
  end

  it "should raise normal method missing for undefinied methods" do
    expect { testclass.c }.to raise_error(NoMethodError)
  end
end

class TestClass2
  include Callback
  before_action :before

  attr_accessor :ivar

  def initialize
    @ivar = "init"
  end

  def before
    false
  end

  def a
    @ivar << "a"
  end
end

describe "False callbacks" do
  subject(:testclass) { TestClass2.new }

  it "should not call method if before callback is false" do
    testclass.a.should == false
    testclass.ivar.should == "init"
  end
end

