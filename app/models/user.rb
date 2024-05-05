# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  has_many :comments, dependent: :destroy
  has_many :reactions, dependent: :destroy
end
