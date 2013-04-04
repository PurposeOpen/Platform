class UpdateFaceSlaveryContentModulesContent < ActiveRecord::Migration
  def up
    ActionPage.serialize(:required_user_details)
    ContentModule.serialize(:options)

  	page = Page.find_by_name('faceslavery')
  	return unless page

  	flickr_gallery_modules = page.content_modules.find_all { |cm| cm.type = "HtmlModule" and cm.content =~ /flickr\.com/i }
  	return unless flickr_gallery_modules

  	flickr_gallery_modules.each do |fgm|
  		fgm.content = <<-HTML
	  		<div class="module_content">
					<object width="100%" height="300">
						<param name="flashvars" value="offsite=true&lang=en-us&page_show_url=%2Fphotos%2Fwalkfreeorg%2Fsets%2F72157631576294130%2Fshow%2F&page_show_back_url=%2Fphotos%2Fwalkfreeorg%2Fsets%2F72157631576294130%2F&set_id=72157631576294130&jump_to="></param>
						<param name="movie" value="http://www.flickr.com/apps/slideshow/show.swf?v=122138"></param>
						<param name="allowFullScreen" value="true"></param>
						<embed type="application/x-shockwave-flash" src="http://www.flickr.com/apps/slideshow/show.swf?v=122138" allowFullScreen="true" flashvars="offsite=true&lang=en-us&page_show_url=%2Fphotos%2Fwalkfreeorg%2Fsets%2F72157631576294130%2Fshow%2F&page_show_back_url=%2Fphotos%2Fwalkfreeorg%2Fsets%2F72157631576294130%2F&set_id=72157631576294130&jump_to=" width="100%" height="300"></embed>
					</object>
				</div>
	  	HTML
	  	fgm.save
    end

    ActionPage.serialize(:required_user_details, JSON)
    ContentModule.serialize(:options, JSON)
  end

  def down
  end
end
