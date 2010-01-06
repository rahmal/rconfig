
require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Object do

  describe "#try" do

    it "should return nil if method doesn't exist" do      
      obj = Object.new
      lambda {obj.try(:bad_method)}.should_not raise_error
      obj.try(:bad_method).should be_nil
    end

    it "should return the value from calling the method it exists" do
      obj = Object.new
      lambda {obj.try(:class)}.should_not raise_error
      obj.try(:class).should_not be_nil
      obj.try(:class).should equal Object
    end

  end

  describe "#config" do

    it "should return root config instance if no matching config file exists" do
      class ObjectWithNoConfig; end
      obj = ObjectWithNoConfig.new
      lambda {obj.config}.should_not raise_error
      obj.config.should_not be_nil
      obj.config.should equal RConfig.instance
    end

    it "should class-specific config when matching config file exists" do
      class MyClass; end
      my_class = MyClass.new
      lambda {my_class.config}.should_not raise_error
      my_class.config.should_not be_nil
      my_class.config.should equal $config.my_class
      my_class.config.my_class_flag.should be_true
    end

  end

end
