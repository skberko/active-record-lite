class AttrAccessorObject
  def self.my_attr_accessor(*names)
    #getter
    names.each do |name|
      define_method("#{name}") do
        instance_variable_get("@#{name}")
      end
    end

    #setter
    names.each do |name|
      define_method("#{name}=") do |name_value|
        instance_variable_set("@#{name}", name_value)
      end
    end
  end
end
