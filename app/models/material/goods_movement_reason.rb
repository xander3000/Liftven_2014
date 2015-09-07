class Material::GoodsMovementReason < ActiveRecord::Base
	def self.table_name_prefix
    'material_'
  end
		BY_CREDIT_NOTE_ENTRY = "Material::CreditNoteEntry"
		BY_PRODUCTION_ORDER = "Material::ProductionOrder"
		BY_INCOMING_INVOICE = "AccountPayable::IncomingInvoice"
		BY_INCOMING_INVOICE_CANCEL = "IncomingInvoiceCancel"
end

