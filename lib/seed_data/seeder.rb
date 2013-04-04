# encoding: utf-8

module SeedData
  class Seeder < Struct.new(:movement)

    def locales;                      []; end
    def campaigns;                    []; end
    def action_sequences;             []; end
    def homepage;                     []; end
    def homepage_contents;            []; end
    def action_pages;                 []; end
    def autofire_emails;              []; end
    def collections;                  []; end
    def content_pages;                []; end
    def featured_content_collections; []; end
    def featured_content_modules;     []; end
    def content_modules;              []; end
    def content_module_links;         []; end

    private

    def movement_id
      movement.id
    end

    def language_id(iso_code)
      Language.find_by_iso_code(iso_code).try(:id) or
        raise ActiveRecord::RecordNotFound, "can't find Language for #{iso_code}"
    end

    def homepage_id
      movement.homepage.id
    end

    def locale_id(iso_code)
      lookup MovementLocale, :movement_id => movement_id, :language_id => language_id(iso_code)
    end

    def campaign_id(name)
      lookup Campaign, :name => name, :movement_id => movement_id
    end

    def action_sequence_id(campaign_name, aseq_name)
      lookup ActionSequence, :name => aseq_name, :campaign_id => campaign_id(campaign_name)
    end

    def page_id(campaign_name, aseq_name, page_name)
      lookup Page, :name => page_name, :action_sequence_id => action_sequence_id(campaign_name, aseq_name)
    end

    def content_page_id(collection_name, page_name)
      lookup Page, :content_page_collection_id => collection_id(collection_name), :type => ContentPage.name, :name => page_name
    end

    def collection_id(name)
      lookup ContentPageCollection, :name => name, :movement_id => movement_id
    end

    def html(file)
      movement.save
      Rails.root.join("lib", "seed_data", "html", movement.friendly_id, "#{file}.html").read
    end

    def featured_content_collection_id(name, featurable_id)
      lookup FeaturedContentCollection, :name => name, :featurable_id => featurable_id
    end

    def lookup(model, attrs={})
      model.where(attrs).first.try(:id) or raise ActiveRecord::RecordNotFound, "can't find #{model} for #{attrs.inspect}"
    end

    # pattern for ids: movement-page-language-counter
    # example:
    # walkfree = second movement
    # learn page = second page in walkfree
    # vi = 4th language in walkfree
    # third module in vi for the learn page on walkfree = id 2243
    def links_for_page_and_modules(page_id, opts = {})
      opts.map do |layout_container, module_ids|
        module_ids = Array(module_ids)

        module_ids.map.with_index do |module_id, position|
          position += 1
          {:content_module_id => module_id, :page_id => page_id, :layout_container => layout_container, :position => position}
        end
      end.flatten
    end

    def required_user_details
      ActionPage::DEFAULT_REQUIRED_USER_DETAILS.inject({}) do |required_details, detail|
        required_details.merge detail[:field] => detail[:default]
      end
    end

  end
end