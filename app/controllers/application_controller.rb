# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  helper_method :current_user

  private

  def current_user
    return unless cookies.permanent[:user_id]

    @current_user ||= User.find_by(id: cookies.permanent[:user_id])
  end

  def authorize
    return unless current_user.nil?

    p current_user

    respond_to do |format|
      format.html { redirect_to login_url, alert: 'Not authorized' }
      format.turbo_stream do
        flash.now[:alert] = 'Not authorized'
        render turbo_stream: turbo_stream.prepend('flash', partial: 'layouts/flash')
      end
    end
  end

  def authorize_admin
    redirect_to root_url, alert: 'Not authorized' if current_user.nil? || !current_user.is_admin?
  end
end
