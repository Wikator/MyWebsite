# frozen_string_literal: true

class ReactionsController < ApplicationController
  before_action :authorize
  before_action :set_post
  before_action :set_reaction, except: :create

  def create
    reaction = @post.reactions.build(user: current_user)
    reaction.liked = reaction_params[:liked]

    if reaction.save
      refresh_reactions
    else
      @comment = Comment.new
      render 'posts/show', status: :unprocessable_entity
    end
  end

  def update
    @reaction.liked = reaction_params[:liked]

    if @reaction.save
      refresh_reactions
    else
      @comment = Comment.new
      render 'posts/show', status: :unprocessable_entity
    end
  end

  def destroy
    @reaction.destroy
    refresh_reactions
  end

  private

  def reaction_params
    params.require(:reaction).permit(:liked)
  end

  def set_post
    @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
    redirect_or_show_error('Post not found', posts_path)
  end

  def set_reaction
    @reaction = @post.reactions.find_by!(user: current_user, id: params[:id], post_id: params[:post_id])
  rescue ActiveRecord::RecordNotFound
    redirect_or_show_error('Reaction not found', @post)
  end

  def redirect_or_show_error(alert, redirect_path)
    respond_to do |format|
      format.turbo_stream do
        flash[:alert] = alert
        render turbo_stream: turbo_stream.prepend('flash', partial: 'layouts/flash')
      end
      format.html { redirect_to redirect_path, alert:, status: :not_found }
    end
  end

  def refresh_reactions
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('reactions',
                                                  partial: 'reactions/reactions', locals: { post: @post })
      end
      format.html { redirect_to @post }
    end
  end
end
