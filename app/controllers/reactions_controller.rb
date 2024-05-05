# frozen_string_literal: true

class ReactionsController < ApplicationController
  before_action :authorize
  before_action :set_post
  before_action :set_reaction, except: :create

  def create
    reaction = @post.reactions.build(user: current_user)
    reaction.liked = reaction_params[:liked]

    if reaction.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('reactions',
                                                    partial: 'reactions/reactions', locals: { post: @post })
        end
        format.html { redirect_to @post }
      end
    else
      @comment = Comment.new
      render 'posts/show', status: :unprocessable_entity
    end
  end

  def update
    @reaction.liked = reaction_params[:liked]

    if @reaction.save
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = notice
          render turbo_stream: turbo_stream.replace('reactions',
                                                    partial: 'reactions/reactions', locals: { post: @post })
        end
        format.html { redirect_to @post }
      end
    else
      @comment = Comment.new
      render 'posts/show', status: :unprocessable_entity
    end
  end

  def destroy
    @reaction.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('reactions',
                                                  partial: 'reactions/reactions', locals: { post: @post })
      end
      format.html { redirect_to @post }
    end
  end

  private

  def reaction_params
    params.require(:reaction).permit(:liked)
  end

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_reaction
    @reaction = @post.reactions.find_by(user: current_user, id: params[:id])
  end
end
