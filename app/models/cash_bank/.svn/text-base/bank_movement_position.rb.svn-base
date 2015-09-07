class CashBank::BankMovementPosition < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	attr_accessor :reference_document_type_name,:id_temporal,:beneficiary_name
	
	humanize_attributes		:reference_document_id => "Documento referenciado",
												:reference_document_type => "Tipo de Documento referenciado",
												:control_number => "Número de control",
												:reference => "Referencia",
												:description => "Descripcion",
												:amount => "Monto",
                        :cash_bank_involvement_type => "Tipo de Afectación",
												:beneficiary => "Proveedor/Beneficiario",
												:beneficiary_name => "Proveedor/Beneficiario"

	belongs_to :bank_movement,:class_name => "CashBank::BankMovement",:foreign_key => "cash_bank_bank_movement_id"
  belongs_to :cash_bank_involvement_type,:class_name => "CashBank::InvolvementType"
  belongs_to :beneficiary,:class_name => "Supplier"
	belongs_to :reference_document,:polymorphic => true
	
													
	validates_presence_of :amount,	:beneficiary,:cash_bank_involvement_type
	validate :reached_maximum_amount, :on => :create
	validate	:reference_document_is_payable, :on => :create
	validate  :reference_document_has_payment_order, :on => :create

	after_create :set_balance_from_reference_document
#	after_create :create_transaction_movement_accounting_concept




	#
	# Nombre del beneficiario
	#
	def beneficiary_name
		beneficiary.name if beneficiary
	end


	#
	# Valida si el amonto actual mas los pagos antyeriores no alncanzal en monto de la factura
	#
	def reached_maximum_amount
		if reference_document_type and reference_document_id
			reference_document = eval(reference_document_type).find_by_id(reference_document_id)
			if reference_document and amount.round(2) > reference_document.total.to_f.round(2)
				errors.add(:amount,"excede el total del documento")
			end
		end
	end

	#
	# Verifica si el documento referenciadoes pagable
	#
	def reference_document_is_payable
		if new_record? and reference_document and !reference_document.is_payable?
			errors.add(:reference_document,"ya está contabilizado")
			return false
		end
	end

	#
	# Verifica si el docuemnto refernciado tiene orden de pago
	#
	def reference_document_has_payment_order
		if new_record? and reference_document and !reference_document.has_payment_order? #and cash_bank_bank_movement_operation_type.is_debit
			errors.add(:reference_document,"no posee orden de pago asociada")
			return false
		end
	end

	#
	# Modifica el balance del documento referenciado
	#
	def set_balance_from_reference_document
		if reference_document
			current_balance = reference_document.balance
			reference_document.update_attributes(:balance => current_balance-amount)
			reference_document.verify_debit_account_is_finished
			reference_document.bank_movement_register(bank_movement.create_by)
		end
	end

  #
  # Registra transqaccion contable
  #
  def create_transaction_movement_accounting_concept

		transaction_movement_accounting_concept_concept = Accounting::TransactionMovementAccountingConcept.new
		transaction_movement_accounting_concept_concept.accounting_accountant_account = accounting_accounting_concept.accounting_accountant_account
		transaction_movement_accounting_concept_concept.create_by = create_by
		transaction_movement_accounting_concept_concept.reference_document = reference_document
		if cash_bank_bank_movement_operation_type.is_debit
			transaction_movement_accounting_concept_concept.debit = amount
		else
			transaction_movement_accounting_concept_concept.credit = amount
		end
		transaction_movement_accounting_concept_concept.date = date
		if transaction_movement_accounting_concept_concept.valid?
			transaction_movement_accounting_concept_concept.save
		end
  end

end
