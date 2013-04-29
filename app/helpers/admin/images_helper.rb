module Admin
  module ImagesHelper
    def image_settings_div(movement, settings_for)
      content_tag(:div, '', {:id => "image-upload-container",
                  :style => "display:none;", :title => "Upload and Attach Image",
                  :data => {:image_upload_url => admin_movement_images_path(movement)}.merge(movement.image_settings_for(settings_for))})
    end

    def image_url(image, format = :original)
      url = S3[:enabled] ? "#{AppConstants.s3_bucket_uri}/#{image.name(format)}" :
          "//#{request.host_with_port}/system/#{image.name(format)}"
      if url.start_with?'http'
        url
      else
        url = "#{protocol}:#{url}"
      end
      url
    end

    def protocol
      Rails.env == ('development' || 'test')?'http' : 'https'
    end

    def hosted_image_tag(image, parms = {})
      parms[:alt] = image.image_description if image.image_description
      parms[:width] = image.image_width.to_s if image.image_width
      parms[:height] = image.image_height.to_s if image.image_height
      image_tag(image_url(image, :full), parms)
    end

    def image_info(image)
      info = { "Image URL" => image_url(image, :full) }
      if Feature[:assets][:show_full_asset_details]
        info["Original URL"] = image_url(image, :original)
        info["Thumbnail URL"] = image_url(image, :thumbnail)
        info["Image type"] = image.image_content_type
        info["File Size"] = "#{number_to_human_size(image.image_file_size) } (#{image.image_file_size } bytes)"
        if image.image_width
          info["Dimensions"] = "#{ image.image_width } x #{ image.image_height } pixels (width x height)"
        end
      end
      info
    end
  end
end
