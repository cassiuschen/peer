class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: String
  field :level, type: Integer
  field :deleted_at, type: Time

  default_scope asc(:level)

  belongs_to :post
  belongs_to :author, class_name: "User"

  before_create do
    self.level = self.post.comments.count + 1
  end
end
