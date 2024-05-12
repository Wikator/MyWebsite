# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :authorize
  before_action :set_post
  before_action :set_comment, except: :create

  def create
    @comment = Comment.new(post: @post, content: comment_params[:content])
    @comment.user = current_user

    if @comment.save
      notice = 'Comment was successfully created.'
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = notice
          render turbo_stream: [
            turbo_stream.append('comments', partial: 'comments/comment', locals: comment_partial_locals),
            turbo_stream.replace('new_comment', partial: 'comments/new',
                                                locals: { post: @post, comment: Comment.new }),
            turbo_stream.prepend('flash', partial: 'layouts/flash')
          ]
        end
        format.html { redirect_to @post, notice: }
      end
    else
      render 'posts/show', status: :unprocessable_entity
    end
  end

  def edit
    if @comment.user != current_user
      @comment = Comment.new
      render 'posts/show', status: :forbidden
    else
      render :edit
    end
  end

  def update
    if @comment.user_id != current_user.id
      forbidden 'You are not authorized to edit this comment.'
      return
    end

    tmp_params = comment_params
    tmp_params[:edited] = true

    if @comment.update(tmp_params)
      notice = 'Comment was successfully updated.'
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = notice
          render turbo_stream: [
            turbo_stream.replace("comment_#{@comment.id}", partial: 'comments/comment', locals: comment_partial_locals),
            turbo_stream.prepend('flash', partial: 'layouts/flash')
          ]
        end
        format.html { redirect_to @comment.post, notice: }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @comment.user_id != current_user.id
      forbidden 'You are not authorized to delete this comment.'
      return
    end

    if @comment.destroy
      notice = 'Comment was successfully deleted'
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = notice
          render turbo_stream: [
            turbo_stream.remove("comment_#{params[:id]}"),
            turbo_stream.prepend('flash', partial: 'layouts/flash')
          ]
        end
        format.html { redirect_to @post, notice: }
      end
    else
      redirect_to @post, alert: 'Comment could not be deleted.'
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to posts_path
  end

  def set_comment
    @comment = Comment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to @post
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def comment_partial_locals
    { post_id: @post.id, comment: @comment }
  end

  def forbidden(message)
    respond_to do |format|
      format.html { redirect_to @post, alert: message, status: :forbidden }
      format.turbo_stream do
        flash.now[:alert] = message
        render turbo_stream: [
          turbo_stream.prepend('flash', partial: 'layouts/flash'),
          turbo_stream.replace("comment_#{@comment.id}", partial: 'comments/comment', locals: comment_partial_locals)
        ]
      end
    end
  end
end
