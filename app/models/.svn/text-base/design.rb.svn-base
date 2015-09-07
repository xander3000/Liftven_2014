class Design < ActiveRecord::Base

  humanize_attributes :note => "Comentario"

  has_many :multimedia_files,:as => :proxy
  has_one :doc,:as => :category
  has_attached_file :attach,
                    :url  => "/attachments/designs/:id/:basename.:extension",
                    :path => ":rails_root/public/attachments/designs/:id/:basename.:extension"

  validates_presence_of :note



  #
  # Asocia un caso al diseño
  #
  def associate_case(caso)
       object_doc = Doc.new
       object_doc.case = caso
       object_doc.category = self
       object_doc.save
  end


  #
  # Obtiene el caso asociado al diseño
  #
  def caso
    doc.case
  end

  #
  # Envia una notificacion al cliente informando del diseño
  #
  def send_notification_email
      begin
        logger.info "---Enviando correo---"
        Mailer::deliver_send_notification_email_design(self,caso)
        logger.info "---Correo enviado exitosamente---"
      rescue Exception => e
          logger.error "---Error enviando correo---"
		   		logger.error e
          logger.error "------"
      end
  end


  def self.prueba
		begin
			Mailer::deliver_prueba
		rescue Exception => e
			p e
		end
  end
end
