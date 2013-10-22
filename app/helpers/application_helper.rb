module ApplicationHelper
  def kind_time(time)
    if Time.now - time < 3.days
      distance_of_time_in_words_to_now(time) + "前"
    else
      l(time.localtime, format: :short)
    end
  end
end
