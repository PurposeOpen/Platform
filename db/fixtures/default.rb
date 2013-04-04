# encoding: utf-8

Language.seed_once(:iso_code, 
  {:iso_code => "en", :name => "English", :native_name => "English"},
  {:iso_code => "fr", :name => "French", :native_name => "Français"},
  {:iso_code => "de", :name => "German", :native_name => "Deutsch"},
  {:iso_code => "hi", :name => "Hindi", :native_name => "हिन्दी, हिंदी"},
  {:iso_code => "id", :name => "Indonesian", :native_name => "Bahasa Indonesia"},
  {:iso_code => "pt", :name => "Portuguese", :native_name => "Português"},
  {:iso_code => "ru", :name => "Russian", :native_name => "русский язык"},
  {:iso_code => "es", :name => "Spanish", :native_name => "Español"},
  {:iso_code => "sw", :name => "Swahili", :native_name => "Kiswahili"},
  {:iso_code => "tl", :name => "Tagalog", :native_name => "Wikang Tagalog"},
  {:iso_code => "vi", :name => "Vietnamese", :native_name => "Tiếng Việt"},
  {:iso_code => "it", :name => "Italian", :native_name => "Italiano"}
)

PlatformUser.seed_once(:email,
  {:first_name => "admin", :last_name => "admin", :email => 'admin@admin.com', :password => 'password', :is_admin => true}
)

if (ENV['DATA_SET'] == 'LARGE_DEMO')
  User.where(:movement_id => 1).delete_all

  max_user_count = ENV['USER_COUNT'].try(:to_i) || 10_000

  User.import( (1..max_user_count).map do |i|
    User.new(:first_name => "Sample#{i}", :last_name => "User", :email => "#{i}@example.com", :movement_id => 1, :is_member => 'true')
  end)
end

User.seed_once(:email, :movement_id,
  {:first_name => "Umbrella", :last_name => "User", :email => 'offlinedonations@allout-preview.herokuapp.com', :movement_id => 1}
)

MemberCountCalculator.init_all_counts!