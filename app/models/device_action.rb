class DeviceAction
  include Mongoid::Document
  field :name, type: String
  field :code, type: String
  embedded_in :device
end
