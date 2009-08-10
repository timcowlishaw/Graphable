require File.join(File.expand_path(File.dirname(__FILE__)), 'graphable.rb')
describe Graphable do
  it "should allow classes to decleratively specify a relationship to a single child object" do
    class Foo
      include Graphable
      has_child :bar, :foo
    end
    f = Foo.new
    f.should respond_to(:bar)
    f.should respond_to(:bar=)
  end
  
  it "should allow classes to decleratively specify a relationship to multiple child objects" do
    class Foo
      include Graphable
      has_children :bars, :foo
    end
    f = Foo.new
    f.should respond_to(:bars)
    f.bars.should be_an_instance_of(Graphable::GraphChildren)
  end
  
  it "should allow classes to decleratively specify a relationship to a single parent object" do
    class Bar
      include Graphable
      has_parent :foo, :bars
    end
    b = Bar.new
    b.should respond_to(:foo)
  end
  
  it "should update the parent parameter of a child object when setting it as the singleton child of a parent" do
    class Foo
      include Graphable
      has_child :bar, :foo
    end
    class Bar
      include Graphable
      has_parent :foo, :bar
    end
    
    f = Foo.new
    b = Bar.new
   
    f.bar = b
    b.foo.should == f
   end
  
  it "should update the parent paramater of a child object when removing it as the singleton child of a parent" do
     class Foo
       include Graphable
        has_child :bar, :foo
      end
      class Bar
        include Graphable
        has_parent :foo, :bar
      end

      f = Foo.new
      b = Bar.new

      f.bar = b
      b.foo.should == f
      f.bar = nil
      b.foo.should == nil
  end
  
  it "should update the parent parameter of a child object when adding it as one of many children of a parent" do
    class Foo
       include Graphable
        has_children :bar, :foo
      end
      class Bar
        include Graphable
        has_parent :foo, :bar
      end

      f = Foo.new
      b = Bar.new

      f.bars.add b
      b.foo.should == f
  end
  
  it "should update the parent parameter of a child object when removing it from the children of its parent" do
    class Foo
       include Graphable
        has_children :bar, :foo
      end
      class Bar
        include Graphable
        has_parent :foo, :bar
      end

      f = Foo.new
      b = Bar.new

      f.bars.add b
      b.foo.should == f
      f.bars.remove b
      b.foo.should == nil
  end
  
  it "should update the parent parameter of a child object when it is added to the graph by an array operation" do
    class Foo
       include Graphable
        has_children :bar, :foo
      end
      class Bar
        include Graphable
        has_parent :foo, :bar
      end

      f = Foo.new
      b = Bar.new
      
      f.bars << b
      b.foo.should == f
      
  end
  
  it "should update the parent parameter of a child object when it is removed from the graph by an array operation" do
    class Foo
       include Graphable
        has_children :bar, :foo
      end
      class Bar
        include Graphable
        has_parent :foo, :bar
      end

      f = Foo.new
      b = Bar.new
      
      f.bars << b
      b.foo.should == f
      f.bars.should include(b)
      
      f.bars.map! {|b| nil}
      b.foo.should == nil
  end
  
  it "should not allow the children of a parent object to contain objects that do not have a parent relation to it" do
    class Foo
     include Graphable
      has_children :bar, :foo
    end
    class Bar
      include Graphable
      has_parent :foo, :bar
    end

    f = Foo.new
    b = Bar.new

    f.bars << "Something wrong"
    f.bars.should be_empty
  end
  
end