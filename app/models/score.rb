class Score
  include Mongoid::Document
  include Mongoid::Timestamps

  field :point1, type: Integer
  field :point2, type: Integer
  field :point3, type: Integer
  field :point4, type: Integer
  field :point, type: Integer

  validates_inclusion_of :point1, in: 1..5
  validates_inclusion_of :point2, in: 1..5
  validates_inclusion_of :point3, in: 1..5
  validates_inclusion_of :point4, in: 1..5

  belongs_to :user
  belongs_to :post

  before_save do
    self.point = self.point1 + self.point2 + self.point3 + self.point4
    self.user != self.post.author
  end

  after_create do
    self.post.update_score
  end
end
