module Refinery
	class ImageSaver
	  require 'open-uri'

	  def initialize(class_name, id, image_field, image_url)

	  	OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
			OpenURI::Buffer.const_set 'StringMax', 0

	  	item = class_name.constantize.find(id)

	  	image_name = image_url.split('/').last
			
			img = ::Auction::Image.new 

			img.image = File.new(open("http:" + image_url))
			img.image_name = image_name
			img.save!

		 	item.update_column(:"#{image_field}_id", img.id)
	  end

	  
	end
end
