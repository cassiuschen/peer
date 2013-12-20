#class Work
#  include Mongoid::Document
#  include Mongoid::Timestamps#

#  field :work_contain, type: String
#  field :if_show_work, type: Boolean, default: false#

#  field :work_time, type: Time
#  default_scope where(:work_time => nil)#

#  def show_work
#    self.update_attributes(if_show_work: true)
#  end#

#  def unshow_work
#    self.update_attributes(if_show_work: false)
#  end#

#  def set_work(work)
#    self.update_attributes(work_contain: work)
#    self.update_attributes(work_time: Time.now)
#  end#

#  after_create do
#    self.post.update_score
#  end#

#  after_destroy do
#    self.post.update_score
#  end
#end
