class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  field :task_contain, type: String
  field :if_show_task, type: Boolean, default: false

  field :task_time, type: Time
  default_scope where(:task_time => nil)

  def show_task
    self.update_attributes(if_show_task: true)
  end

  def unshow_task
    self.update_attributes(if_show_task: false)
  end

  def save_task
    
    Rails.cache.fetch(["is_teacher_score", self.id]) do
      user.is_teacher
    end
  end

  after_create do
    self.post.update_score
  end

  after_destroy do
    self.post.update_score
  end
end
