class Mailer < ActionMailer::Base
  
def prueba
    subject "Nueva Clave"
    #body :usuario_nueva_clave => usuario_nueva_clave
    recipients "gplaza86@gmail.com"
    headers["reply-to"] = CONTACT_REPLY_TO
    from CONTACT_RECIPIENT
#
#    @file_name = "/tmp/venom_logo.png"
#    attachment :content_type => "image/png",:filename => "ax.png",:body => File.read(@file_name)
#        attachment :content_type => "image/png",:filename => "ax.png",:body => File.read(@file_name)
    #delete_attachment_file
    #content_type "multipart/mixed"
		content_type "text/html"
  end


  def send_notification_email_design(design,caso)
    subject "Diseño Venom Impresos ESPECIFICAR ASUNTO"
    body :design => design,:caso => caso
    recipients "#{caso.order.client.contact.email}"
    #recipients "gabriel.plaza86@gmail.com"
    headers["reply-to"] = CONTACT_REPLY_TO
    from CONTACT_RECIPIENT
    design.multimedia_files.each do |multimedia_file|
      @file_name = "#{multimedia_file.attach.path}"
      attachment :content_type => multimedia_file.attach_content_type,:filename => "#{multimedia_file.attach_file_name}",:body => File.read(@file_name)
    end
    
    content_type "text/html"
  end

	def send_payment_receipt(regular_payroll_check,employee,file_path)
		owner = Supplier.find_owner
		contact = owner.contact
		subject "Recibo de pago Nomina #{regular_payroll_check.name}"
    body :regular_payroll_check => regular_payroll_check,:employee => employee,:contact => contact,:owner => owner
    recipients "#{employee.payroll_staff.email}"
    headers["reply-to"] = CONTACT_REPLY_TO
    from CONTACT_RECIPIENT
    attachment :content_type => "application/pdf",:filename => "ReciboPago.pdf",:body => File.read(file_path)
    content_type "text/html"
	end

end
