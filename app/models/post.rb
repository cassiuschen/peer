class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :body, type: String
  validates :title, presence: true

  field :deleted_at, type: Time
  default_scope where(:deleted_at => nil)

  field :author_name, type: String
  field :author_department, type: String

  field :score, type: Float, default: 0.0
  field :scores_count, type: Integer, default: 0
  field :teacher_score, type: Float, default: 0.0
  field :teacher_scores_count, type: Integer, default: 0

  has_many :comments, dependent: :delete
  has_many :scores, dependent: :delete
  belongs_to :author, class_name: "User", inverse_of: :posts

  before_save do
    self.body = Sanitize.clean(
      self.body,
      :elements => %w[
        a abbr b blockquote br cite code dd dfn dl dt em h1 h2 h3 h4 h5 h6 i kbd div font
        li mark ol p pre q s samp small span strike strong sub sup time u ul var img table tbody tr td
      ],
      :attributes => {
        :all    => ['style', 'width', 'height', 'src', 'color', 'class'],
        'a'     => ['title', 'href', 'target'],
      },
      :protocols => {
        'a'   => {'href' => ['ftp', 'http', 'https', 'mailto']}
      },
      :remove_contents => true
    )
    self.author_name = self.author.name
  end

  def hide
    self.update_attributes(deleted_at: Time.now)
  end

  def update_author
    set(author_name: author.name)
    set(author_department: author.department)
  end

  def update_score
    s  = scores.reject { |s| s.is_teacher? }
    ts = scores.select { |s| s.is_teacher? }
    set(score: s.present? ? s.inject(0){ |sum, a| sum + a.point }.to_f / s.count : 0,
        scores_count: s.count,
        teacher_score: ts.present? ? ts.inject(0){ |sum, a| sum + a.point }.to_f / ts.count : 0,
        teacher_scores_count: ts.count
        )
  end
end
