module Paperclip
  class Resizer < Processor

    attr_accessor :target_geometry

    def initialize file, options = {}, attachment = nil
      super

      @target = attachment.instance
      @target_geometry = Geometry.new(@target.image_width, @target.image_height)
    end

    # Performs the conversion of the +file+ into a thumbnail. Returns the Tempfile
    # that contains the new image.
    def make
      src = @file
      dst = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
      dst.binmode

      begin
        parameters = [":source", "-format jpeg"]
        parameters << resize_command if resize_command
        parameters << ":dest"

        parameters = parameters.join(" ").strip.squeeze(" ")

        success = Paperclip.run("convert", parameters, :source => "#{File.expand_path(src.path)}[0]", :dest => File.expand_path(dst.path))
      rescue Paperclip::CommandNotFoundError,Cocaine::ExitStatusError => e
        raise PaperclipError, "There was an error resizing #{@basename}" if @whiny
      end

      dst
    end
    
    def resize_command
      target = @attachment.instance
      if target.image_resize
        " -resize '#{target.image_width}x#{target.image_height}'"
      end
    end
  end
end
