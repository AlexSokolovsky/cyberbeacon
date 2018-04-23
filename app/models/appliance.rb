class Appliance
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :status, type: String
  field :verified, type: Boolean
  belongs_to :user
  has_and_belongs_to_many :devices
end
