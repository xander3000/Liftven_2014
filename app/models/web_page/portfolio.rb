class WebPage::Portfolio < ActiveRecord::Base
	def self.table_name_prefix
    'web_page_'
  end
  has_many :multimedia_files,:as => :proxy
  has_one :doc,:as => :category
  has_attached_file :attach,
                    :url  => "/attachments/home_page_slides/:id/:basename.:extension",
                    :path => ":rails_root/public/attachments/home_page_slides/:id/:basename.:extension"



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
