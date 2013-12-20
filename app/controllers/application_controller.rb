class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # CAS
  before_filter CASClient::Frameworks::Rails::Filter, :get_cas_user
  helper_method :current_user, :is_admin?, :is_teacher?, :is_post_show?, :is_post_submit?, :is_scores?

  def get_cas_user
    begin
      @current_user = User.find(session[:cas_user])
    rescue Mongoid::Errors::DocumentNotFound
      @current_user = User.create!(no: session[:cas_user])
    end
  end

  $task = "Testing....."

  def current_user
    @current_user
  end

  def is_admin?
    @current_user.is_admin
  end

  def is_teacher?
    @current_user.is_teacher
  end

  def is_post_show?
    setting = Setting.where(key: 'post_show').first
    return (setting && setting.value == 'yes') ? true : false
  end

  def is_post_submit?
    setting = Setting.where(key: 'post_submit').first
    return (setting && setting.value == 'yes') ? true : false
  end

  def is_scores?
    setting = Setting.where(key: 'scores').first
    return (setting && setting.value == 'yes') ? true : false
  end

  def logout
    cookies.delete(:tgt)
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

  # CanCan
  # Apply strong_parameters filtering before CanCan authorization
  # See https://github.com/ryanb/cancan/issues/571#issuecomment-10753675
  # before_filter do
  #   resource = controller_name.singularize.to_sym
  #   method = "#{resource}_params"
  #   params[resource] &&= send(method) if respond_to?(method, true)
  # end

  load_and_authorize_resource except: [:logout, :create]
  check_authorization except: [:logout, :create]

  if Rails.env.production?
    rescue_from CanCan::AccessDenied do |exception|
      raise ActionController::RoutingError.new('Not Found')
    end
  end
end
