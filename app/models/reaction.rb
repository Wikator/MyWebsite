# frozen_string_literal: true

class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :post
  validates :user_id, uniqueness: { scope: :post_id }
  validates :liked, inclusion: { in: [true, false] }
end
