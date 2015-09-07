class Backend::Cpanel::WebPage::CustomDesignsController < Backend::Cpanel::WebPage::BaseController

	def index

	end

	def new
		self.multimedia_files_uploads_reset
		@custom_design = CustomDesign.new
		@multimedia_files = []
	end

	def select_multimedia_file_by_type_design
		custom_design = CustomDesign.last(:conditions => {:type_design => params[:custom_design][:type_design]})
		@multimedia_files = custom_design.nil? ? [] : custom_design.multimedia_files
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
                                :url => multimedia_file.attach.url,
                                :thumbnail_url => multimedia_file.thumbnail_url,
                                :delete_url => backend_multimedia_file_url(multimedia_file),
                                :delete_type => multimedia_file.delete_type}#
        # = multimedia_file.attach.to_json(:only => [:name],:methods => [:size,:url,:thumbnail_url])
        #multimedia_file_json = multimedia_file_json.to_json
        self.multimedia_files_uploads = multimedia_file.id
        multimedia_files << multimedia_file_json
      end

    end
    json = JSON.generate(multimedia_files)
    render :text => json
  end

	def delete_prev
		multimedia_files = MultimediaFile.find(params[:multimedia_file_id])
		self.multimedia_files_uploads_delete(multimedia_files.id)
		multimedia_files.delete
		@multimedia_files = CustomDesign.last.multimedia_files
	end

	def create

    @design = CustomDesign.new(params[:custom_design])
    @success = @design.valid?
    @success &= !multimedia_files_uploads.empty?
    if @success
      @design.save
      multimedia_files_uploads.each do |multimedia_file|
        multimedia_file = MultimediaFile.find(multimedia_file)
        multimedia_file.update_attributes(:proxy_id => @design.id,:proxy_type => @design.class.to_s)
      end
      multimedia_files_uploads_clear
      flash[:notice] = "Diseño actualizados!"
    else

    end
  end

	protected


  def multimedia_files_uploads=(multimedia_files_id)
    session[:custom_designs_multimedia_files] = [] if session[:custom_designs_multimedia_files].nil?
    session[:custom_designs_multimedia_files] << multimedia_files_id
  end

  def multimedia_files_uploads
    session[:custom_designs_multimedia_files] = [] if session[:custom_designs_multimedia_files].nil?
    session[:custom_designs_multimedia_files]
  end

	def multimedia_files_uploads_delete(multimedia_files_id)
    session[:custom_designs_multimedia_files].delete(multimedia_files_id)
  end

  def multimedia_files_uploads_clear
    session[:custom_designs_multimedia_files].clear
  end

  def multimedia_files_uploads_reset
    session[:custom_designs_multimedia_files] = []
  end
end
