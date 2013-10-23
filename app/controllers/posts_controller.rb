class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :comment, :score]

  # GET /
  def index
    order = {
        score: "score",
        author: "author",
        title: "title",
        time: "created_at"
      }[(params[:sort] || :time).to_sym] || "created_at"
    if params[:author]
      @posts = Post.where(author_id: params[:author]).desc(order).page params[:page]
    else
      @posts = Post.desc(order).page params[:page]
    end
  end

  # GET /my
  def my
    order = {
        score: "score",
        author: "author",
        title: "title",
        time: "created_at"
      }[(params[:sort] || :time).to_sym] || "created_at"
    @posts = current_user.posts.desc(order).page params[:page]
    render "index"
  end

  # GET /posts/1
  def show
    @comment = Comment.new
    @comments = @post.comments
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  def create
    @post = Post.new(post_params)
    @post.author = current_user

    if @post.save
      redirect_to @post, notice: 'Post was successfully created.'
    else
      render action: 'new'
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

  # GET /posts/1/score/:score
  def score
    if current_user.can_score?(@post)
      s = Score.new(user: current_user, post: @post, point: params[:score])
      if s.save
        redirect_to post_path(@post, anchor: "raty"), alert: { success: "Score successfully." }
      else
        redirect_to post_path(@post, anchor: "raty"), alert: { danger: "Score error!" }
      end
    else
      redirect_to post_path(@post, anchor: "raty"), alert: { danger: "You cannot score this post!" }
    end
  end

  # DELETE /comments/2
  def destroy_comment
    @comment = Comment.find(params[:comment_id])
    @post = @comment.post
    if @comment.update_attributes(deleted_at: Time.now)
      redirect_to post_path(@post, anchor: "comments")
    else
      redirect_to @post, alert: { danger: "Delete error!" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def post_params
      params.require(:post).permit(:title, :body)
    end
end
