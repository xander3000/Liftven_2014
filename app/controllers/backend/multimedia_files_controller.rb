class Backend::MultimediaFilesController < Backend::BaseController

  def destroy
    
    multimedia_files_uploads_delete(params[:id])
    multmedia_file = MultimediaFile.destroy(params[:id])
    render :text => multmedia_file.id
  end


  def multimedia_files_uploads_delete(multmedia_file_id)
     #session[:orders_multimedia_files].delete(multmedia_file_id.to_i)
  end

end
