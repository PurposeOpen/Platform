class Api::SharesController < Api::BaseController
  skip_before_filter :set_locale

  def create
    share = Share.new(params.slice('user_id', 'share_type', 'page_id'))

    if valid?(share)
      share.save!
      head :ok
    else
      head 400
    end
  end

  def share_counts
    page_id = params['page_id']

    return 400 if page_id.blank?

    render :json => Share.counts(page_id)
  end 

  private

  def valid?(share)
    return share.valid? && Page.find(share.page_id).is_tell_a_friend?
  end

end