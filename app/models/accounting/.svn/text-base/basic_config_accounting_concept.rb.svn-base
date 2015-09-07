class Accounting::BasicConfigAccountingConcept < ActiveRecord::Base
	def self.table_name_prefix
    'accounting_'
  end

  humanize_attributes		:accounting_accounting_concept => "Concepto por Cuenta contable",
                        :name => "Nombre/Descripción"
  
  
  belongs_to :accounting_accounting_concept,:class_name => "Accounting::AccountingConcept"

  
end
