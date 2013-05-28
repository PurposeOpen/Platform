Given /^I have (\d+) (?:fixture )?images? for the movement "(.+?)"(?: with description "(.+?)")?(?: with filename "(.+?)")?$/ do |n, movement_name, description, filename|
  movement = Movement.find_by_name(movement_name)
  default_filename = File.join(Rails.root, 'spec/fixtures/images/wikileaks.jpg')
  n.to_i.times { Image.create(:image_file_name => (filename || default_filename), :movement_id => movement.id, :image_description => description) }
end

When /^I upload a fixture image file$/ do
  filename = File.join(Rails.root, 'spec/fixtures/images/wikileaks.jpg')
  attach_file(:image_image, filename)
  click_button "Upload"
end

Given /^I have (\d+) (?:fixture )?downloadable assets? for the movement "(.+?)"(?: with link text "(.+?)")?(?: with filename "(.+?)")?$/ do |n, movement_name, link_text, filename|
  default_filename = File.join(Rails.root, 'spec/fixtures/images/wikileaks.jpg')
  movement = Movement.find_by_name(movement_name)
  n.to_i.times { DownloadableAsset.create(:asset_file_name => filename || default_filename, :link_text => link_text || "Wikileaks file", :movement_id => movement.id) }
end

When /^I upload a fixture downloadable asset$/ do
  filename = File.join(Rails.root, 'spec/fixtures/images/wikileaks.jpg')
  step %{I fill in "asset_link_text" with "Wikileaks file"}
  attach_file('asset[asset]', filename)
  click_button "Upload"
end
