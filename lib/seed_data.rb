# encoding: utf-8

module SeedData
  def self.seed_movement(params = {})
    movement_params = params.slice(:name, :url)
    seeder_class = params[:seeder_class]
    seed_method = params[:seed].to_s == "always" ? :seed : :seed_once

    Movement.seed_once(:name, movement_params)
    movement = Movement.where(name: params[:name]).first
    seeder = seeder_class.new movement

    seed MovementLocale, seed_method,            :language_id, :movement_id,         seeder.locales
    seed Homepage, seed_method,                  :movement_id,                       seeder.homepage
    seed HomepageContent, seed_method,           :homepage_id, :language_id,         seeder.homepage_contents

    seed Campaign, seed_method,                  :name, :movement_id,                seeder.campaigns
    seed ActionSequence, seed_method,            :name, :campaign_id,                seeder.action_sequences

    seed Page, seed_method,                      :name, :action_sequence_id,         seeder.action_pages
    seed AutofireEmail, seed_method,             :action_page_id, :language_id,      seeder.autofire_emails
    seed ContentPageCollection, seed_method,     :name, :movement_id,                seeder.collections
    seed Page, seed_method,                      :name, :content_page_collection_id, seeder.content_pages

    seed ContentModule, seed_method,             :id,                                seeder.content_modules
    seed ContentModuleLink, seed_method,         :content_module_id, :page_id,       seeder.content_module_links

    seed FeaturedContentCollection, seed_method, :name, :featurable_id,              seeder.featured_content_collections
    seed FeaturedContentModule, seed_method,     :featured_content_collection_id, :language_id, :title, seeder.featured_content_modules
  end

  def self.seed(model_class, seed_method, *args)
    seeds = args.last
    return if seeds.empty?

    model_class.send seed_method, *args
  end
end