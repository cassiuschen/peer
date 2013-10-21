class Score
  include Mongoid::Document
  include Mongoid::Timestamps

  field :point, type: Integer
  validates_inclusion_of :point, in: 1..5

  belongs_to :user
  belongs_to :post
end
