class AccountPayable::PaymentSchedule < ActiveRecord::Base
	def self.table_name_prefix
    'account_payable_'
  end

	attr_accessor :tenderer_name

	humanize_attributes		:cash_bank_bank => "Banco",
												:cash_bank_bank_account => "Cuenta Bancaria",
												:account_payable_incoming_invoice => "Documento / Factura",
												:account_payable_incoming_invoice_id => "Documento / Factura",
												:tenderer => "Proveedor/Beneficiario",
												:tenderer_name => "Proveedor/Beneficiario",
												:tenderer_type => "Tipo de Relación",
												:tenderer_id => "Tipo de Relación",
												:currency_type => "Moneda",
												:account_payable_payment_frequency => "Frecuencia de Pago",
												:create_by => "Creado por",
												:share => "Nº Cuotas",
												:total_amount => "Total pago",
												:balance_amount => "Balance",
												:init_date => "Fecha inicio",
												:end_date => "Fecha fin",
												:description => "Descripción",
												:paid => "¿Pago efectuado?"


	

  has_many	 :account_payable_payment_schedule_positions,:class_name => "AccountPayable::PaymentSchedulePosition"
	belongs_to :cash_bank_bank,:class_name => "CashBank::Bank"
	belongs_to :cash_bank_bank_account,:class_name => "CashBank::BankAccount"
	belongs_to :account_payable_incoming_invoice,:class_name => "AccountPayable::IncomingInvoice"
	belongs_to :tenderer,:polymorphic => true
	belongs_to :currency_type
	belongs_to :account_payable_payment_frequency,:class_name => "AccountPayable::PaymentFrequency"
	belongs_to :create_by,:class_name => "User"

	validates_presence_of :cash_bank_bank,
												:cash_bank_bank_account,
												:account_payable_payment_frequency,
												:account_payable_incoming_invoice,
												:tenderer,
												:tenderer_type,
												:tenderer_id,
												:tenderer_name,
												:currency_type,
												:share,
												:total_amount,
												:balance_amount,
												:init_date,
												:end_date,
												:create_by



	#
	# Define el plan de pagos
	#
	def payment_plan
		payment_schedule_positions = []
		date = init_date.to_date
		#date = Date.new(date[2].to_i,date[1].to_i,date[0].to_i)
		for number_share in eval("1..#{share}")
			payment_schedule_position = AccountPayable::PaymentSchedulePosition.new
			payment_schedule_position.number = number_share
			payment_schedule_position.expiration_date = date.to_s.split("-").reverse.join("/")
			payment_schedule_position.amount = total_amount/share
			payment_schedule_positions << payment_schedule_position
			date += account_payable_payment_frequency.factor.days
		end
		payment_schedule_positions
	end

end
