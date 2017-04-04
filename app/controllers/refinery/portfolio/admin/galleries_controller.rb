module Refinery
  module Portfolio
    module Admin
      class GalleriesController < ::Refinery::AdminController

        crudify :'refinery/portfolio/gallery',
                :order => 'lft ASC',
                :include => [:children],
                :paging => false

        def new
          @gallery = ::Refinery::Portfolio::Gallery.new(:parent_id => find_parent_gallery)
        end

        def children
          @gallery = find_gallery
          render :layout => false
        end

        def destroy_items
          @gallery = find_gallery
          @gallery.items.each do  |item|
            item.image.destroy
            item.destroy
          end
          redirect_to :back
        end

        def process_import
          image_name = params[:image_name].force_encoding('iso-8859-1').encode('utf-8')
          image_mime_type = params[:image_mime_type].force_encoding('iso-8859-1').encode('utf-8')
          image_size = params[:image_size].to_s
          image_width = params[:image_width].to_s
          image_height = params[:image_height].to_s
          image_uid = params[:image_uid].force_encoding('iso-8859-1').encode('utf-8')

          #Refinery Image Model
          image = Refinery::Image.new
          image.image_name = image_name
          image.image_mime_type = image_mime_type
          image.image_size = image_size
          image.image_width = image_width
          image.image_height = image_height
          image.image_uid = image_uid
          image.save!

          Refinery::Portfolio::Item.create!(:image_id => image.id, :gallery_id => params[:portfolio_id])

          redirect_to :back, notice: 'Importing Images'
        end

      

        protected

        def find_parent_gallery
          @parent_gallery = ::Refinery::Portfolio::Gallery.find(params[:parent_id]) if params[:parent_id].present?
        end

        def find_gallery
          @gallery = ::Refinery::Portfolio::Gallery.find(params[:id]) if params[:id].present?
        end

      end
    end
  end
end
