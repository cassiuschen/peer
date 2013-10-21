class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: String

  belongs_to :post
  belongs_to :author, class_name: "User"
end
