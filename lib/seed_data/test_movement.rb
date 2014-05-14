# encoding: utf-8
require 'seed_data/seeder'

module SeedData
  class TestMovement < Seeder

    def locales
      [
          {movement_id: movement_id, language_id: language_id("en"), default: true},
          {movement_id: movement_id, language_id: language_id("es"), default: false},
      ]
    end

    def campaigns
      [{name: "Campaign1", movement_id: movement_id}]
    end

    def action_sequences
      enabled_languages = ["en", "es"]
      [{name: "First Action Sequence", campaign_id: campaign_id("Campaign1"), published: true, enabled_languages: enabled_languages}]
    end

    def homepage
      [{movement_id: movement_id}]
    end

    def homepage_contents
      [{# English
        homepage_id: homepage_id,
        language_id: language_id("en"),
        banner_text: "{MEMBERCOUNT} HAVE JOINED THE MOVEMENT",
        join_headline: "Let's fight for World Peace",
        join_message: "Will you join this movement for a better world?",
        #:banner_image => "//platform-preview.s3.amazonaws.com/some_image.png",
        follow_links: {facebook: 'http://www.facebook.com/testmovement?ref=ts', twitter: 'http://twitter.com/#!/testmovement', youtube: 'http://www.youtube.com/user/testmovement'},
        footer_navbar: %{<ul><li class="first">Contact Us: <a href="mailto:info@testmovement.org">info@testmovement.org</a></li><li><a href="/en/privacy">Privacy Policy</a></li><li class="last"><a href="/en/jobs">Join Our Team</a></li></ul>}
       },
       {# Spanish
        homepage_id: homepage_id,
        language_id: language_id("es"),
        banner_text: "{MEMBERCOUNT} SE HAN UNIDO AL MOVIMIENTO",
        join_headline: "Luchemos por la paz mundial",
        join_message: "¿Te unes al movimiento que cambiará el mundo?",
        #:banner_image => "//platform-preview.s3.amazonaws.com/some_image.png",
        follow_links: {facebook: 'http://www.facebook.com/testmovement?ref=ts', twitter: 'http://twitter.com/#!/testmovement', youtube: 'http://www.youtube.com/user/testmovement'},
        footer_navbar: %{<ul><li class="first">Contáctanos: <a href="mailto:info@testmovement.org">info@testmovement.org</a></li><li><a href="/es/privacy">Política de privacidad</a></li><li class="last"><a href="/es/jobs">Puestos de trabajo</a></li></ul>}
       }
      ]
    end

    def action_pages
      [{
           action_sequence_id: action_sequence_id("Campaign1", "First Action Sequence"),
           position: 1,
           required_user_details: required_user_details.to_json,
           name: "Change the world",
           type: ActionPage.name,
           movement_id: movement_id
       }]
    end

    def autofire_emails
      [{
           enabled: true,
           action_page_id: page_id("Campaign1", "First Action Sequence", "Change the world"),
           language_id: language_id("en"),
           subject: "You can change the world",
           body: <<-HTML
           <p>Dear {NAME|Friend},</p>

                     <p>
                       Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum
                     </p>
           HTML
       }]
    end

    def collections
      [
          {movement_id: movement_id, name: "Jobs"},
          {movement_id: movement_id, name: "Static Pages"}
      ]
    end

    def content_pages
      [
          {movement_id: movement_id, content_page_collection_id: collection_id("Jobs"), name: "Jobs", type: ContentPage.name},
          {movement_id: movement_id, content_page_collection_id: collection_id("Static Pages"), name: "About", type: ContentPage.name},
          {movement_id: movement_id, content_page_collection_id: collection_id("Static Pages"), name: "Privacy", type: ContentPage.name}
      ]
    end

    def content_modules
      [
          {id: 1111, type: HtmlModule.name, language_id: language_id("en"), content: "Change the world"},
          {id: 1112, type: HtmlModule.name, language_id: language_id("en"), content: html("campaign1-en-2")},
          {id: 1113, type: HtmlModule.name, language_id: language_id("en"), content: html("campaign1-en-3")},
          {id: 1114, type: PetitionModule.name, language_id: language_id("en"),
           title: "TO: Somebody",
           public_activity_stream_template: "{NAME|A member} added their signature to [a petition].", options: {
              button_text: "SIGNING, I AM",
              signatures_goal: 75,
              thermometer_threshold: 5,
              petition_statement: html("campaign1-en-4")
          }},

          {id: 1131, type: HtmlModule.name, language_id: language_id("es"), content: "Cambiemos el mundo"},
          {id: 1132, type: HtmlModule.name, language_id: language_id("es"), content: html("campaign1-es-2")},
          {id: 1133, type: HtmlModule.name, language_id: language_id("es"), content: html("campaign1-es-3")},

          {id: 1134, type: PetitionModule.name, language_id: language_id("es"),
           title: "A: Alguien",
           public_activity_stream_template: "{NAME|A member} {COUNTRY} <BR> [firmó la petición para cambiar el mundo] <BR> {TIMESTAMP}", :otions =:
              button_text: "FIRMANDO, ESTOY",
              signatures_goal: 75,
              thermometer_threshold: 5,
              petition_statement: html("campaign1-es-4")
          }},

          {id: 1211, type: HtmlModule.name, language_id: language_id("en"), content: html("about-en-1")},

          {id: 1231, type: HtmlModule.name, language_id: language_id("es"), content: html("about-es-1")},

          {id: 1311, type: HtmlModule.name, language_id: language_id("en"), content: html("privacy-en-1")},
          {id: 1331, type: HtmlModule.name, language_id: language_id("es"), content: html("privacy-es-1")},

          {id: 1411, type: HtmlModule.name, language_id: language_id("en"), content: html("jobs-en-1")},
          {id: 1431, type: HtmlModule.name, language_id: language_id("es"), content: html("jobs-es-1")},

      ]
    end

    def content_module_links
      test_page_1 = page_id("Campaign1", "First Action Sequence", "Change the world")
      about_page = content_page_id("Static Pages", "About")
      privacy_page = content_page_id("Static Pages", "Privacy")
      jobs_page = content_page_id("Jobs", "Jobs")

      [
          {content_module_id: 1111, page_id: test_page_1, layout_container: ContentModule::HEADER, position: 0},
          {content_module_id: 1112, page_id: test_page_1, layout_container: ContentModule::MAIN, position: 0},
          {content_module_id: 1113, page_id: test_page_1, layout_container: ContentModule::MAIN, position: 1},
          {content_module_id: 1114, page_id: test_page_1, layout_container: ContentModule::SIDEBAR, position: 0},


          {content_module_id: 1131, page_id: test_page_1, layout_container: ContentModule::HEADER, position: 0},
          {content_module_id: 1132, page_id: test_page_1, layout_container: ContentModule::MAIN, position: 0},
          {content_module_id: 1133, page_id: test_page_1, layout_container: ContentModule::MAIN, position: 1},
          {content_module_id: 1134, page_id: test_page_1, layout_container: ContentModule::SIDEBAR, position: 0},

          {content_module_id: 1211, page_id: about_page, layout_container: ContentModule::HEADER, position: 0},

          {content_module_id: 1231, page_id: about_page, layout_container: ContentModule::HEADER, position: 0},

          {content_module_id: 1311, page_id: privacy_page, layout_container: ContentModule::MAIN, position: 0},
          {content_module_id: 1331, page_id: privacy_page, layout_container: ContentModule::MAIN, position: 0},

          {content_module_id: 1411, page_id: jobs_page, layout_container: ContentModule::MAIN, position: 0},
          {content_module_id: 1431, page_id: jobs_page, layout_container: ContentModule::MAIN, position: 0}

      ]
    end

    def featured_content_collections
      [
          {name: 'Carousel',         featurable_id: homepage_id, featurable_type: 'Homepage'},
          {name: 'Featured Actions', featurable_id: homepage_id, featurable_type: 'Homepage'},
          {name: 'Press Releases',   featurable_id: content_page_id("Static Pages", "About"), featurable_type: 'ContentPage'}
      ]
    end

    def featured_content_modules
      [ # Homepage Carousel
          {featured_content_collection_id: featured_content_collection_id('Carousel', homepage_id),
           language_id: language_id("en")},
          {featured_content_collection_id: featured_content_collection_id('Carousel', homepage_id),
           language_id: language_id("es")},
          # Homepage Featured Actions
          {featured_content_collection_id: featured_content_collection_id('Featured Actions', homepage_id),
           language_id: language_id("en")},
          {featured_content_collection_id: featured_content_collection_id('Featured Actions', homepage_id),
           language_id: language_id("es")},
          {featured_content_collection_id: featured_content_collection_id('Press Releases', content_page_id("Static Pages", "About")),
          # About Press Releases
           language_id: language_id("en")},
          {featured_content_collection_id: featured_content_collection_id('Press Releases', content_page_id("Static Pages", "About")),
           language_id: language_id("es")},
      ]
    end
  end
end