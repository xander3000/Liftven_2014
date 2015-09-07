class AccountPayable::IncomingInvoice < ActiveRecord::Base
	def self.table_name_prefix
    'account_payable_'
  end
  attr_accessor :tenderer_name,:supplier_name
  
  humanize_attributes :material_purchase_order => "Orden de compra",
                      :currency_type => "Moneda",
                      :account_payable_incoming_invoice_document_type => "Tipo de documento",
                      :supplier => "Proveedor",
                      :supplier_name => "Proveedor",
                      :tenderer => "Beneficiario de abono",
                      :tenderer_name => "Beneficiario de abono",
                      :tenderer_type => "Tipo de Relación",
                      :create_by => "Creador por",
                      :account_payable_incoming_invoice_status_type => "Estatus",
                      :amount_total_to_paid => "Total a pagar",
                      :posting_date => "Contabilización",
											:purchase_ledger_period => "Periodo libro compras afectado",
                      :invoice_date => "Fecha de la factura",
                      :reference => "N° Factura Fiscal",
                      :description => "Descripción",
                      :tax => "Impuesto",
											:tax_amount => "Monto del impuesto",
											:retained_amount => "Monto retenido",
                      :base => "Entrada de Factura",
                      :control_number => "Número de control",
                      :id => "Número de documento",
                      :sub_total_amount => "Sub Total",
											:sub_total => "Sub Total",
                      :total_amount => "Total",
											:total  => "Total",
											:created_at => "Fecha de creación",
											:no_deductible => "No deducible",
											:associated_purchase_ledgers => "¿Asociado al libro de compras?",
											:municipal_tax => "¿Impuesto municipal?",
											:legal_contractual_voluntary_obligation => "¿obligación legal, contractual y voluntaria?",
											:with_affectation_inventory => "¿Con afectación de inventario?",
                      :tax_exempt => "¿Exento de IVA?",
											:account_payable_incoming_invoice_status_types => "Estatus"

	alias_attribute :sub_total, :sub_total_amount
	alias_attribute :total, :total_amount
	alias_attribute :beneficiary, :tenderer


  belongs_to :material_purchase_order,:class_name => "Material::PurchaseOrder",:foreign_key => "purchase_purchase_order_id"
	belongs_to :create_by,:class_name => "User"
	belongs_to :account_payable_incoming_invoice_document_type,:class_name => "AccountPayable::IncomingInvoiceDocumentType"
	belongs_to :tenderer,:polymorphic => true
  belongs_to :supplier
  belongs_to :currency_type
	has_one :accounting_payable_account,:as => :doc,:class_name => "Accounting::PayableAccount"
	has_many :account_payable_incoming_invoice_positions,:class_name => "AccountPayable::IncomingInvoicePosition",:foreign_key => "account_payable_incoming_invoice_id"
	has_many :account_payable_incoming_invoice_retentions,:class_name => "AccountPayable::IncomingInvoiceRetention",:foreign_key => "account_payable_incoming_invoice_id"
	has_many :account_payable_payment_orders,:class_name => "AccountPayable::PaymentOrder",:as => :doc
	has_many :cash_bank_bank_movements,:class_name => "CashBank::BankMovement",:as => :reference_document
	has_many :account_payable_status_incoming_invoices,:class_name => "AccountPayable::StatusIncomingInvoice",:foreign_key => "account_payable_incoming_invoice_id"
	has_many :account_payable_incoming_invoice_status_types,:class_name => "AccountPayable::IncomingInvoiceStatusType",:foreign_key => "account_payable_incoming_invoice_id", :through => :account_payable_status_incoming_invoices
	has_many :account_payable_incoming_invoice_taxes,:class_name => "AccountPayable::IncomingInvoiceTax",:foreign_key => "account_payable_incoming_invoice_id"

  after_create :create_payable_account,:set_value_balance,:set_default_status_type
  #after_update :update_payable_account,:set_value_balance,:set_default_status_type

	validates_presence_of :account_payable_incoming_invoice_document_type,:tenderer,:description,:sub_total_amount,:tax,:total_amount,:currency_type,:tenderer_name,:supplier_name
	validates_presence_of :reference,:control_number, :if => Proc.new { |incoming_invoice| incoming_invoice.associated_purchase_ledgers }
	#validates_uniqueness_of :material_purchase_order_id,:scope => [:account_payable_incoming_invoice_document_type_id]
  #validates_uniqueness_of :reference,:scope => [:tenderer_id], :if => Proc.new { |incoming_invoice| incoming_invoice.associated_purchase_ledgers }
	
	alias_attribute(:total, :total_amount)
	alias_method(:material_positions, :account_payable_incoming_invoice_positions)
	


	#
	# Retorna true si fueron agregados position al incoming_invoice
	#
	def has_added_item_positions?(incoming_invoice_positions_added)
		if incoming_invoice_positions_added.empty?
			 errors.add_to_base("debe seleccionar al menos un material")
			 return false
		end
		return true
	end



	#
  # Codigo de factura
  #
  def code
    "CEF-"+"%05d" % id
  end


	#
	# Nombre del beneficiario
	#
	def tenderer_name
		tenderer.name if tenderer
	end

	#
	# Nombre del proveedor
	#
	def supplier_name
		supplier.name if supplier
	end

	
#	#
#	# Expresa el total de las posiction - los pagos realizados
#	#
#	def balance
#		total_amount.to_f - amount_payments.to_f
#	end

	#
	# Total en pagos
	#
	def amount_payments
		account_payable_incoming_invoice_positions.map(&:total_amount).to_sum
	end

	#
	# Verific asi con el balace actual la cuenta por cobrar fue saldada
	#
	def verify_debit_account_is_finished
		if accounting_payable_account
			accounting_payable_account.update_attributes(:paid => total - balance,:balance => balance,:cashed => balance.zero?)
		end
	end

	#
	#
	#
	def set_value_balance
		update_attributes!(:balance => amount_total_to_paid)
	end

	#
	# Coneviret su valores  ahash
	#
	def to_hash
		{"reference"=>reference, "description"=>description, "reference_document_type"=>to_s, "amount"=>total, "control_number"=>control_number, "reference_document_id"=>id}
	end

	#
	# Nombre corto
	#
	def name
		"#{self.class.model_humanize_name} (#{id.to_code})"
	end

	#
	# Nombre completo
	#
	def fullname
		"(Número: #{id.to_code}) | F. creacion: #{created_at.to_date} | Nro Factura: #{reference} | Monto #{total_amount.to_currency}"
	end

	#
	# Nombre completo
	#
	def full_name
		"#{self.class.model_humanize_name} / #{code}"
	end


	#
	# Nombre completo
	#
	def id_fullname
		{:id => id,:fullname => "(Número: #{id.to_code}) | F. creacion: #{created_at.to_date} | Nro Factura: #{reference} | Monto #{total_amount.to_currency}"}
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
		!balance.zero?
	end


	#
	# Crear cuanta por pagar al crear la factura
	#
	def create_payable_account
				#Accounting::PayableAccount
					payable_account = Accounting::PayableAccount.new
					payable_account.doc = self
					payable_account.tenderer = tenderer
					payable_account.date_doc = invoice_date
					payable_account.date_doc_expiration = invoice_date
					payable_account.reference = reference
					payable_account.control_number = control_number
					payable_account.note = "#{self.class.model_humanize_name} ##{id.to_code}"
					payable_account.total = amount_total_to_paid
					payable_account.paid = 0
					payable_account.balance = amount_total_to_paid
					payable_account.cashed = false
					payable_account.valid?
					if payable_account.valid?
						payable_account.save
					end
		end

  #
	# Crear cuanta por pagar al crear la factura
	#
	def update_payable_account
        
				#Accounting::PayableAccount
					payable_account = self.accounting_payable_account
					payable_account.doc = self
					payable_account.tenderer = tenderer
					payable_account.date_doc = invoice_date
					payable_account.date_doc_expiration = invoice_date
					payable_account.reference = reference
					payable_account.control_number = control_number
					payable_account.note = "#{self.class.model_humanize_name} ##{id.to_code}"
					payable_account.total = amount_total_to_paid
					payable_account.paid = 0
					payable_account.balance = amount_total_to_paid
					payable_account.cashed = false
					payable_account.valid?
					if payable_account.valid?
						payable_account.save
					end
		end

	#
	#
	#
	def create_taxes
		taxes = {}
		account_payable_incoming_invoice_positions.each do |incoming_invoice_position|
			taxes[incoming_invoice_position.tax_id.to_s] = 0 if !taxes.has_key?(incoming_invoice_position.tax_id.to_s)
			taxes[incoming_invoice_position.tax_id.to_s] += incoming_invoice_position.taxable
		end
		taxes.each do |tax_id,taxable|
			tax_incoming_invoice = AccountPayable::IncomingInvoiceTax.new
			tax_incoming_invoice.account_payable_incoming_invoice = self
			tax_incoming_invoice.tax_id = tax_id.to_i
			tax_incoming_invoice.taxable = taxable
			tax_incoming_invoice.tax_amount = tax_incoming_invoice.tax.amount*taxable/100
			tax_incoming_invoice.total_amount = tax_incoming_invoice.tax_amount + tax_incoming_invoice.taxable
			if tax_incoming_invoice.valid?
				tax_incoming_invoice.save
			end
		end
	end

	#
	# Valida si hay algun material en la posiciones de la factura
	#
	def has_materials?
		!account_payable_incoming_invoice_positions.map(&:material_raw_material).compact.empty?
	end

	#
	# Crear un moviemiento de entrada de mercancia si aplica
	#
	def create_goods_movement
		#Material::GoodsMovement
		goods_movement = Material::GoodsMovement.new
		
		if has_materials?
			goods_movement.material_goods_movement_type = Material::GoodsMovementType.find_by_tag_name(Material::GoodsMovementType::IN_GOODS_MOVEMENT)
			goods_movement.material_goods_movement_reason = Material::GoodsMovementReason.find_by_tag_name(Material::GoodsMovementReason::BY_INCOMING_INVOICE)
			goods_movement.doc_id = id
			goods_movement.doc_type = self.class.to_s
			goods_movement.create_by = create_by
			goods_movement.supplier = supplier
			goods_movement.delivery_date = posting_date
			goods_movement.posting_date = Time.now.to_date
			if goods_movement.valid?
				goods_movement.save
				account_payable_incoming_invoice_positions.each do |position|
					goods_movement_position = Material::GoodsMovementPosition.new
					if position.material_raw_material
						goods_movement_position.material_goods_movement = goods_movement
						goods_movement_position.material_raw_material = position.material_raw_material
						goods_movement_position.quantity = position.quantity
						goods_movement_position.delivery_date = goods_movement.delivery_date
						goods_movement_position.material_raw_material.update_attributes(:previous_price => goods_movement_position.material_raw_material.moving_price,:moving_price => position.sub_total)
						if goods_movement_position.valid?
							goods_movement_position.save
						end
					end
				end
			end
		end
	end

	#
	# Crear un Orden movimiento de entrada de mercancia si aplica
	#
	def create_material_production_order
		#Material::ProductionOrder
		production_order = Material::ProductionOrder.new

		if has_materials?
			production_order.material_production_orden_type = Material::ProductionOrderType.find_by_tag_name(Material::ProductionOrderType::INCOMING_INVOICE)
			production_order.delivery_date = posting_date
      production_order.description = "#{self.class.model_humanize_name}: #{code}"
			production_order.requesting_unit = create_by
		
			if production_order.valid?
				production_order.save
				account_payable_incoming_invoice_positions.each do |position|
					production_order_position = Material::ProductionOrderPosition.new
					if position.material_raw_material
						production_order_position.material_production_order = production_order
						production_order_position.material_raw_material = position.material_raw_material
						production_order_position.quantity = position.quantity
						if production_order_position.valid?
							production_order_position.save
						end
					end
				end
			end
		end
	end

	#
	# sete a esttus registrado
	#
	def set_default_status_type
		add_status(AccountPayable::IncomingInvoiceStatusType.default,create_by)
	end

	#
	# vlaor del impuesto
	#
	def tax_amount
		tax*sub_total_amount/100
	end

	#
	# Estatus Acual
	#
	def actual_status
		account_payable_status_incoming_invoices.first(:conditions => {:actual => true}).account_payable_incoming_invoice_status_type
	end

	#
	# Puede ser anulada
	#
	def can_cancel?
		if actual_status.tag_name.eql?(AccountPayable::IncomingInvoiceStatusType::REGISTRADA)
			return true
		end

		if actual_status.tag_name.eql?(AccountPayable::IncomingInvoiceStatusType::ANULADA)
			errors.add(:base,"ya esta anulada")
		end
		if actual_status.tag_name.eql?(AccountPayable::IncomingInvoiceStatusType::PAGO_EMITIDO)
			errors.add(:base,"en proceso de pago")
		end
		if actual_status.tag_name.eql?(AccountPayable::IncomingInvoiceStatusType::PAGADA)
			errors.add(:base,"pago emitido")
		end
		(year,month,day) = posting_date.split("-")
		if year.to_i != Time.now.year and month.to_i != Time.now.month
			errors.add(:base,"se encuentra fuera del periodo de emisión")
		end
		false
	end

	def cancel(create_by)
		if can_cancel?
			add_status(AccountPayable::IncomingInvoiceStatusType.find_by_tag_name(AccountPayable::IncomingInvoiceStatusType::ANULADA),create_by)
			accounting_payable_account.update_attribute(:canceled, true) if accounting_payable_account
		#Material::GoodsMovement
		goods_movement = Material::GoodsMovement.new

		if has_materials?
			goods_movement.material_goods_movement_type = Material::GoodsMovementType.find_by_tag_name(Material::GoodsMovementType::OUT_GOODS_MOVEMENT)
			goods_movement.material_goods_movement_reason = Material::GoodsMovementReason.find_by_tag_name(Material::GoodsMovementReason::BY_INCOMING_INVOICE_CANCEL)
			goods_movement.doc_id = id
			goods_movement.doc_type = self.class.to_s
			goods_movement.create_by = create_by
			goods_movement.supplier = supplier
			goods_movement.delivery_date = posting_date
			goods_movement.posting_date = Time.now.to_date
			if goods_movement.valid?
				goods_movement.save
				account_payable_incoming_invoice_positions.each do |position|
					goods_movement_position = Material::GoodsMovementPosition.new
					if position.material_raw_material
						goods_movement_position.material_goods_movement = goods_movement
						goods_movement_position.material_raw_material = position.material_raw_material
						goods_movement_position.quantity = position.quantity
						goods_movement_position.delivery_date = goods_movement.delivery_date
						if goods_movement_position.valid?
							goods_movement_position.save
						end
					end
				end
			else
				logger.info "***********AccountPayable::IncomingInvoice.cancel************"
				p "***********AccountPayable::IncomingInvoice.cancel************"
				goods_movement.errors.each do |a,b|
					logger.info "\t#{a}: #{b}"
					p "\t#{a}: #{b}"
				end
				logger.info "*************************************************************"
				p "*************************************************************"
			end
		end

		end
	end

	#
	# Registro de emisionde pago
	#
	def payment_order_register(create_by)
		#doc.account_payable_incoming_invoice_status_types << AccountPayable::IncomingInvoiceStatusType::PAGO_EMITIDO
		add_status(AccountPayable::IncomingInvoiceStatusType.find_by_tag_name(AccountPayable::IncomingInvoiceStatusType::PAGO_EMITIDO),create_by)
	end

	#
	# Accion al definir un movimiento bancario
	#
	def bank_movement_register(create_by)
		add_status(AccountPayable::IncomingInvoiceStatusType.find_by_tag_name(AccountPayable::IncomingInvoiceStatusType::PAGADA),create_by)
		reload

	end

	#
	# Crea la transacion contable para el credito fiscal
	#
	def create_transaction_fiscal_movement_movement_accounting_concept
		if actual_status.tag_name.eql?(AccountPayable::IncomingInvoiceStatusType::PAGADA)
			#Accounting::TransactionMovementAccountingConcept
			transaction_movement_accounting_concept_fiscal_credit = Accounting::TransactionMovementAccountingConcept.new
			transaction_movement_accounting_concept_fiscal_credit.accounting_accountant_account = Accounting::BasicConfigAccountingConcept.find_by_tag_name("tax_accounting").accounting_accounting_concept.accounting_accountant_account
			transaction_movement_accounting_concept_fiscal_credit.create_by = create_by
			transaction_movement_accounting_concept_fiscal_credit.reference_document = self
			transaction_movement_accounting_concept_fiscal_credit.debit = tax_amount if !tax_amount.zero? and associated_purchase_ledgers
			transaction_movement_accounting_concept_fiscal_credit.date = posting_date
			if transaction_movement_accounting_concept_fiscal_credit.valid?
				transaction_movement_accounting_concept_fiscal_credit.save
			end
		end
	end


	#
	# Agregar status
	#
	def add_status(status_type,create_by)
				status = AccountPayable::StatusIncomingInvoice.new
				status.account_payable_incoming_invoice_status_type = status_type
				status.account_payable_incoming_invoice = self
				status.create_by = create_by
				status.save
	end

	#
	# Tiene orden de pago asociado
	#
	def has_payment_order?
		!account_payable_payment_orders.empty?
	end


	#
	# Monto total por tipo de tax
	#
	def total_amount_taxes_by_tax(tax)
			account_payable_incoming_invoice_taxes.sum(:total_amount,:conditions => {:tax_id => tax.id})
	end

	#
	# Monto base imponible por tipo de tax
	#
	def taxable_taxes_by_tax(tax)
			account_payable_incoming_invoice_taxes.sum(:taxable,:conditions => {:tax_id => tax.id})
	end

	#
	# Monto impuesto por tipo de tax
	#
	def tax_amount_taxes_by_tax(tax)
			account_payable_incoming_invoice_taxes.sum(:tax_amount,:conditions => {:tax_id => tax.id})
	end

	#
	# Nombre del modelo
	#
	def self.model_humanize_name
		"Entrada de Factura"
	end

	#
	# todas Por mes y año
	#
	def self.all_group_by_month_year(year=Time.now.year)
		group_by_month_year = {}
		Date::MONTHNAMES.each_index do |index|
			if index > 0
				condition_month_year = "#{year}-#{index.to_code("02")}"
				result = first(:select => "SUM(sub_total_amount) AS sub_total_amount,SUM(tax) AS tax,SUM(total_amount) AS total_amount",:conditions => ["purchase_ledger_period = ?","#{condition_month_year}"])
				group_by_month_year[condition_month_year] =  {:sub_total_amount => result.sub_total_amount.to_f,:tax => result.tax.to_f,:total_amount => result.total_amount.to_f}
			end
		end
		group_by_month_year.sort
	end

	#
	# todas Por mes y año
	#
	def self.all_by_month_year(month_year)
			records = all(:conditions => ["associated_purchase_ledgers = ? AND purchase_ledger_period = ? AND account_payable_status_incoming_invoices.actual = ? AND account_payable_incoming_invoice_status_types.tag_name NOT IN (?)",true,"#{month_year}",true,[AccountPayable::IncomingInvoiceStatusType::ANULADA]],:order => "invoice_date ASC",:include => [:account_payable_status_incoming_invoices => [:account_payable_incoming_invoice_status_type]])
			taxes = records.map(&:account_payable_incoming_invoice_taxes).flatten.map(&:tax).uniq
			{:records => records,:taxes => taxes,:with_exempts => taxes.map(&:exempt).uniq.include?(true)}
	end



	#
	# Busca todos las facturas pendeinte spor pagar
	#
	def self.all_payables
		all#(:conditions => {:status => PAYABLE})
	end

	#
	# Proceso masivo de actualziacion de inventario
	#
	def self.update_massive_inventory
		all.each do |item|
				item.create_goods_movement
		end
	end
end
