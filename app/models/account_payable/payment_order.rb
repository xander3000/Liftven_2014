class AccountPayable::PaymentOrder < ActiveRecord::Base
	def self.table_name_prefix
    'account_payable_'
  end

  attr_accessor :tenderer_name,
								:doc_type_demodulize,
								:doc_fullname,
								:external_doc_id,
								:external_doc_type

  	humanize_attributes	:accounting_accounting_concept => "Concepto",
												#:account_payable_payment_order_type => "Tipo de orden de pago",
												:cash_bank_bank => "Banco",
												:cash_bank_bank_account => "Cuenta Bancaria",
												:accounting_accountant_account => "Cta. Contable",
												:cash_bank_involvement_type => "Tipo de Afectación",
												#:cash_bank_checkbook => "Chequera",
												:doc => "Documento referenciado",
												:doc_id => "Documento referenciado",
												:doc_type => "Tipo de Documento referenciado",
												:tenderer => "Proveedor/Beneficiario",
                        :tenderer_id => "Proveedor/Beneficiario",
                        :tenderer_type => "Proveedor/Beneficiario",
                        :tenderer_name => "Proveedor/Beneficiario",
												:description => "Descripción",
												:amount => "Monto",
												#:control_number => "Numero de control",
												:amount_withheld_committed => "Monto sujeto a retención",
												:amount_withheld => "Monto retenido",
												:posting_date => "Fecha",
												:base => "Ordenes de pago",
												:id => "Documento",
												:account_balance_to_date => "Balance a la fecha",
                        #:cash_bank_bank_movement_operation_type => "Forma de pago",
                        :account_payable_payment_order_document_type => "Tipo de documento"
												#:bank_movement_date => "Fecha del movimiento"

  has_many :accounting_retention_accounting_types,:class_name => "Accounting::RetentionAccountingType"
	has_many :bank_movement_retention_positions,:class_name => "CashBank::BankMovementRetentionPosition"
	has_many :cash_bank_bank_movement_positions,:class_name => "CashBank::BankMovementMovementPosition"

  belongs_to :account_payable_payment_order_document_type,:class_name => "AccountPayable::PaymentOrderDocumentType"
	belongs_to :accounting_accounting_concept,:class_name => "Accounting::AccountingConcept"
	
	#belongs_to :account_payable_payment_order_type,:class_name => "AccountPayable::PaymentOrderType"
	belongs_to :cash_bank_bank,:class_name => "CashBank::Bank"
	belongs_to :cash_bank_bank_account,:class_name => "CashBank::BankAccount"
	belongs_to :accounting_accountant_account,:class_name => "Accounting::AccountantAccount"
	belongs_to :cash_bank_involvement_type,:class_name => "CashBank::InvolvementType"
  belongs_to :tenderer,:polymorphic => true
	belongs_to :doc,:polymorphic => true
	
	belongs_to :create_by,:class_name => "User"


	#belongs_to :cash_bank_checkbook, :class_name => "CashBank::Checkbook"
	#belongs_to :cash_bank_bank_movement_operation_type,:class_name => "CashBank::BankMovementOperationType"#,:conditions => {:visible => true}

	validates_presence_of :accounting_accounting_concept,
												#:account_payable_payment_order_type,
												:cash_bank_bank,
												:cash_bank_bank_account,
												:accounting_accountant_account,
												:cash_bank_involvement_type,
												:tenderer_name,
												:description,
												:amount,
												:amount_withheld_committed,
												:amount_withheld,
												:posting_date
	validates_presence_of :tenderer
	validates_uniqueness_of :doc_id,:scope => [:doc_type]

	after_create :payment_order_register#,:create_bank_movement

	def doc_fullname
		doc.fullname
	end

	#
	# nombre del proveedor/Beneficiario
	#
	def tenderer_name
		self.tenderer.name if self.tenderer
	end


	#
	# Asociar emsiond epago al doc
	#
	def payment_order_register
		if doc
			doc.payment_order_register(create_by)
		end
	end


	#
	# Crea un movimiento bancario a partir de una orden de pago ejecutada
	#
	def create_bank_movement
		
		bank_movement = CashBank::BankMovement.new
		bank_movement.create_by = create_by
		bank_movement.cash_bank_bank_movement_operation_type = cash_bank_bank_movement_operation_type
		bank_movement.accounting_accounting_concept = accounting_accounting_concept
		bank_movement.cash_bank_bank = cash_bank_bank
		bank_movement.cash_bank_bank_account = cash_bank_bank_account
		bank_movement.accounting_accountant_account = accounting_accountant_account
		bank_movement.account_balance_to_date = cash_bank_bank_account.current_balance
		bank_movement.cash_bank_involvement_type = cash_bank_involvement_type
		bank_movement.description = description
		bank_movement.reference_document = doc
		bank_movement.vale = control_number
		bank_movement.date = bank_movement_date
		bank_movement.amount = amount
		bank_movement.amount_withheld_committed = amount_withheld_committed
		bank_movement.amount_withheld = amount_withheld
		bank_movement.cash_bank_checkbook = cash_bank_checkbook
		bank_movement.beneficiary = tenderer
		if bank_movement.valid?
			bank_movement.save
		end
	end

end
