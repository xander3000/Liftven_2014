class Backend::WebDesign::CustomDesignsController < Backend::WebDesign::BaseController

	def index
		
	end

	def new
		self.multimedia_files_uploads_reset
		@custom_design = CustomDesign.new
		@multimedia_files = []
	end

	def select_multimedia_file_by_type_design
		custom_design = CustomDesign.last(:conditions => {:type_design => params[:custom_design][:type_design],:category_design => params[:custom_design][:category_design]})
		@multimedia_files = custom_design.nil? ? [] : custom_design.multimedia_files
		multimedia_files_uploads_clear
		@multimedia_files.each do |multimedia_file|
			self.multimedia_files_uploads << 	multimedia_file.id
		end
	end

	def set_category_design

		@type_design = params[:custom_design][:type_design]
		@custom_design_type = CustomDesignType.find(@type_design)
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

	def add_custom_design_category_type
		@custom_design_category_type = CustomDesignCategoryType.new
		@custom_design_type_design = CustomDesignType.find_by_id(params[:custom_design_type_design_id])
		@custom_design_category_type.custom_design_type = @custom_design_type_design
	end

	def process_add_custom_design_category_type
		@custom_design_category_type = CustomDesignCategoryType.new(params[:custom_design_category_type])
		@success = @custom_design_category_type.valid?
		if @success
			@custom_design_category_type.save
			@custom_design_type = @custom_design_category_type.custom_design_type
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
