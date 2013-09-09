module Admin
  module MovementHelper
    def movement_languages(movement)
      languages = movement.non_default_languages.map(&:name).sort
      languages = ["#{movement.default_language.name} (default)",languages].flatten if movement.default_language
      languages.to_sentence
    end

    def member_stats
      stats_group(prepare_member_stats)
    end

    def miscellaneous_stats
      stats_group(prepare_misc_stats)
    end

    def stats_group(stats=[])
      content_tag(:div, class: 'stats') do
        stats.collect do |k,v|
          concat(content_tag(:p, class: 'desc') do
            concat(content_tag(:span, class: 'number') do
              "#{number_with_delimiter(v, :locale => I18n.locale)}"
            end)
            concat("#{ k.is_a?(String) ? k : k.to_s.titleize}")
          end)
        end
      end
    end

    private

    def prepare_misc_stats
      actions_in_the_last_week = UserActivityEvent.actions_taken.where(:movement_id => @movement.id).where("created_at > ?", 1.week.ago).count
      languages_count = @movement.languages.count

      {'Actions in the Last Week' => actions_in_the_last_week,
       "Languages: #{movement_languages(@movement)}" => languages_count}
    end

    def prepare_member_stats
      stats = {active_members: nil,
               joins: @movement.members.count,
               unsubscribes: @movement.unsubscribed_members.count}
      stats[:active_members] = stats[:joins] - stats[:unsubscribes]
      stats
    end

  end
end