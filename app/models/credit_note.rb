class CreditNote < ActiveRecord::Base

  humanize_attributes :credit_note_emision_type => "Tipo de emisión",
                      :invoice => "Factura afectada",
											:administrative_expenses => "Gastos administrativos",
											:client => "Cliente",
											:created_at => "Fecha de emisión",
											:id => "Numero de N/C"

  belongs_to :client
  belongs_to :credit_note_emision_type
  belongs_to :invoice
  has_many :product_by_credit_notes

  validates_presence_of :credit_note_emision_type
  validates_presence_of :invoice,:if => Proc.new { |credit_note| credit_note.credit_note_emision_type and credit_note.credit_note_emision_type.invoice_required }
	validates_numericality_of :administrative_expenses,:greater_than_or_equal_to => 0,:less_than_or_equal_to => 100#,:allow_nil => true


  MIN_AMOUNT = 1

  #
  # Calcula el sub_total y total de la nota de credito
  #
  def set_values_sub_total_total
    aux_sub_total = 0
    product_by_credit_notes.each do |product_by_credit_note|
      aux_sub_total += product_by_credit_note.total_price
    end
    self.sub_total = aux_sub_total
    #tax = TAX*self.sub_total
    self.total = self.sub_total + applicable_taxes_administrative_expenses
    self.save
  end


  #
  # Calcula el impuesto
  #
  def tax
    return 0 if self.sub_total.nil?
    self.sub_total*AppConfig.tax_percentage
  end

	#
	# Calucla los impuestos y gastos administrativos si aplica
	#
	def applicable_taxes_administrative_expenses
		total_taxes_administrative_expenses = 0
		tax_aux = AppConfig.tax_percentage*self.sub_total
		
		#total_taxes_administrative_expenses += tax_aux
		total_taxes_administrative_expenses -= self.administrative_expenses.to_f*self.sub_total/100
		#self.tax = tax_aux

		total_taxes_administrative_expenses.round(2)
	end

	#
	# Imprime la factura en impresora fical
	#
	def print
		hostname = PRINTER_HOST
		port = PRINTER_PORT
		logger.info "********* CreditNote(#{id}).print *********"
		logger.info "\tOPEN CONNECTION WITH #{hostname}:#{port}"
		s = TCPSocket.open(hostname, port)
		logger.info "\tWRITE CONNECTION: invoice,#{id}"
		logger.info "****************************************"
		s.write("credit_note,#{id}")
		s.close
	end


end
