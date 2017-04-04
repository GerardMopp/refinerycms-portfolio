module Refinery
  module Portfolio
    module Admin
      class ItemsController < ::Refinery::AdminController
        include Refinery::Portfolio

        crudify :'refinery/portfolio/item',
                :order => 'position ASC',
                :xhr_paging => false,
                :paging => false

        before_filter :find_gallery, :only => [:index]
        before_filter :set_s3_direct_post, only: [:index, :create]

        def index
          if params[:orphaned]
            @items = Item.orphaned.order('position ASC')
          elsif params[:gallery_id]
            @items = @gallery.items.order('position ASC')
          else
            redirect_to refinery.portfolio_admin_galleries_path and return
          end

          @items = @items.page(params[:page])
        end

        def new
          @item = Item.new(:gallery_id => find_gallery)
        end

        def create
            # if the position field exists, set this object as last object, given the conditions of this class.
            if Refinery::Portfolio::Item.column_names.include?("position") && params[:item][:position].nil?
              params[:item].merge!({
                :position => ((Refinery::Portfolio::Item.maximum(:position)||-1) + 1)
              })
            end


            if params[:item][:image].present?
              
              img = ::Refinery::Image.new
              img.image = params[:item][:image]
              img.save!

              @item = ::Refinery::Portfolio::Item.new
              @item.image_id = img.id
              @item.gallery_id = params[:item][:gallery_id]


              if @item.save!
                render json: { message: "success", item: @item, image_url: img.thumbnail(::Refinery::Portfolio.cover_image_thumb_size).url }, :status => 200
              else
                render json: { error: @item.errors.full_messages.join(',')}, :status => 400
              end
              
            else
               if (@item = Refinery::Portfolio::Item.create(params[:item])).valid?
                  flash.notice = t(
                    'refinery.crudify.created',
                    :what => "'\#{@item.#{options[:title_attribute]}}'"
                  )
                  unless from_dialog?
                    unless params[:continue_editing] =~ /true|on|1/
                      redirect_back_or_default("refinery.#{Refinery.route_for_model(class_name.constantize, :plural => true)}")
                    else
                      unless request.xhr?
                        redirect_to :back
                      else
                        render :partial => '/refinery/message'
                      end
                  end
               else
                  self.index
                  @dialog_successful = true
                  render :index
               end
            else
              unless request.xhr?
                render :action => 'new'
              else
                render :partial => '/refinery/admin/error_messages', :locals => {
                         :object => @item,
                         :include_object_name => true
                       }
                end
              end


            end

          end

          def destroy
             @item = Refinery::Portfolio::Item.find(params[:id])
          if @item.destroy
            flash.notice = t('destroyed', :scope => 'refinery.crudify', :what => "#{@item.id}")
          end
            redirect_to :back
          end

          def destroy_images
            
          end

        private
        def find_gallery
          @gallery = Gallery.find(params[:gallery_id]) if params[:gallery_id]
        end

         def set_s3_direct_post
          @s3_direct_post = S3_BUCKET.presigned_post(key: "portfolio/#{@gallery.id}/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
         end

      end
    end
  end
end
