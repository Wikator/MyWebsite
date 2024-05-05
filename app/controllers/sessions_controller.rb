# frozen_string_literal: true

class SessionsController < ApplicationController
  def new_login; end

  def new_register; end

  # POST /login
  def create_login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      log_in_user(user, 'Logged in successfully')
    else
      flash.now[:alert] = 'Email or password is invalid'
      render :new_login, status: :unprocessable_entity
    end
  end

  # POST /register
  def create_register
    user = User.new(username: params[:username], email: params[:email], password: params[:password],
                    password_confirmation: params[:password_confirmation])

    if user.save
      log_in_user(user, 'Registered and logged in successfully')
    else
      flash.now[:alert] = 'Failed to register user. Please try again.'
      render :new_register, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    cookies.delete(:user_id)
    redirect_back fallback_location: root_path, notice: 'Logged out successfully'
  end

  private

  def log_in_user(user, notice_message)
    session[:user_id] = user.id
    cookies.permanent[:user_id] = user.id
    redirect_to posts_path, notice: notice_message
  end
end
