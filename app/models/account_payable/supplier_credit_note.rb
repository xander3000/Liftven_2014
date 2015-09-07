class AccountPayable::SupplierCreditNote < ActiveRecord::Base
	  def self.table_name_prefix
    'account_payable_'
  end

		humanize_attributes	:supplier => "Acreedor",
												:create_by => "Creado por",
												:date => "Fecha",
												:posting_date => "Fecha registro",
												:sub_total_amount => "Sub total",
												:tax => "% impuesto",
												:tax_amount => "Impuesto",
												:total_amount => "Total",
												:balance => "Balance disponible",
												:description => "Descripción",
												:reference => "Referencia",
												:control_number => "Número de control"


		belongs_to :supplier
		belongs_to :create_by,:class_name => "User"

		validates_presence_of :supplier,:create_by,:posting_date,:reference,:date,:sub_total_amount,:tax_amount,:total_amount
		validates_uniqueness_of :reference,:scope => [:supplier_id]
end
