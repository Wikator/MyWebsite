# frozen_string_literal: true

class AddEditedToComments < ActiveRecord::Migration[7.1]
  def change
    add_column :comments, 'edited', :boolean, default: false
  end
end
