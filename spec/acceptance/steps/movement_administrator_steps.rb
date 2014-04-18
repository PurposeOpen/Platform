step 'I am a Movement Administrator' do
  @movement = FactoryGirl.create(:movement)
  @user = FactoryGirl.create(:platform_user, email: 'admin@movement.com',
                              first_name: "Platform", last_name: "User",
                              password: 'password')

  UserAffiliation.create!(movement_id: @movement.id, user_id: @user.id, 
                          role: 'admin')
end

step 'I am a logged in Movement Admistrator' do
  step 'I am a Movement Administrator'
  step 'I sign into the platform'
  visit admin_movement_path(@movement)
end

