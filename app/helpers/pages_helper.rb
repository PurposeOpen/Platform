module PagesHelper
  def content_module_partial(content_module)
    "pages/content_modules/#{content_module.class.name.underscore}"
  end
  
  def render_html(content)
    return "" if content.blank?
    html = content
    if request.ssl?
      html.gsub!('src="http:', 'src="https:')
    end
    html += '<div class="content-end"></div>'
    return html
  end
end
