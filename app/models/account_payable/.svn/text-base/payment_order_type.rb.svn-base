class AccountPayable::PaymentOrderType < ActiveRecord::Base
  def self.table_name_prefix
    'account_payable_'
  end



  PAGO_PROVEEDORES = "pago_proveedores"
  PAGO_ORGANISMOS = "pago_organismos"
  FONDO_AVANCE = "fondo_avance"

	named_scope :all_by_tag_name, lambda { |tag_name|  { :conditions => { :tag_name => tag_name } }    }

	#
	#
	#
	def associated_involvement_types
		CashBank::InvolvementType.all(:conditions => ["is_debit = ?",true])
	end

	#
	#
	#
	def associated_involvement_types_with_reference_document
		CashBank::InvolvementType.all(:conditions => ["is_debit = ? AND require_reference_document = ?",true,true])
	end


end
