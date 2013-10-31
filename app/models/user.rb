class User
  include Mongoid::Document

  field :no, type: String
  validates :no, presence: true, uniqueness: true
  attr_readonly :no
  field :_id, type: String, default: -> { no }

  field :name, type: String, default: -> { no }
  validates_presence_of :name

  field :is_admin, type: Boolean, default: false
  field :has_signed_in, type: Boolean, default: false

  has_many :posts, inverse_of: :author
  has_many :comments, inverse_of: :author
  has_many :scores

  def can_score?(post)
    self != post.author && !self.scores.where(post: post).exists? && post.scores.count < 10
  end

  def is_admin?
    !!is_admin
  end

  def who?
    if self.is_admin?
      "管理员"
    else
      "学生"
    end
  end

  after_save do
    self.posts.each do |p|
      p.update_author_name
      self.comments.each do |comment|
        Rails.cache.delete(["author_name_comment", comment.id])
      end
      self.scores.each do |score|
        Rails.cache.delete(["user_name_score", score.id])
      end
    end
  end
end
