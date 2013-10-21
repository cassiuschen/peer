class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :body, type: String

  has_many :comments
  has_many :scores
  belongs_to :author, class_name: "User", inverse_of: :posts

  def score
    scores.count && scores.sum(&:point).to_f / scores.count
  end
end
