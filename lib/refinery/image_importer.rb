module Refinery
	class ImageImporter
	  require "aws-sdk"
    require "open-uri"

	  def initialize(gallery_id)
	  	OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
			OpenURI::Buffer.const_set 'StringMax', 0
			@gallery_id = gallery_id
     	@objects = S3_BUCKET.objects(prefix: "portfolio/#{gallery_id}")
	  end

	  def import
	  	@objects.each do |object|
	  		image_id = create_image(object.public_url, object.key)
	  		create_portfolio_item(image_id)
	  		object.delete
	  	end
	  end

	  def create_image(url, key)
	  	img = Refinery::Image.new
			img.image = open(url).read
			img.image_name = file_name(key)
			img.save!
			img.id
	  end

	  def file_name(s)
    	slash_index = s.index('/')
    	s[(slash_index + 1)..s.length]
  	end

  	def create_portfolio_item(image_id)
  		Refinery::Portfolio::Item.create(:image_id => image_id, :gallery_id => @gallery_id)
  	end
	  
	end
end
