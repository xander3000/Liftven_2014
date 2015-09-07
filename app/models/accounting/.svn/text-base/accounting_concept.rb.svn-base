class Accounting::AccountingConcept < ActiveRecord::Base
		def self.table_name_prefix
    'accounting_'
		end
		
		attr_accessor :accounting_accountant_account_name

		humanize_attributes		:base => "Concepto por Cuenta contable",
													:accounting_accountant_account_name => "Cuenta contable",
													:accounting_accountant_account => "Cuenta contable",
													:accounting_accounting_concept_operation_type => "Tipo de concepto",
													:name => "Nombre"

		belongs_to :accounting_accounting_concept_operation_type,:class_name => "Accounting::AccountingConceptOperationType"
		belongs_to :accounting_accountant_account,:class_name => "Accounting::AccountantAccount"
    has_one :cash_bank_cash_journal_to_create,:class_name => "CashBank::CashJournal",:foreign_key => "accounting_concept_create_id",:conditions => ["closed = ?",false]
		has_one :cash_bank_cash_journal_to_rehearing,:class_name => "CashBank::CashJournal",:foreign_key => "accounting_concept_rehearing_id",:conditions => ["closed = ?",false]

		validates_presence_of :accounting_accounting_concept_operation_type,:accounting_accountant_account,:name
		
		named_scope :all_per_bank_debit, lambda { |tag_name|  { :conditions => ["accounting_accounting_concept_operation_types.accounting_ledger_type_id = ? AND accounting_accounting_concept_operation_types.is_debit = ?",Accounting::LedgerType.first_per_bank.id,true],:joins => [:accounting_accounting_concept_operation_type ]  }}

		#
		# Si usa chuequera
		#
		def accountant_account_used_checkbook?(add_error=true)
			if accounting_accountant_account.cash_bank_bank_account.nil?
				errors.add(:base, "no tiene asociado una cuenta bancaria")
				return false
			end
			
			if not accounting_accountant_account.cash_bank_bank_account.used_checkbook
				if add_error
					errors.add(:base, "Esta asociado a una cuenta bancaria sin chequera")
				end
				return false
			else
				return true
			end
		end

		#
		# OPeracion de egreso de banco 
		#
		def self.all_mbe
			all(:conditions => ["accounting_accounting_concept_operation_types.tag_name = ?",Accounting::AccountingConceptOperationType::MBE],:joins => :accounting_accounting_concept_operation_type)
		end

		#
		# Tipo de afectacion con compromiso segun debit
		#
		def associated_involvement_types_with_reference_document
			CashBank::InvolvementType.all(:conditions => ["is_debit = ? AND require_reference_document = ?",accounting_accounting_concept_operation_type.is_debit,true])
		end

		#
		#
		#
		def associated_involvement_types
			CashBank::InvolvementType.all(:conditions => ["is_debit = ?",true])
		end

end
