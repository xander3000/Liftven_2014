class Accounting::RetentionAccountingType < ActiveRecord::Base
	def self.table_name_prefix
    'accounting_'
  end
		humanize_attributes		:retention_percentage => "% retención",
													:reduction_tax_base => "Reducción de la base imponible",
													:reduction_taxable_lessened => "Reducción aminorada de la base imponible",
													:name => "Denominación"


	belongs_to :accounting_accountant_account,:class_name => "Accounting::AccountantAccount"


end
