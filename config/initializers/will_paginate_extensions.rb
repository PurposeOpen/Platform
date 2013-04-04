# encoding: utf-8
require 'will_paginate/core_ext'
require 'will_paginate/i18n'

module WillPaginate
  module ViewHelpers
    # This fixes plurals for models
    def page_entries_info(collection, options = {})
      model = options[:model]
      model = collection.first.class unless model or collection.empty?
      model ||= 'entry'
      model_key = if model.respond_to? :model_name
                    model.model_name.i18n_key  # ActiveModel::Naming
                  else
                    model.to_s.underscore
                  end
      if options.fetch(:html, true)
        b, eb = '<b>', '</b>'
        sp = '&nbsp;'
        html_key = '_html'
      else
        b = eb = html_key = ''
        sp = ' '
      end

      model_count = collection.total_pages > 1 ? 5 : collection.size
      defaults = ["models.#{model_key}"]
      defaults << Proc.new { |_, opts|
        if model.respond_to? :model_name
          opts[:count] > 1 ? model.model_name.plural : model.model_name.singular
        else
          name = model_key.to_s.tr('_', ' ')
          raise "can't pluralize model name: #{model.inspect}" unless name.respond_to? :pluralize
          opts[:count] == 1 ? name : name.pluralize
        end
      }
      model_name = will_paginate_translate defaults, :count => model_count

      if collection.total_pages < 2
        i18n_key = :"page_entries_info.single_page#{html_key}"
        keys = [:"#{model_key}.#{i18n_key}", i18n_key]

        will_paginate_translate keys, :count => collection.size, :model => model_name do |_, opts|
          case opts[:count]
          when 0; "No #{opts[:model]} found"
          when 1; "Displaying #{b}1#{eb} #{opts[:model]}"
          else    "Displaying #{b}all#{sp}#{opts[:count]}#{eb} #{opts[:model]}"
          end
        end
      else
        i18n_key = :"page_entries_info.multi_page#{html_key}"
        keys = [:"#{model_key}.#{i18n_key}", i18n_key]
        params = {
          :model => model_name, :count => collection.total_entries,
          :from => collection.offset + 1, :to => collection.offset + collection.length
        }
        will_paginate_translate keys, params do |_, opts|
          %{Displaying %s #{b}%d#{sp}-#{sp}%d#{eb} of #{b}%d#{eb} in total} %
            [ opts[:model], opts[:from], opts[:to], opts[:count] ]
        end
      end
    end
  end
end
