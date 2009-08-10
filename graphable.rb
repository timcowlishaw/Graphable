require File.join(File.expand_path(File.dirname(__FILE__)), 'ext', 'ruby_decorators', 'decorators')

module Graphable
  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
    
    def has_child(name_here, name_there)
      class_eval <<-EOS
        attr_reader :#{name_here}
        def #{name_here}=(obj)
          #{name_here} && #{name_here}.instance_variable_set(:@#{name_there}, nil)
          @#{name_here}=(obj)
          obj.instance_variable_set(:@#{name_there}, self)
          return obj
        end
      EOS
    end
  
    def has_children(name_here, name_there)
      class_eval <<-EOS
        def #{name_here}
          @#{name_here} ||= Graphable::GraphChildren.new(self, :#{name_there})
        end
      EOS
    end
  
    def has_parent(name_here, name_there)
      class_eval <<-EOS
        attr_reader :#{name_here}
      EOS
    end
  
  end

  class GraphChildren
  
    extend MethodDecorators
    include Enumerable

    class UpdateRelationshipsDecorator
      def initialize(klass, method)
        @method = method
      end

      def call(this, *args, &block)
        pre_mod = this.instance_variable_get(:@array).dup
        return_val = @method.bind(this).call(*args, &block)
        this.send(:notify_changed, pre_mod)
        return_val
      end
    end
  
    def self.with_updates
      decorate UpdateRelationshipsDecorator
    end
  
    def initialize(parent, parent_relation_name)
      @parent = parent
      @parent_relation_name = parent_relation_name
      @array = []
    end
    
    with_updates
    def add(object)
      @array.push(object)
    end

    with_updates
    def remove(object)
      @array.reject! {|elem| elem == object }
    end
  
    with_updates
    def method_missing(*args, &block)
      @array.send(*args, &block)
    end
  
    private
  
    def notify_changed(pre_mod)
      (pre_mod - @array).each do |obj|
        obj.instance_variable_set("@#{@parent_relation_name}", nil) if obj.send(@parent_relation_name) == @parent
      end
      (@array - pre_mod).each do |obj|
        obj.instance_variable_set("@#{@parent_relation_name}", @parent) 
      end
      @array.reject! {|elem| !elem.respond_to?(@parent_relation_name) || elem.send(@parent_relation_name) != @parent}
    end  
  end
end