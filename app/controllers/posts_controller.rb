class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :comment, :score, :unscore, :like, :unlike, :top, :untop]
  before_action :set_order, only: [:index, :my, :scored]

  # GET /
  def index
    if params[:search]
      pattern = params[:search].split(/\s/).reject(&:empty?).map{|s| /#{Regexp.escape(s)}/i }
      @posts = Post.or({ :title.all => pattern }, { :author_name.all => pattern }, { :body.all => pattern }, { :author_department.all => pattern }).desc(@order).page params[:page]
    else
      @posts = Post.desc(@is_top, @order).page params[:page]
    end
  end

  # GET /my
  def my
    @posts = current_user.posts.desc(@order).page params[:page]
    render "index"
  end

  # GET /scored
  def scored
    @scores = current_user.scores.includes(:post).page(params[:page])
    @posts = @scores.map(&:post)
    render "index"
  end

  # GET /scored
  def favorite
    @posts = current_user.favorite_posts.desc(@order).page params[:page]
    render "index"
  end

  # GET /posts/1
  def show
    @scores = @post.scores.reject{|s| s.is_teacher?}
    @teacher_scores = @post.scores.select{|s| s.is_teacher?}
    @comment = Comment.new
    @comments = @post.comments
  end

  # GET /posts/new
  def new
    if current_user.is_create_post? && is_post_submit?
      @post = Post.new
    else
      redirect_to :back, alert: { danger: "New error!" }
    end
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  def create
    if current_user.is_create_post? && is_post_submit?
      @post = Post.new(post_params)
      @post.author = current_user

      if @post.save
        redirect_to @post, notice: 'Post was successfully created.'
      else
        render action: 'new'
      end
    else
      redirect_to :back, alert: { danger: "New error!" }
    end
  end

  # PATCH/PUT /posts/1
  def update
    if @post.update(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy
    redirect_to :back, notice: 'Post was successfully destroyed.'
  end

  # POST /posts/1/comment
  def comment
    comment_params = {
      body: ERB::Util.html_escape(params[:comment][:body].strip).gsub(/#(\d+)楼/, '<a href="#comment-\1">\0</a> '),
      author: current_user,
      post: @post
    }
    if Comment.create(comment_params)
      redirect_to post_path(@post, anchor: "comments")
    else
      redirect_to @post, alert: { danger: "Comment error!" }
    end
  end

  # POST /posts/1/score
  def score
    if current_user.can_score?(@post) || current_user.teacher_can_score?(@post)
      score_params = params.require(:score).permit(:point1, :point2, :point3, :point4)
      score_params = score_params.merge(user: current_user, post: @post)
      s = Score.new(score_params)
      if s.save
        redirect_to post_path(@post, anchor: "raty"), alert: { success: "Rate successfully." }
      else
        redirect_to post_path(@post, anchor: "raty"), alert: { danger: "Rate error!" }
      end
    else
      redirect_to post_path(@post, anchor: "raty"), alert: { danger: "You cannot score this post!" }
    end
  end

  # GET /posts/1/unscore
  def unscore
    current_user.scores.where(post: @post).destroy
    redirect_to post_path(@post, anchor: "raty"), alert: { success: "Rate deleted." }
  end

  # GET /posts/1/like
  def like
    current_user.favorite_posts << @post
    redirect_to :back
  end

  # GET /posts/1/unlike
  def unlike
    current_user.favorite_posts.delete @post
    redirect_to :back
  end

  # GET /posts/1/top
  def top
    @post.top
    redirect_to :back
  end

  # GET /posts/1/untop
  def untop
    @post.untop
    redirect_to :back
  end

  # DELETE /comments/2
  def destroy_comment
    @comment = Comment.find(params[:comment_id])
    @post = @comment.post
    if @comment.hide
      redirect_to post_path(@post, anchor: "comments")
    else
      redirect_to @post, alert: { danger: "Delete error!" }
    end
  end

  # GET /setting
  def setting
  end

  # GET /setting/
  def save_setting
    key = params[:key]
    value = params[:value]

    setting = Setting.where(key: key).first
    if setting
      setting.set_value(value)
    else
      Setting.create!(key: key, value: value)
    end
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    def set_order
      @order = {
          score: "score",
          teacher_score: "teacher_score",
          author: "author_name",
          author: "author_department",
          title: "title",
          time: "created_at"
        }[(params[:sort] || :time).to_sym] || "created_at"
    end

    # Only allow a trusted parameter "white list" through.
    def post_params
      permitted = params.require(:post).permit(:title, :body, :is_top)
      permitted[:is_top] = permitted[:is_top] ? true : false
      return permitted
    end
end
