class Score
  include Mongoid::Document
  include Mongoid::Timestamps

  field :point, type: Integer
  validates_inclusion_of :point, in: 1..20

  belongs_to :user
  belongs_to :post

  before_save do
    user != post.author
  end

  after_create do
    self.post.update_score
  end
end
