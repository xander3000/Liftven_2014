class Backend::Cpanel::WebPage::HomePageSlidesController < Backend::Cpanel::WebPage::BaseController
	def index

	end

	def new
		self.multimedia_files_uploads_reset
		@home_page_slide = HomePageSlide.new
		@multimedia_files = HomePageSlide.last.nil? ? [] : HomePageSlide.last.multimedia_files
		@multimedia_files.each do |multimedia_file|
			self.multimedia_files_uploads << 	multimedia_file.id
		end
	end
	
  def upload

    multimedia_files  = []
    params[:files].each do |file|
      multimedia_file = MultimediaFile.new(:attach => file)
      success = multimedia_file.valid?
      if success
        multimedia_file.save
        multimedia_file_json = {:name => multimedia_file.attach_file_name,
                                :size => multimedia_file.attach_file_size,
																:type => multimedia_file.attach_content_type,
                                :url => multimedia_file.attach.url,
                                :thumbnailUrl => multimedia_file.thumbnail_url,
                                :deleteUrl => backend_multimedia_file_url(multimedia_file),
                                :deleteType => multimedia_file.delete_type}#
        # = multimedia_file.attach.to_json(:only => [:name],:methods => [:size,:url,:thumbnail_url])
        #multimedia_file_json = multimedia_file_json.to_json
        self.multimedia_files_uploads = multimedia_file.id
        multimedia_files << multimedia_file_json
      end

    end
    json = JSON.generate(:files => multimedia_files)
    render :text => json
  end

	def delete_prev
		multimedia_files = MultimediaFile.find(params[:multimedia_file_id])
		self.multimedia_files_uploads_delete(multimedia_files.id)
		multimedia_files.delete
		@multimedia_files = HomePageSlide.last.multimedia_files
	end

	def destroy_upload
		
	end


	def create

    @home_page_slide = HomePageSlide.new(params[:custom_design])
    @success = @home_page_slide.valid?
    @success &= !multimedia_files_uploads.empty?
    if @success
      @home_page_slide.save
      multimedia_files_uploads.each do |multimedia_file|
        multimedia_file = MultimediaFile.find(multimedia_file)
        multimedia_file.update_attributes(:proxy_id => @home_page_slide.id,:proxy_type => @home_page_slide.class.to_s)
      end
      multimedia_files_uploads_clear
      flash[:notice] = "Diseño actualizados!"
    else

    end
  end

	protected


  def multimedia_files_uploads=(multimedia_files_id)
    session[:home_page_slides_multimedia_files] = [] if session[:home_page_slides_multimedia_files].nil?
    session[:home_page_slides_multimedia_files] << multimedia_files_id
  end

  def multimedia_files_uploads
    session[:home_page_slides_multimedia_files] = [] if session[:home_page_slides_multimedia_files].nil?
    session[:home_page_slides_multimedia_files]
  end

	def multimedia_files_uploads_delete(multimedia_files_id)
    session[:home_page_slides_multimedia_files].delete(multimedia_files_id)
  end

  def multimedia_files_uploads_clear
    session[:home_page_slides_multimedia_files].clear
  end

  def multimedia_files_uploads_reset
    session[:home_page_slides_multimedia_files] = []
  end
end
