class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :body, type: String

  has_many :comments, dependent: :delete
  has_many :scores, dependent: :delete
  belongs_to :author, class_name: "User", inverse_of: :posts

  def score
    scores.sum(&:point).to_f / scores.count
  end
end
