# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def bootstrap_class_for_flash(type)
    case type
    when 'notice' then 'alert-info'
    when 'alert' then 'alert-warning'
    when 'error' then 'alert-danger'
    else type.to_s
    end
  end

  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    extensions = {
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true
    }
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    markdown.render(text).html_safe
  end
end
