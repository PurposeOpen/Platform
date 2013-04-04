#This renderer just skips printing the 'Previous' and 'Next' links by overriding the appropriate methods
class WillPaginateCustomRenderer < WillPaginate::ViewHelpers::LinkRenderer
  protected
  def previous_page;end
  def next_page;end
end
