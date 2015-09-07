class CashBank::BankMovementRetentionPosition < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end
	humanize_attributes		:amount_subject_retention => "Monto sujeto a retención",
													:amount_retained => "Monto retenido"

	belongs_to :bank_movement,:class_name => "CashBank::BankMovement",:foreign_key => "cash_bank_bank_movement_id"
	belongs_to :retention_accounting_type,:class_name => "Accounting::RetentionAccountingType",:foreign_key => "accounting_retention_accounting_type_id"

	after_create :set_amount_retained


	#
	# Calclar el monto etenido
	#
	def set_amount_retained
		update_attribute(:amount_retained, (retention_accounting_type.retention_percentage*amount_subject_retention/100))
	end

end
