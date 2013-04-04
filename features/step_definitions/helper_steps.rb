def prepare_dialog_box(action)
  if ["OK","Yes"].include?(action)
    page.execute_script("$.rails.confirm = function () { return true; };")
    page.execute_script("window.confirm = function(msg) { return true; }")
  elsif action == "Cancel"
    page.execute_script("window.confirm = function(msg) { return false; }")
    page.execute_script("$.rails.confirm = function () { return false; };")
  end
end