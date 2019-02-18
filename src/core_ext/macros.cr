# :nodoc:
macro abstract_class_method(method_name)
  def self.{{method_name.id}}
    raise "attempted to call abstract class method {{@type.class.id}}.{{method_name.id}}"
  end
end
