class IncomingInvoice < ActiveRecord::Base

	PAYABLE = "payable"
	PAID = "paid"
	CANCELED = "canceled"
	BACKWARD = "backward"

	 humanize_attributes	:purchase_order => "Pedido",
												:supplier => "Proveedor",
												:currency_type => "Moneda",
												:currency_type_short => "Mo.",
												:create_by => "Creado por",
												:delivery_date => "Fecha estima de entrega",
												:posting_date => "Contabilización",
												:invoice_date => "Fecha de la factura",
												:reference => "Referencia",
												:description => "Texto",
												:tax => "Impuesto",
												:base => "Entrada de Factura",
												:control_number => "Número de control",
												:id => "Numero de documento",
												:total => "Importe",
												:balance => "Balance",
												:incoming_invoice_document_type => "Tipo de documento"
											
	belongs_to :purchase_order
	belongs_to :supplier
	belongs_to :currency_type
	belongs_to :create_by,:class_name => "User"
	belongs_to :incoming_invoice_document_type
	has_many :incoming_invoice_positions
	has_many :incoming_invoice_payments,:order => "id DESC"

	validates_presence_of :supplier,
												:currency_type,
												:create_by,
												:posting_date,
												:reference,
												:description,
												:tax,
												:invoice_date


	#
	# Retorna true si fueron agregados position al incoming_invoice
	#
	def has_added_item_positions?(incoming_invoice_positions_added)
		if incoming_invoice_positions_added.empty?
			 errors.add_to_base("debe seleccionar al menos un material")
			 false
		end
		true
	end

	#
	# Expresa el total de las posiction
	#
	def total
		incoming_invoice_positions.map(&:total).to_sum
	end

	#
	# Expresa el total de las posiction - los pagos realizados
	#
	def balance
		total.to_f - amount_payments.to_f
	end

	#
	# Total en pagos
	#
	def amount_payments
		incoming_invoice_payments.map(&:amount).to_sum
	end

	#
	# Coneviret su valores  ahash
	#
	def to_hash
		{"reference"=>reference, "description"=>description, "reference_document_type"=>"IncomingInvoice", "amount"=>total, "control_number"=>control_number, "reference_document_id"=>id}
	end

	#
	#
	#
	def name
		"#{self.class.model_humanize_name} (#{id.to_code})"
	end

	#
	# Cambiar status a pagada
	#
	def status_to_paid
		update_attribute(:status, PAID)
	end

	#
	# Verifica si la factura esta por pagar
	#
	def is_payable?
		status.eql?(PAYABLE)
	end

	#
	# Nombre del modelo
	#
	def self.model_humanize_name
		"Entrada de Factura"
	end

	#
	# Busca todos las facturas pendeinte spor pagar
	#
	def self.all_payables
		all(:conditions => {:status => PAYABLE})
	end

end
