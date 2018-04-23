class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :description
  embeds_many :device_actions
  belongs_to :user
  has_and_belongs_to_many :appliances
end
