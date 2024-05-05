# frozen_string_literal: true

class Post < ApplicationRecord
  has_one_attached :thumbnail, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :reactions, dependent: :destroy

  before_destroy :cleanup_thumbnail
  # after_update :cleanup_thumbnail, if: :saved_change_to_thumbnail?

  private

  def cleanup_thumbnail
    thumbnail.purge_later
  end
end
