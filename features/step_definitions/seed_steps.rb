require 'csv'
require 'rake'

def generate_users(n)
  movement = Movement.find_by_name("Dummy Movement") || FactoryGirl.create(:movement)
  i = 0;
  n.times do
    i = i+1
    User.create(id: i, email: "target#{i}@yourdomain.org", first_name: "first_name#{i}",
                last_name: "last_name#{i}", is_member: false, password: 'password', movement: movement)
  end
  n.times do
    i = i+1
    User.create(id: i, email: "moo#{i+20}@homes.com", first_name: "first_cup#{i+20}",
                last_name: "last_name#{i+20}", is_admin: true, is_member: true, movement: movement)
  end
  n.times do
    i = i+1
    User.create(id: i, email: "temp#{i+40}@imthepmbtch.gov.au", first_name: "first_name#{i+40}",
                last_name: "last_angel#{i+40}", is_member: true, movement: movement)
  end
  i = i+1
  User.create(id: i, email: "chrisanthemum@example.com", first_name: "Chris",
              last_name: "Anthemum", is_member: true, movement: movement)

end

Given /^I have a small sample set of platform users$/ do
  ActiveRecord::Base.transaction do
    i = 0;
    2.times do
      i = i+1
      PlatformUser.create(id: i, email: "target#{i}@yourdomain.org", first_name: "first_name#{i}", last_name: "last_name#{i}", password: 'password')
    end
    PlatformUser.create(id: i, email: "chrisanthemum@example.com", first_name: "Chris", last_name: "Anthemum")
  end
end

Given /^I have a small sample set of users$/ do
  ActiveRecord::Base.transaction do
    generate_users(2)
  end
end

Given /^I have a sample set of users$/ do
  ActiveRecord::Base.transaction do
    generate_users(20)
  end
end

Given /^I run the seed task$/ do
  ActiveRecord::Base.transaction do
    english = Language.find_by_iso_code("en") || FactoryGirl.create(:english)
    portuguese = Language.find_by_iso_code("pt") || FactoryGirl.create(:portuguese)

    FactoryGirl.create(:movement, name: "Funny Movement")

    movement = Movement.find_by_name("Dummy Movement") || FactoryGirl.create(:movement,
      name: "Dummy Movement",
      languages: [english, portuguese]
    )

    movement.update_attributes default_language: english, url: "http://localhost:#{DummyMovementServer::PORT}"

    movement.homepage.homepage_contents =
      [FactoryGirl.create(:homepage_content,
                               homepage: movement.homepage,
                               language: english,
                               banner_image: "/images/homepage-banner.jpg",
                               banner_text: "{MEMBERCOUNT} AUSSIES WHO ALL FIGHT FOR FAIRNESS, SUSTAINABILITY & SOCIAL JUSTICE!"
      )]

    # HOMEPAGE FEATURED CONTENTS
    carousel_collection = FactoryGirl.create(:featured_content_collection,
        name: "Carousel",
        featurable: movement.homepage)
    carousel_module = FactoryGirl.create(:featured_content_module,
        title: "Dummy title",
        url: "http://www.example.com",
        button_text: "Button",
        language: english,
        featured_content_collection: carousel_collection)

    # CONTENT PAGES
    ['Footer', 'Jobs', 'Static Pages'].each do |content_page_collection_name|
      pages_collection = ContentPageCollection.create!(name: content_page_collection_name, movement: movement)
      pages_collection.content_pages.create!(name: "A page inside #{content_page_collection_name}", movement: movement)
    end

    # SAMPLE CAMPAIGNS AND PAGES
    climate, wikileaks, walrus, forestry, same_sex_marriage = Campaign.create!([{name: 'Climate', description: 'Lorem ipsum dolor sit amet.', movement: movement},
                                                                                {name: 'Wikileaks', description: 'Lorem ipsum dolor sit amet.', movement: movement},
                                                                                {name: 'Walruses', description: 'Lorem ipsum dolor sit amet.', movement: movement},
                                                                                {name: 'Forestry', description: 'Lorem ipsum dolor sit amet.', movement: movement},
                                                                                {name: 'Same Sex Marriage', description: 'Lorem ipsum dolor sit amet.', movement: movement, opt_out: false}])


    # PUSHES
    dummy_push = Push.create!(name: "Dummy Push", campaign: forestry)

    # BLASTS
    Blast.create!(name: "Dummy Blast", push: dummy_push)

    ActionSequence.create!([
                             {name: 'Gunns Petition', campaign: forestry},
                             {name: 'Climate Donation', campaign: climate},
                             {name: 'Wikileaks Email', campaign: wikileaks},
                             {name: 'Walrus MP Email', campaign: walrus},
                             {name: 'Walrus MP Email with delay', campaign: walrus},
                             {name: 'Walrus MP Call', campaign: walrus},
                             {name: 'Blank Slate', campaign: climate},
                             {name: 'LGBT Petition', campaign: same_sex_marriage}
                         ])

    ActionSequence.all.each do |ps|
      ActionPage.create!(name: "Landing Page for #{ps.name}", action_sequence: ps, position: 1, movement_id: movement.id)
      ActionPage.create!(name: "Thankyou Page for #{ps.name}", action_sequence: ps, position: 2, movement_id: movement.id)
    end

    # GUNNS PETITION
    action_page = ActionPage.find_by_name("Landing Page for Gunns Petition") or raise 'Page not found'
    kittens = HtmlModule.create!(content: "Save the kittens!", language: english)
    ContentModuleLink.create!(page: action_page, content_module: kittens, position: 1, layout_container: :main_content)
    walrus = HtmlModule.create!(content: "No, save the walrus!", language: english)
    ContentModuleLink.create!(page: action_page, content_module: walrus, position: 2, layout_container: :main_content)

    petition = PetitionModule.create!(
        title: "Sign, please",
        content: 'We the undersigned...',
        petition_statement: "This is the petition statement",
        signatures_goal: 1,
        thermometer_threshold: 0,
        language: english
    )
    ContentModuleLink.create!(page: action_page, content_module: petition, position: 3, layout_container: :main_content)

    action_page = ActionPage.find_by_name("Thankyou Page for Gunns Petition") or raise 'Page not found'
    narwhal = HtmlModule.create!(content: "What about Narwhals?", language: english)
    ContentModuleLink.create!(page: action_page, content_module: narwhal, position: 1, layout_container: :main_content)
    ducks = HtmlModule.create!(content: "Ducks are cool too!", language: english)
    ContentModuleLink.create!(page: action_page, content_module: ducks, position: 2, layout_container: :main_content)

    # CLIMATE DONATION
    action_page = ActionPage.find_by_name("Landing Page for Climate Donation") or raise 'Page not found'
    donation = DonationModule.create!(
        title: "We need cash!",
        content: "Please give generously.",
        thermometer_threshold: 1000,
        frequency_options: {"one_off" => "default", "weekly" => "optional", "monthly" => "hidden", "annual" => "hidden"},
        language: english
    )
    ContentModuleLink.create!(page: action_page, content_module: donation, position: 1, layout_container: :sidebar)

    # WIKILEAKS EMAILS
    action_page = ActionPage.find_by_name("Landing Page for Wikileaks Email") or raise 'Page not found!'
    email_targets = EmailTargetsModule.create!(
        title: "Email the PM",
        content: "You aren't listening Julia, and we're not happy",
        default_subject: "Dear Joolia",
        default_body: "Hi, I've got to put it out there, I'm not happy with you right now.",
        targets: "'Bobson' <colonelbobson@heroes.com>, 'Joolia' <jooolia@imthepm.gov.au>",
        button_text: "SEND SEND SEND!",
        language: english
    )
    ContentModuleLink.create!(page: action_page, content_module: email_targets, position: 1, layout_container: :sidebar)

    # SAME SEX MARRIAGE USER DETAILS COLLECTION
    action_page = ActionPage.find_by_name("Landing Page for LGBT Petition") or raise 'Page not found'
    frogs = HtmlModule.create!(content: "Save the frogs!", language: english)
    ContentModuleLink.create!(page: action_page, content_module: frogs, position: 1, layout_container: :main_content)
    toads = HtmlModule.create!(content: "No, save the toads!", language: english)
    ContentModuleLink.create!(page: action_page, content_module: toads, position: 2, layout_container: :main_content)
    petition = PetitionModule.create!(
        title: "Sign, please",
        content: 'We the undersigned...',
        petition_statement: "This is the petition statement",
        signatures_goal: 1,
        thermometer_threshold: 0,
        language: english
    )
    ContentModuleLink.create!(page: action_page, content_module: petition, position: 3, layout_container: :main_content)

    action_page.update_attributes(required_user_details: {first_name: :required, last_name: :refresh, postcode: :optional, suburb: :required})

    MemberCountCalculator.init_all_counts!

    date_yesterday=Date.yesterday
    date_yesterday.strftime('%m/%d/%Y')

    # Creates the Umbrella User.
    # It's used for offline donations when a user (1) doesn't exist in our database AND (2) doesn't have an email address
    User.create(first_name: "Umbrella", last_name: "User", email: 'offlinedonations@yourdomain.org', movement: movement)
    User.create(first_name: "Afgani", last_name: "Afgan", email: 'afgani_afgan@yourdomain.org',created_at: date_yesterday, movement: movement, country_iso: 'AF')
  end
end

Given /^I have the reference languages in the platform$/ do
  ActiveRecord::Base.transaction do
    Language.find_by_iso_code('en') || FactoryGirl.create(:english)
    Language.find_by_iso_code('pt') || FactoryGirl.create(:portuguese)
    Language.find_by_iso_code('fr') || FactoryGirl.create(:french)
    Language.find_by_iso_code('es') || FactoryGirl.create(:spanish)
  end
end
