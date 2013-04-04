class StartFromScratch < ActiveRecord::Migration
  def up
    create_table :agra_actions, :force => true do |t|
      t.integer  "user_id"
      t.string   "slug"
      t.string   "role"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table :blasts, :force => true do |t|
      t.integer  "push_id"
      t.string   "name"
      t.datetime "deleted_at"
      t.datetime "created_at",     :null => false
      t.datetime "updated_at",     :null => false
      t.integer  "delayed_job_id"
      t.string   "failed_job_ids"
    end

    create_table :bookmarked_content_modules, :force => true do |t|
      t.integer  "content_module_id",               :null => false
      t.string   "name",              :limit => 64, :null => false
      t.datetime "created_at",                      :null => false
      t.datetime "updated_at",                      :null => false
    end

    create_table :campaign_blacklists, :id => false, :force => true do |t|
      t.integer  "user_id"
      t.integer  "campaign_id"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    add_index :campaign_blacklists, ["user_id", "campaign_id"], :name => "user_campaign_idx"

    create_table :campaigns, :force => true do |t|
      t.string   "name",          :limit => 64
      t.text     "description"
      t.datetime "created_at",                                    :null => false
      t.datetime "updated_at",                                    :null => false
      t.datetime "deleted_at"
      t.string   "created_by"
      t.string   "updated_by"
      t.integer  "alternate_key"
      t.boolean  "opt_out",                     :default => true
      t.integer  "movement_id"
    end

    create_table :comments, :force => true do |t|
      t.integer  "commentable_id",   :default => 0
      t.string   "commentable_type", :default => ""
      t.string   "title",            :default => ""
      t.text     "body"
      t.string   "subject",          :default => ""
      t.integer  "user_id",          :default => 0,  :null => false
      t.integer  "parent_id"
      t.integer  "lft"
      t.integer  "rgt"
      t.datetime "created_at",                       :null => false
      t.datetime "updated_at",                       :null => false
    end

    add_index :comments, ["commentable_id"], :name => "index_comments_on_commentable_id"
    add_index :comments, ["user_id"], :name => "index_comments_on_user_id"

    create_table :content_module_links, :force => true do |t|
      t.integer "page_id",                         :null => false
      t.integer "content_module_id",               :null => false
      t.integer "position"
      t.string  "layout_container",  :limit => 64
    end

    create_table :content_modules, :force => true do |t|
      t.string   "type",                            :limit => 64,  :null => false
      t.text     "content"
      t.datetime "created_at",                                     :null => false
      t.datetime "updated_at",                                     :null => false
      t.text     "options"
      t.string   "title",                           :limit => 128
      t.string   "public_activity_stream_template"
      t.integer  "alternate_key"
    end

    create_table :delayed_jobs, :force => true do |t|
      t.integer  "priority",   :default => 0
      t.integer  "attempts",   :default => 0
      t.text     "handler"
      t.text     "last_error"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string   "locked_by"
      t.datetime "created_at",                :null => false
      t.datetime "updated_at",                :null => false
    end

    add_index :delayed_jobs, ["priority", "run_at"], :name => "delayed_jobs_priority"

    create_table :donations, :force => true do |t|
      t.integer  "user_id",                                                :null => false
      t.integer  "content_module_id",                                      :null => false
      t.integer  "amount_in_cents",                                        :null => false
      t.string   "payment_method",        :limit => 32,                    :null => false
      t.string   "frequency",             :limit => 32,                    :null => false
      t.datetime "created_at",                                             :null => false
      t.datetime "updated_at",                                             :null => false
      t.string   "card_type",             :limit => 32
      t.integer  "card_expiry_month"
      t.integer  "card_expiry_year"
      t.string   "card_last_four_digits", :limit => 4
      t.string   "name_on_card"
      t.boolean  "active",                               :default => true
      t.datetime "last_donated_at"
      t.integer  "page_id",                                                :null => false
      t.integer  "email_id"
      t.string   "cheque_number",         :limit => 128
      t.string   "cheque_name"
      t.string   "cheque_bank"
      t.string   "cheque_branch"
      t.string   "recurring_trigger_id"
      t.datetime "last_tried_at"
      t.string   "identifier"
      t.string   "receipt_frequency"
      t.datetime "flagged_since"
      t.string   "flagged_because"
      t.datetime "dismissed_at"
    end

    add_index :donations, ["content_module_id"], :name => "donations_content_module_idx"
    add_index :donations, ["dismissed_at"], :name => "dismissed_at_idx"

    create_table :downloadable_assets, :force => true do |t|
      t.string   "asset_file_name"
      t.string   "asset_content_type", :limit => 128
      t.integer  "asset_file_size"
      t.string   "link_text"
      t.datetime "created_at",                        :null => false
      t.datetime "updated_at",                        :null => false
      t.string   "created_by"
      t.string   "updated_by"
      t.integer  "movement_id"
    end

    create_table :electorates, :force => true do |t|
      t.string  "name"
      t.integer "jurisdiction_id"
    end

    create_table :electorates_postcodes, :id => false, :force => true do |t|
      t.integer "electorate_id", :default => 0, :null => false
      t.integer "postcode_id",   :default => 0, :null => false
    end

    create_table :emails, :force => true do |t|
      t.integer  "blast_id"
      t.string   "name"
      t.text     "sent_to_users_ids"
      t.string   "from_address"
      t.string   "reply_to_address"
      t.string   "subject"
      t.text     "body"
      t.datetime "deleted_at"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
      t.datetime "test_sent_at"
      t.integer  "delayed_job_id"
      t.string   "from_name"
    end

    create_table :events, :force => true do |t|
      t.datetime "created_at",                                                              :null => false
      t.datetime "updated_at",                                                              :null => false
      t.string   "name"
      t.date     "date"
      t.integer  "time"
      t.string   "address"
      t.integer  "host_id"
      t.text     "host_notes"
      t.datetime "deleted_at"
      t.integer  "get_together_id"
      t.integer  "capacity"
      t.string   "phone"
      t.boolean  "confirmed",                                            :default => false
      t.string   "confirmation_code"
      t.datetime "confirmed_at"
      t.datetime "canceled_at"
      t.string   "postcode"
      t.string   "street"
      t.string   "suburb"
      t.decimal  "address_latitude",     :precision => 15, :scale => 12
      t.decimal  "address_longitude",    :precision => 15, :scale => 12
      t.decimal  "suburb_latitude",      :precision => 15, :scale => 12
      t.decimal  "suburb_longitude",     :precision => 15, :scale => 12
      t.boolean  "terms_and_conditions",                                 :default => false
      t.boolean  "is_public"
    end

    create_table :events_attendees, :id => false, :force => true do |t|
      t.integer "event_id",    :null => false
      t.integer "attendee_id", :null => false
    end

    create_table :get_together_content_module_links, :force => true do |t|
      t.integer  "content_module_id"
      t.integer  "get_together_id"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
    end

    create_table :get_togethers, :force => true do |t|
      t.string   "name"
      t.integer  "campaign_id"
      t.date     "from_date"
      t.date     "to_date"
      t.date     "recommended_date"
      t.integer  "from_time"
      t.integer  "to_time"
      t.integer  "recommended_time"
      t.datetime "deleted_at"
      t.datetime "created_at",              :null => false
      t.datetime "updated_at",              :null => false
      t.string   "description"
      t.text     "host_greeting_email"
      t.text     "attendee_greeting_email"
      t.text     "options"
      t.boolean  "is_closed"
    end

    create_table :homepages, :force => true do |t|
      t.string   "banner_image"
      t.string   "banner_text"
      t.string   "campaign_image"
      t.string   "campaign_url"
      t.string   "campaign_alt_text"
      t.datetime "updated_at"
      t.string   "updated_by"
      t.string   "campaign2_image"
      t.string   "campaign2_url"
      t.string   "campaign2_alt_text"
      t.string   "campaign3_image"
      t.string   "campaign3_url"
      t.string   "campaign3_alt_text"
      t.integer  "movement_locale_id"
    end

    create_table :images, :force => true do |t|
      t.string   "image_file_name"
      t.string   "image_content_type", :limit => 32
      t.integer  "image_file_size"
      t.datetime "created_at",                                          :null => false
      t.datetime "updated_at",                                          :null => false
      t.integer  "image_height"
      t.integer  "image_width"
      t.string   "image_description"
      t.boolean  "image_resize",                     :default => false, :null => false
      t.string   "created_by"
      t.string   "updated_by"
      t.integer  "movement_id"
    end

    create_table :jurisdictions, :force => true do |t|
      t.string   "name"
      t.datetime "created_at",                        :null => false
      t.datetime "updated_at",                        :null => false
      t.boolean  "upper_house_present"
      t.string   "code",                :limit => 10
    end

    create_table :languages, :force => true do |t|
      t.string   "iso_code"
      t.string   "name"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
      t.string   "native_name"
    end

    create_table :list_intermediate_results, :force => true do |t|
      t.text     "data"
      t.boolean  "ready",      :default => false
      t.integer  "list_id"
      t.datetime "created_at",                    :null => false
      t.datetime "updated_at",                    :null => false
    end

    create_table :lists, :force => true do |t|
      t.text     "rules",      :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
      t.integer  "blast_id"
    end

    create_table :member_count_calculators, :force => true do |t|
      t.integer  "current"
      t.integer  "last_member_count"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
      t.integer  "movement_id",       :null => false
    end

    create_table :movement_locales, :force => true do |t|
      t.integer "movement_id"
      t.integer "language_id"
      t.boolean "default",     :default => false
    end

    create_table :movements, :force => true do |t|
      t.string   "name",       :limit => 20, :null => false
      t.text     "urls"
      t.datetime "created_at",               :null => false
      t.datetime "updated_at",               :null => false
    end

    create_table :mps, :force => true do |t|
      t.string   "last_name"
      t.string   "first_name"
      t.string   "email"
      t.string   "courtesy"
      t.string   "salutation"
      t.string   "honorific"
      t.string   "gender"
      t.string   "parliament_phone"
      t.string   "parliament_fax"
      t.string   "office_address"
      t.string   "office_suburb"
      t.string   "office_state"
      t.string   "office_postcode"
      t.string   "office_fax"
      t.string   "office_phone"
      t.string   "office_tollfree"
      t.string   "titles"
      t.integer  "party_id"
      t.integer  "electorate_id"
      t.datetime "created_at",       :null => false
      t.datetime "updated_at",       :null => false
    end

    create_table :notes, :force => true do |t|
      t.text     "value"
      t.string   "created_by"
      t.string   "updated_by"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table :page_sequences, :force => true do |t|
      t.integer  "campaign_id"
      t.string   "name",          :limit => 64
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.string   "created_by"
      t.string   "updated_by"
      t.integer  "alternate_key"
      t.text     "options"
      t.integer  "theme_id"
    end

    create_table :pages, :force => true do |t|
      t.integer  "page_sequence_id"
      t.string   "name",                   :limit => 64
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.integer  "position"
      t.text     "required_user_details"
      t.boolean  "send_thankyou_email",                  :default => false
      t.text     "thankyou_email_text"
      t.string   "thankyou_email_subject"
      t.integer  "views",                                :default => 0,     :null => false
      t.string   "created_by"
      t.string   "updated_by"
      t.integer  "alternate_key"
      t.boolean  "paginate_main_content",                :default => false
      t.boolean  "no_wrapper"
    end

    create_table :parties, :force => true do |t|
      t.string   "name"
      t.string   "abbreviation"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
      t.integer  "jurisdiction_id"
    end

    create_table :petition_signatures, :force => true do |t|
      t.integer  "user_id",            :null => false
      t.integer  "content_module_id",  :null => false
      t.datetime "created_at",         :null => false
      t.datetime "updated_at",         :null => false
      t.integer  "page_id",            :null => false
      t.integer  "email_id"
      t.text     "dynamic_attributes"
    end

    create_table :platform_users, :force => true do |t|
      t.string   "email",                  :limit => 256,                    :null => false
      t.string   "first_name",             :limit => 64
      t.string   "last_name",              :limit => 64
      t.string   "mobile_number",          :limit => 32
      t.string   "home_number",            :limit => 32
      t.string   "encrypted_password"
      t.string   "password_salt"
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",                         :default => 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.boolean  "is_admin",                              :default => false
      t.datetime "created_at",                                               :null => false
      t.datetime "updated_at",                                               :null => false
      t.datetime "deleted_at"
    end

    create_table :postcodes, :force => true do |t|
      t.string   "number"
      t.string   "suburbs",    :limit => 1024
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.float    "longitude"
      t.float    "latitude"
    end

    create_table :postcodes_regions, :id => false, :force => true do |t|
      t.integer "region_id"
      t.integer "postcode_id"
    end

    create_table :push_logs, :force => true do |t|
      t.text     "message",    :limit => 16777215
      t.datetime "created_at",                     :null => false
      t.datetime "updated_at",                     :null => false
    end

    create_table :pushes, :force => true do |t|
      t.integer  "campaign_id"
      t.string   "name"
      t.datetime "deleted_at"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    create_table :radio_shows, :force => true do |t|
      t.string   "name"
      t.string   "presenter"
      t.time     "from_time"
      t.time     "to_time"
      t.string   "website"
      t.string   "show_type"
      t.integer  "radio_station_id"
      t.datetime "created_at",       :null => false
      t.datetime "updated_at",       :null => false
    end

    create_table :radio_stations, :force => true do |t|
      t.string   "name"
      t.string   "state"
      t.string   "phone"
      t.string   "sms"
      t.string   "fax"
      t.string   "air"
      t.decimal  "latitude",         :precision => 15, :scale => 12
      t.decimal  "longitude",        :precision => 15, :scale => 12
      t.float    "broadcast_radius"
      t.datetime "created_at",                                       :null => false
      t.datetime "updated_at",                                       :null => false
    end

    create_table :redirects, :force => true do |t|
      t.string   "alias",      :limit => 128
      t.string   "target",     :limit => 1024
      t.datetime "created_at",                 :null => false
      t.datetime "updated_at",                 :null => false
    end

    create_table :regions, :force => true do |t|
      t.string   "name"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
      t.integer  "jurisdiction_id"
    end

    create_table :senators, :force => true do |t|
      t.string   "last_name"
      t.string   "first_name"
      t.string   "email"
      t.string   "honorific"
      t.string   "state"
      t.string   "gender"
      t.string   "parliament_phone"
      t.string   "parliament_fax"
      t.string   "office_address"
      t.string   "office_suburb"
      t.string   "office_state"
      t.string   "office_postcode"
      t.string   "office_fax"
      t.string   "office_phone"
      t.string   "office_tollfree"
      t.string   "mailing_address"
      t.string   "mailing_suburb"
      t.string   "mailing_state"
      t.string   "mailing_postcode"
      t.string   "titles"
      t.integer  "party_id"
      t.datetime "created_at",       :null => false
      t.datetime "updated_at",       :null => false
      t.integer  "region_id"
    end

    create_table :slugs, :force => true do |t|
      t.string   "name"
      t.integer  "sluggable_id"
      t.integer  "sequence",                     :default => 1, :null => false
      t.string   "sluggable_type", :limit => 40
      t.string   "scope"
      t.datetime "created_at"
    end

    add_index :slugs, ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
    add_index :slugs, ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

    create_table :themes, :force => true do |t|
      t.string   "name"
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
      t.string   "display_name"
    end

    create_table :transactions, :force => true do |t|
      t.integer  "donation_id",                                     :null => false
      t.boolean  "successful",                   :default => false
      t.integer  "amount_in_cents"
      t.string   "response_code"
      t.string   "message"
      t.string   "txn_ref"
      t.integer  "bank_ref"
      t.string   "action_type"
      t.boolean  "refunded",                     :default => false, :null => false
      t.integer  "refund_of_id"
      t.datetime "created_at",                                      :null => false
      t.datetime "updated_at",                                      :null => false
      t.date     "settled_on"
      t.string   "currency",        :limit => 3
      t.integer  "fee_in_cents"
      t.string   "status_reason"
      t.boolean  "invoiced",                     :default => true
    end

    add_index :transactions, ["created_at"], :name => "created_at_idx"
    add_index :transactions, ["donation_id"], :name => "transactions_donation_idx"

    create_table :unique_activity_by_emails, :force => true do |t|
      t.integer  "email_id"
      t.string   "activity",    :limit => 64
      t.integer  "total_count"
      t.datetime "created_at",                :null => false
      t.datetime "updated_at",                :null => false
    end

    add_index :unique_activity_by_emails, ["email_id", "activity"], :name => "index_unique_activity_by_emails_on_email_id_and_activity", :unique => true

    create_table :user_activity_events, :force => true do |t|
      t.integer  "user_id",                                :null => false
      t.string   "activity",                 :limit => 64, :null => false
      t.integer  "campaign_id"
      t.integer  "page_sequence_id"
      t.integer  "page_id"
      t.integer  "content_module_id"
      t.string   "content_module_type",      :limit => 64
      t.integer  "user_response_id"
      t.string   "user_response_type",       :limit => 64
      t.string   "public_stream_html"
      t.datetime "created_at",                             :null => false
      t.datetime "updated_at",                             :null => false
      t.integer  "donation_amount_in_cents"
      t.string   "donation_frequency"
      t.integer  "email_id"
      t.integer  "push_id"
      t.integer  "get_together_event_id"
    end

    add_index :user_activity_events, ["activity"], :name => "activities_activity_idx"
    add_index :user_activity_events, ["email_id"], :name => "activities_email_id_idx"
    add_index :user_activity_events, ["page_id"], :name => "activities_page_id_idx"
    add_index :user_activity_events, ["updated_at"], :name => "user_activity_events_updated_at_idx"
    add_index :user_activity_events, ["user_id"], :name => "activities_user_id_idx"

    create_table :user_affiliations, :force => true do |t|
      t.integer  "user_id"
      t.integer  "movement_id"
      t.string   "role",        :null => false
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    create_table :user_calls, :force => true do |t|
      t.integer  "page_id"
      t.integer  "content_module_id"
      t.integer  "user_id"
      t.integer  "email_id"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
      t.text     "targets"
    end

    create_table :user_emails, :force => true do |t|
      t.integer  "user_id",           :null => false
      t.integer  "content_module_id", :null => false
      t.string   "subject",           :null => false
      t.text     "body",              :null => false
      t.text     "targets",           :null => false
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
      t.integer  "page_id",           :null => false
      t.integer  "email_id"
      t.boolean  "cc_me"
    end

    create_table :users, :force => true do |t|
      t.string   "email",                                                                :null => false
      t.string   "first_name",             :limit => 64
      t.string   "last_name",              :limit => 64
      t.string   "mobile_number",          :limit => 32
      t.string   "home_number",            :limit => 32
      t.string   "street_address",         :limit => 128
      t.string   "suburb",                 :limit => 64
      t.string   "country_iso",            :limit => 2
      t.datetime "created_at",                                                           :null => false
      t.datetime "updated_at",                                                           :null => false
      t.boolean  "is_member",                             :default => true,              :null => false
      t.string   "encrypted_password",                    :default => "!K1T7en$!!2011G"
      t.string   "password_salt"
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",                         :default => 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.datetime "deleted_at"
      t.boolean  "is_admin",                              :default => false
      t.string   "created_by"
      t.string   "updated_by"
      t.integer  "postcode_id"
      t.string   "tags",                                  :default => "",                :null => false
      t.boolean  "is_volunteer",                          :default => false
      t.float    "random"
      t.text     "comment"
      t.integer  "movement_id",                                                          :null => false
    end

    add_index :users, ["created_at"], :name => "created_at_idx"
    add_index :users, ["deleted_at", "is_member"], :name => "member_status"
    add_index :users, ["deleted_at", "postcode_id"], :name => "postcode_id_idx"
    add_index :users, ["email", "movement_id"], :name => "index_users_on_email_and_movement_id", :unique => true
    add_index :users, ["email"], :name => "index_users_on_email"
    add_index :users, ["random"], :name => "users_random_idx"

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
