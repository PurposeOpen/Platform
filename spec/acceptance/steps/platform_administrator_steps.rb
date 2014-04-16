step 'I am a platform administrator with a primary movement' do
  FactoryGirl.create(:movement)
  @user = FactoryGirl.create(:admin_platform_user, email: 'admin@admin.com',
                             first_name: "Admin", last_name: "User",
                             password: 'password')
end

step 'I sign into the platform' do
  visit new_platform_user_session_path
  fill_in("Email", with: @user.email )
  fill_in("Password", with: @user.password )
  click_button("Sign in")
end

step 'I am taken to my primary movement dashboard' do
  expect(current_path).to eq(admin_movement_path(Movement.first))
end

