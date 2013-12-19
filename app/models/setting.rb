class Setting
  include Mongoid::Document
  field :key, type: String # key
  field :value, type: String # velue

  def set_value(value)
    self.update_attributes(value: value)
  end
end
