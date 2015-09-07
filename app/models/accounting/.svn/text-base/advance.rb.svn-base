class Accounting::Advance < ActiveRecord::Base
	def self.table_name_prefix
    'accounting_'
  end
	humanize_attributes		:base => "Anticipo",
												:doc => "Documento",
												:client => "client",
												:user => "Usuario",
												:note => "Descripción",
												:amount => "Monto",
												:balance => "Balance",
												:date => "Fecha de compromiso"

	has_one :accounting_receivable_account,:as => :doc,:class_name => "Accounting::ReceivableAccount"
	belongs_to :user
	belongs_to :doc,:polymorphic => true
	belongs_to :client

	validates_presence_of :doc,:client,:user,:amount,:date
	validates_numericality_of :amount,:greater_than => 0,:on => :create
	#validate :less_than_or_equal_to_balance

	after_create :set_balance_to_doc,:create_receivable_account

	alias_attribute :total, :amount


	#
	# Codigo
	#
	def code
		"AN-"+"%05d" % id
	end
	
	#
	# Nombre corto
	#
	def name
		"#{self.class.human_attribute_name("base")} #{id.to_code}"
	end

	#
	# Nombre completo con doc
	#
	def full_name
		"<b>#{name}</b> de #{doc.name}"
	end

	#
	# Valida si el monto es meno o igual al balance actual
	#
	def less_than_or_equal_to_balance
		if amount > balance
			errors.add(:amount, "debe ser menor o igual al balance actual")
			return false
		end
		return true
	end

	#
	# Stea el balance del doc
	#
	def set_balance_to_doc
		doc.update_attribute(:balance, (doc.balance - amount))
	end


	#
	# Crear cuanta por cobrar si el balance es > 0
	#
	def create_receivable_account
				#Accounting::ReceivableAccount
				if balance > 0
					receivable_account = Accounting::ReceivableAccount.new
					receivable_account.doc = self
					receivable_account.client = client
					#receivable_account.payment_method_type = payment_method_type
					receivable_account.date_doc = created_at.to_date.to_s
					receivable_account.date_doc_expiration = date.to_date.to_s
					receivable_account.note = "#{self.class.human_attribute_name("base")} #{id.to_code}: #{note}"
					receivable_account.sub_total = doc.sub_total
					receivable_account.tax = doc.tax
					receivable_account.total = doc.total
					receivable_account.paid = amount
					receivable_account.balance = balance
					receivable_account.cashed = false
					receivable_account.valid?
					if receivable_account.valid?
						receivable_account.save
					end
				end
	end

  #
	# Verifica si el anticipo es posible de cobrar
	#
	def is_payable?
		!doc.balance.zero?
	end

	#
	# Verific asi con el balace actual la cuenta por cobrar fue saldada
	#
	def verify_debit_account_is_finished
		if accounting_receivable_account
			accounting_receivable_account.update_attributes(:balance => balance, :cashed => balance.zero?)
		end
	end

#
	# Accion al definir un movimiento bancario
	#
	def bank_movement_register

	end


	#
	# Nombre del modelo
	#
	def self.model_humanize_name
		"Anticipo de cliente"
	end

end
