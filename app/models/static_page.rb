class StaticPage
  def self.global_donation
    @global_donation_page ||= ActionSequence.static.where(:name => "Donate").first.action_pages.first
  end
end