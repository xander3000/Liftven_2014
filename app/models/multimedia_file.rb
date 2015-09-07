class MultimediaFile < ActiveRecord::Base

	humanize_attributes :name => "Nombre",
											:attach => "Recurso"


  belongs_to :proxy,:polymorphic => true
  has_attached_file :attach, :styles => { :thumb => ["80x80#", :png]},
                    :url  => "/uploads/multimedia_file/:attachment/:id/:style/:filename",
                    :path => ":rails_root/public:url"


  validates_attachment_presence :attach
  alias_attribute(:name, :attach_file_name)




  #
  # Retorna el la url del thumbnail
  #

  def thumbnail_url
      attach.url(:thumb)
  end

  #
  # Retorna el la url para eliminar el objeto
  #

  def delete_url
      attach.url
  end

  #
  # Methodo REST para eliminar
  #
  def delete_type
    "DELETE"
  end

  #
  #  Retorna el la url para un enlace web
  #
  def web_url(site_url)
    "#{site_url}#{attach.url}"
  end
end
