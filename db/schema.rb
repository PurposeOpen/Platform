# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130517173716) do

  create_table "action_sequences", :force => true do |t|
    t.integer  "campaign_id"
    t.string   "name",              :limit => 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "created_by"
    t.string   "updated_by"
    t.integer  "alternate_key"
    t.text     "options"
    t.boolean  "published"
    t.text     "enabled_languages"
    t.string   "slug"
  end

  add_index "action_sequences", ["slug"], :name => "index_action_sequences_on_slug"

  create_table "autofire_emails", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.boolean  "enabled"
    t.integer  "action_page_id"
    t.integer  "language_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "from"
    t.string   "reply_to"
  end

  create_table "blasts", :force => true do |t|
    t.integer  "push_id"
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "delayed_job_id"
    t.string   "failed_job_ids"
  end

  create_table "campaign_share_stats", :id => false, :force => true do |t|
    t.integer "campaign_id",          :null => false
    t.integer "facebook_shares"
    t.integer "twitter_shares"
    t.integer "email_shares"
    t.integer "actions_before_share"
    t.integer "taf_page_id"
  end

  create_table "campaigns", :force => true do |t|
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
    t.string   "slug"
  end

  add_index "campaigns", ["slug"], :name => "index_campaigns_on_slug"

  create_table "content_module_links", :force => true do |t|
    t.integer "page_id",                         :null => false
    t.integer "content_module_id",               :null => false
    t.integer "position"
    t.string  "layout_container",  :limit => 64
  end

  create_table "content_modules", :force => true do |t|
    t.string   "type",                            :limit => 64,  :null => false
    t.text     "content"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.text     "options"
    t.string   "title",                           :limit => 128
    t.string   "public_activity_stream_template"
    t.integer  "alternate_key"
    t.integer  "language_id"
    t.integer  "live_content_module_id"
  end

  add_index "content_modules", ["live_content_module_id"], :name => "live_content_module_id_fk"

  create_table "content_page_collections", :force => true do |t|
    t.string   "name"
    t.integer  "movement_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",                         :default => 0
    t.integer  "attempts",                         :default => 0
    t.text     "handler",    :limit => 2147483647
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "queue",                            :default => "default"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "donations", :force => true do |t|
    t.integer  "user_id",                                                :null => false
    t.integer  "content_module_id",                                      :null => false
    t.integer  "amount_in_cents",                                        :null => false
    t.string   "payment_method",         :limit => 32,                   :null => false
    t.string   "frequency",              :limit => 32,                   :null => false
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.boolean  "active",                               :default => true
    t.datetime "last_donated_at"
    t.integer  "page_id",                                                :null => false
    t.integer  "email_id"
    t.string   "recurring_trigger_id"
    t.datetime "last_tried_at"
    t.string   "identifier"
    t.string   "receipt_frequency"
    t.datetime "flagged_since"
    t.string   "flagged_because"
    t.datetime "dismissed_at"
    t.string   "currency"
    t.integer  "amount_in_dollar_cents"
    t.string   "order_id"
    t.string   "transaction_id"
    t.string   "subscription_id"
    t.integer  "subscription_amount"
  end

  add_index "donations", ["content_module_id"], :name => "donations_content_module_idx"
  add_index "donations", ["dismissed_at"], :name => "dismissed_at_idx"

  create_table "downloadable_assets", :force => true do |t|
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

  create_table "email_footers", :force => true do |t|
    t.text     "html"
    t.integer  "movement_locale_id"
    t.string   "created_by"
    t.string   "updated_by"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.text     "text"
  end

  create_table "email_recipient_details", :force => true do |t|
    t.integer  "email_id"
    t.integer  "recipients_count"
    t.text     "sent_to_users_ids"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "emails", :force => true do |t|
    t.integer  "blast_id"
    t.string   "name"
    t.text     "sent_to_users_ids"
    t.string   "subject"
    t.text     "body"
    t.datetime "deleted_at"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.datetime "test_sent_at"
    t.integer  "delayed_job_id"
    t.integer  "language_id"
    t.string   "from"
    t.string   "reply_to"
    t.string   "alternate_key_a",   :limit => 25
    t.string   "alternate_key_b",   :limit => 25
    t.boolean  "sent"
    t.datetime "sent_at"
  end

  create_table "featured_content_collections", :force => true do |t|
    t.string   "name"
    t.integer  "featurable_id"
    t.string   "featurable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "featured_content_collections", ["featurable_id", "featurable_type"], :name => "index_feat_cont_coll_polymorphic_id_and_type"

  create_table "featured_content_modules", :force => true do |t|
    t.integer  "featured_content_collection_id"
    t.integer  "language_id"
    t.text     "title"
    t.string   "image"
    t.text     "description"
    t.string   "url"
    t.string   "button_text"
    t.string   "date"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "position"
  end

  create_table "homepage_contents", :force => true do |t|
    t.string   "banner_image"
    t.string   "banner_text"
    t.datetime "updated_at"
    t.string   "updated_by"
    t.string   "join_headline"
    t.string   "join_message"
    t.text     "follow_links"
    t.text     "header_navbar"
    t.text     "footer_navbar"
    t.integer  "homepage_id"
    t.integer  "language_id"
  end

  create_table "homepages", :force => true do |t|
    t.integer "movement_id"
    t.boolean "draft",       :default => false
  end

  create_table "image_settings", :id => false, :force => true do |t|
    t.integer  "carousel_image_height"
    t.integer  "carousel_image_width"
    t.integer  "carousel_image_dpi"
    t.integer  "action_page_image_height"
    t.integer  "action_page_image_width"
    t.integer  "action_page_image_dpi"
    t.integer  "featured_action_image_height"
    t.integer  "featured_action_image_width"
    t.integer  "featured_action_image_dpi"
    t.integer  "facebook_image_height"
    t.integer  "facebook_image_width"
    t.integer  "facebook_image_dpi"
    t.integer  "movement_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "image_settings", ["movement_id"], :name => "index_image_settings_on_movement_id", :unique => true

  create_table "images", :force => true do |t|
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

  create_table "join_emails", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.integer  "movement_locale_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "from"
    t.string   "created_by"
    t.string   "updated_by"
    t.string   "reply_to"
  end

  create_table "languages", :force => true do |t|
    t.string   "iso_code"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "native_name"
  end

  create_table "list_intermediate_results", :force => true do |t|
    t.text     "data"
    t.boolean  "ready",      :default => false
    t.integer  "list_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.text     "rules"
  end

  create_table "lists", :force => true do |t|
    t.text     "rules",                        :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "blast_id"
    t.integer  "saved_intermediate_result_id"
  end

  add_index "lists", ["saved_intermediate_result_id"], :name => "lists_saved_intermediate_result_id_fk"

  create_table "member_count_calculators", :force => true do |t|
    t.integer  "current"
    t.integer  "last_member_count"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "movement_id",       :null => false
  end

  create_table "movement_locales", :force => true do |t|
    t.integer "movement_id"
    t.integer "language_id"
    t.boolean "default",     :default => false
  end

  create_table "movements", :force => true do |t|
    t.string   "name",                      :limit => 20, :null => false
    t.string   "url"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.boolean  "subscription_feed_enabled"
    t.string   "created_by"
    t.string   "updated_by"
    t.string   "password_digest"
    t.string   "slug"
    t.string   "crowdring_url"
  end

  add_index "movements", ["slug"], :name => "index_movements_on_slug"

  create_table "pages", :force => true do |t|
    t.integer  "action_sequence_id"
    t.string   "name",                       :limit => 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "position"
    t.text     "required_user_details"
    t.integer  "views",                                    :default => 0,     :null => false
    t.string   "created_by"
    t.string   "updated_by"
    t.integer  "alternate_key"
    t.boolean  "paginate_main_content",                    :default => false
    t.boolean  "no_wrapper"
    t.string   "type"
    t.integer  "content_page_collection_id"
    t.integer  "movement_id"
    t.string   "slug"
    t.integer  "live_page_id"
    t.string   "crowdring_campaign_name"
  end

  add_index "pages", ["live_page_id"], :name => "live_page_id_fk"
  add_index "pages", ["slug"], :name => "index_pages_on_slug"

  create_table "petition_signatures", :force => true do |t|
    t.integer  "user_id",            :null => false
    t.integer  "content_module_id",  :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "page_id",            :null => false
    t.integer  "email_id"
    t.text     "dynamic_attributes"
    t.string   "comment"
  end

  add_index "petition_signatures", ["page_id"], :name => "index_petition_signatures_on_page_id"

  create_table "platform_users", :force => true do |t|
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

  create_table "push_clicked_emails", :id => false, :force => true do |t|
    t.integer  "movement_id", :null => false
    t.integer  "user_id",     :null => false
    t.integer  "push_id",     :null => false
    t.integer  "email_id",    :null => false
    t.datetime "created_at"
  end

  add_index "push_clicked_emails", ["movement_id", "email_id"], :name => "idx_emails"
  add_index "push_clicked_emails", ["movement_id", "push_id"], :name => "idx_pushes"
  add_index "push_clicked_emails", ["push_id"], :name => "index_push_clicked_emails_on_push_id"
  add_index "push_clicked_emails", ["user_id", "movement_id", "created_at"], :name => "idx_list_cutter"

  create_table "push_logs", :force => true do |t|
    t.text     "message",    :limit => 16777215
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "push_sent_emails", :id => false, :force => true do |t|
    t.integer  "movement_id", :null => false
    t.integer  "user_id",     :null => false
    t.integer  "push_id",     :null => false
    t.integer  "email_id",    :null => false
    t.datetime "created_at"
  end

  add_index "push_sent_emails", ["movement_id", "email_id"], :name => "idx_emails"
  add_index "push_sent_emails", ["movement_id", "push_id"], :name => "idx_pushes"
  add_index "push_sent_emails", ["push_id"], :name => "index_push_sent_emails_on_push_id"
  add_index "push_sent_emails", ["user_id", "movement_id", "created_at"], :name => "idx_list_cutter"

  create_table "push_spammed_emails", :id => false, :force => true do |t|
    t.integer  "movement_id", :null => false
    t.integer  "user_id",     :null => false
    t.integer  "push_id",     :null => false
    t.integer  "email_id",    :null => false
    t.datetime "created_at"
  end

  add_index "push_spammed_emails", ["movement_id", "email_id"], :name => "idx_emails"
  add_index "push_spammed_emails", ["movement_id", "push_id"], :name => "idx_pushes"
  add_index "push_spammed_emails", ["push_id"], :name => "index_push_spammed_emails_on_push_id"
  add_index "push_spammed_emails", ["user_id", "movement_id", "created_at"], :name => "idx_list_cutter"

  create_table "push_viewed_emails", :id => false, :force => true do |t|
    t.integer  "movement_id", :null => false
    t.integer  "user_id",     :null => false
    t.integer  "push_id",     :null => false
    t.integer  "email_id",    :null => false
    t.datetime "created_at"
  end

  add_index "push_viewed_emails", ["movement_id", "email_id"], :name => "idx_emails"
  add_index "push_viewed_emails", ["movement_id", "push_id"], :name => "idx_pushes"
  add_index "push_viewed_emails", ["push_id"], :name => "index_push_viewed_emails_on_push_id"
  add_index "push_viewed_emails", ["user_id", "movement_id", "created_at"], :name => "idx_list_cutter"

  create_table "pushes", :force => true do |t|
    t.integer  "campaign_id"
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "shares", :force => true do |t|
    t.string   "share_type"
    t.integer  "user_id"
    t.integer  "page_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "shares", ["page_id"], :name => "index_shares_on_page_id"

  create_table "transactions", :force => true do |t|
    t.integer  "donation_id",                                     :null => false
    t.boolean  "successful",                   :default => false
    t.integer  "amount_in_cents"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "currency",        :limit => 3
    t.string   "external_id"
    t.string   "invoice_id"
  end

  add_index "transactions", ["created_at"], :name => "created_at_idx"
  add_index "transactions", ["donation_id"], :name => "transactions_donation_idx"

  create_table "unique_activity_by_emails", :force => true do |t|
    t.integer  "email_id"
    t.string   "activity",    :limit => 64
    t.integer  "total_count"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "unique_activity_by_emails", ["email_id", "activity"], :name => "index_unique_activity_by_emails_on_email_id_and_activity", :unique => true

  create_table "user_activity_events", :force => true do |t|
    t.integer  "user_id",                           :null => false
    t.string   "activity",            :limit => 64, :null => false
    t.integer  "campaign_id"
    t.integer  "action_sequence_id"
    t.integer  "page_id"
    t.integer  "content_module_id"
    t.string   "content_module_type", :limit => 64
    t.integer  "user_response_id"
    t.string   "user_response_type",  :limit => 64
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "email_id"
    t.integer  "push_id"
    t.integer  "movement_id"
    t.string   "comment"
    t.boolean  "comment_safe"
  end

  add_index "user_activity_events", ["action_sequence_id"], :name => "idx_uae_action_seq_id"
  add_index "user_activity_events", ["activity", "page_id"], :name => "activity"
  add_index "user_activity_events", ["activity"], :name => "activities_activity_idx"
  add_index "user_activity_events", ["campaign_id", "activity"], :name => "uae_campaign_id_activity"
  add_index "user_activity_events", ["comment"], :name => "idx_uae_comment"
  add_index "user_activity_events", ["comment_safe"], :name => "index_user_activity_events_on_comment_safe"
  add_index "user_activity_events", ["content_module_id"], :name => "index_user_activity_events_on_content_module_id"
  add_index "user_activity_events", ["created_at"], :name => "idx_uae_created_at"
  add_index "user_activity_events", ["email_id"], :name => "activities_email_id_idx"
  add_index "user_activity_events", ["movement_id"], :name => "index_user_activity_events_on_movement_id"
  add_index "user_activity_events", ["page_id"], :name => "activities_page_id_idx"
  add_index "user_activity_events", ["updated_at"], :name => "user_activity_events_updated_at_idx"
  add_index "user_activity_events", ["user_id", "created_at", "content_module_type"], :name => "user_id_created_mod_type"

  create_table "user_affiliations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "movement_id"
    t.string   "role",        :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "user_emails", :force => true do |t|
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

  create_table "users", :force => true do |t|
    t.string   "email",                                                                  :null => false
    t.string   "first_name",               :limit => 64
    t.string   "last_name",                :limit => 64
    t.string   "mobile_number",            :limit => 32
    t.string   "home_number",              :limit => 32
    t.string   "street_address",           :limit => 128
    t.string   "suburb",                   :limit => 64
    t.string   "country_iso",              :limit => 2
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.boolean  "is_member",                               :default => true,              :null => false
    t.string   "encrypted_password",                      :default => "!K1T7en$!!2011G"
    t.string   "password_salt"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "deleted_at"
    t.boolean  "is_admin",                                :default => false
    t.string   "created_by"
    t.string   "updated_by"
    t.boolean  "is_volunteer",                            :default => false
    t.float    "random"
    t.integer  "movement_id",                                                            :null => false
    t.integer  "language_id"
    t.string   "postcode"
    t.boolean  "join_email_sent"
    t.boolean  "name_safe"
    t.string   "source"
    t.boolean  "permanently_unsubscribed"
    t.string   "state",                    :limit => 64
  end

  add_index "users", ["created_at"], :name => "created_at_idx"
  add_index "users", ["deleted_at", "is_member"], :name => "member_status"
  add_index "users", ["deleted_at", "movement_id", "is_member"], :name => "index_users_on_deleted_at_and_movement_id_and_is_member"
  add_index "users", ["deleted_at", "movement_id", "source"], :name => "index_users_on_deleted_at_and_movement_id_and_source"
  add_index "users", ["deleted_at"], :name => "idx_deleted_at"
  add_index "users", ["email", "movement_id"], :name => "index_users_on_email_and_movement_id", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["movement_id", "language_id"], :name => "index_users_on_movement_id_and_language_id"
  add_index "users", ["movement_id", "source", "deleted_at"], :name => "index_users_on_movement_id_and_source_and_deleted_at"
  add_index "users", ["name_safe"], :name => "index_users_on_name_safe"
  add_index "users", ["random"], :name => "users_random_idx"

  add_foreign_key "content_modules", "content_modules", :name => "live_content_module_id_fk", :column => "live_content_module_id"

  add_foreign_key "image_settings", "movements", :name => "image_settings_movement_id_fk"

  add_foreign_key "lists", "list_intermediate_results", :name => "lists_saved_intermediate_result_id_fk", :column => "saved_intermediate_result_id", :dependent => :nullify

  add_foreign_key "pages", "pages", :name => "live_page_id_fk", :column => "live_page_id"

end
