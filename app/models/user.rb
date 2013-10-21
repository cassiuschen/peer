class User
  include Mongoid::Document

  field :no, type: String
  validates_uniqueness_of :no

  attr_readonly :no
  field :_id, type: String, default: -> { no }
  
  field :name, type: String, default: -> { no }
  validates_presence_of :name

  field :is_admin, type: Boolean, default: false

  field :last_sign_in_at, :type => Time
  field :last_sign_in_ip, :type => String

  has_many :posts, inverse_of: :author
  has_many :comments, inverse_of: :author
  has_many :scores

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
end
