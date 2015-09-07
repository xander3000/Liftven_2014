class CashBank::BankMovementOperationType < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	CHEQUE = "cheque"
	RETIRO = "retiro"
	DEPOSITO = "deposito"
	DEBITO_REVERSO = "debito_reverso"
	CREDITO_REVERSO = "credito_reverso"
	POS_DEBITO_CREDITO = "pos_debito_credito"

	named_scope :all_visibles, :conditions => {:visible => true}
  named_scope :all_visibles_debit, :conditions => {:visible => true,:is_debit => true}
  named_scope :all_visibles_credit, :conditions => {:visible => true,:is_debit => false,:is_revert => false}

	#
	# Conceptos asociados
	#
	def associated_concepts
		ledger_type = Accounting::LedgerType.first_per_bank
		Accounting::AccountingConcept.all(:conditions => ["accounting_accounting_concept_operation_types.accounting_ledger_type_id = ? AND accounting_accounting_concept_operation_types.is_debit = ?",ledger_type.id,is_debit],:joins => [:accounting_accounting_concept_operation_type ])
	end

	#
	# Tipo de afectacion segun debit
	#
	def associated_involvement_types
		CashBank::InvolvementType.all(:conditions => ["is_debit = ?",is_debit])
	end

#
	# Tipo de afectacion con compromiso segun debit
	#
	def associated_involvement_types_with_reference_document
		CashBank::InvolvementType.all(:conditions => ["is_debit = ? AND require_reference_document = ?",is_debit,true])
	end

	#
	# Verifica si requiere uso de cueque
	#
	def require_check?
		["cheque"].include?(tag_name.downcase)
	end

	#
	# OPeraciones no incurridas en errores para banco al momento de la conciliacion desde libro banco
	#
	def self.allowed_movement_operations_on_reconciliation_at_bank_from_book
		[CHEQUE]
	end

	#
	# Operaciones de generacion automatica por ventas POS CON TDC y TDD
	#
	def self.by_pos_debit_credit
		first(:conditions => ["tag_name = ?",POS_DEBITO_CREDITO])
	end

end
