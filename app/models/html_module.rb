# == Schema Information
#
# Table name: content_modules
#
#  id                              :integer          not null, primary key
#  type                            :string(64)       not null
#  content                         :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  options                         :text
#  title                           :string(128)
#  public_activity_stream_template :string(255)
#  alternate_key                   :integer
#  language_id                     :integer
#  live_content_module_id          :integer
#

class HtmlModule < ContentModule
  placeable_in ALL_CONTAINERS
  option_fields :use_markdown

  def use_markdown?
    !!use_markdown
  end

  def as_json(options = {})
    if self.use_markdown?
      super.merge content: $markdown.render(content)
    else super end
  end
end
