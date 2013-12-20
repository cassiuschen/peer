class User
  include Mongoid::Document

  field :no, type: String
  validates :no, presence: true, uniqueness: true
  attr_readonly :no
  field :_id, type: String, default: -> { no }

  field :name, type: String, default: -> { no }
  field :department, type: String
  validates_presence_of :name

  field :is_admin, type: Boolean, default: false
  field :is_teacher, type: Boolean, default: false
  field :has_signed_in, type: Boolean, default: false

  has_many :posts, inverse_of: :author
  has_many :comments, inverse_of: :author
  has_many :scores
  has_and_belongs_to_many :favorite_posts, class_name: "Post", inverse_of: nil

  def like?(post)
    post.in? favorite_posts
  end

  def can_score?(post)
    !is_teacher? && self != post.author && self[:department].split('/').first == post.author[:department].split('/').first && !self.scores.where(post: post).exists? && post.scores.count < 3
  end

  def teacher_can_score?(post)
    is_teacher? && self != post.author && !self.scores.where(post: post).exists?
  end

  def is_admin?
    is_admin
  end

  def is_teacher?
    is_teacher
  end

  def can_create_post?
    self.posts.count < 1
  end

  def is_scores?
    self.scores.count < 3
  end

  def who?
    if self.is_admin?
      "管理员"
    else
      "学生"
    end
  end

  after_save do
    self.posts.each do |post|
      post.update_author
    end
    self.comments.each do |comment|
      Rails.cache.delete(["author_name_comment", comment.id])
    end
    self.scores.each do |score|
      Rails.cache.delete(["user_name_score", score.id])
      Rails.cache.delete(["is_teacher_score", score.id])
    end
  end
end
