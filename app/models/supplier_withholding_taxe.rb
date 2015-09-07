class SupplierWithholdingTaxe < ActiveRecord::Base

	attr_accessor :id_temporal

	humanize_attributes :supplier => "Acreedor",
											:accounting_withholding_taxe_type => "Tipo de retención",
											:min_amount => "Monto mínimo de retención",
                      :subtrahend => "Sustraendo"

	belongs_to :accounting_withholding_taxe_type,:class_name => "Accounting::WithholdingTaxeType"
	belongs_to :supplier

	validates_presence_of :accounting_withholding_taxe_type,:min_amount
	validates_numericality_of :min_amount
	
end
