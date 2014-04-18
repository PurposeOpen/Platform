step 'I create a new movement' do
  find('.new-movement-link').click
  fill_in('Name', with: 'New Movement')
  fill_in('Url', with: 'http://www.new-movement.com')
  select('Mid-Atlantic', from: 'Time zone')
  click_button('Create Movement')
end

step 'I am taken to the movement dashboard page' do
  within('.title') { expect(page).to have_content('New Movement') }
  movement = Movement.find_by_name('New Movement')
  expect(current_path).to eq(admin_movement_path(movement))
end
