class Supplier < ActiveRecord::Base

  humanize_attributes :supplier_type => "Tipo de acreedor",
											:person_name_contact => "Persona de contacto",
                      :person_phone_contact => "Telf. persona de contacto",
											:bank => "Entidad bancaria",
											:bank_account_number => "Número de cuenta",
											:bank_account_name => "Titular de cuenta",
											:is_national => "¿Es un acreedor nacional?",
											:is_retention_agent => "¿Es un agente de retección?",
											:is_taxpayer => "¿Es contribuyente IVA?",
											:rate_retention => "Tasa de retención"


	validates_presence_of :supplier_type
	
  before_validation :set_default_supplier_type

  has_one  :contact_category,:as => :category
  has_many :inventories
  has_many :account_payable_incoming_invoices,:class_name => "AccountPayable::IncomingInvoice",:foreign_key => "tenderer_id",:conditions => ["tenderer_type = ?","Supplier"]
	has_many :account_payable_payable_incoming_invoices,:class_name => "AccountPayable::IncomingInvoice",:foreign_key => "tenderer_id",:conditions => ["tenderer_type = ? AND balance > ?","Supplier",0]
	has_many :material_quotation_requisition_position_positions_tendered,:class_name => "Material::QuotationRequisitionPosition",:foreign_key => "selected_supplier_id",:conditions => ["material_quotation_requisition_position_status_types.tag_name = ?",Material::QuotationRequisitionPositionStatusType::TENDERED],:include => [:material_quotation_requisition_position_status_type]
	has_many :accounting_payable_accounts, :class_name => "Accounting::PayableAccount",:as => :tenderer,:conditions => {:cashed => false}
	has_many :supplier_withholding_taxes,:class_name => "SupplierWithholdingTaxe"
	has_many :account_payable_supplier_credit_notes,:class_name => "AccountPayable::SupplierCreditNote"
	belongs_to :supplier_type
  

  #
  # Retorna la informacion de contacto del proveedor
  #
  def contact
    contact_category.contact
  end

  #
  # Retorna el nombre del cliente
  #
  def name
    contact.name
  end

  #
  # Retorna el documento de identidad del cliente
  #
  def identification_document
    contact.identification_document
  end

   #
   #
   #
   def set_default_supplier_type
     if supplier_type.nil?
       self.supplier_type = SupplierType.find_by_tag_name(SupplierType::PROVEEDOR)
     end
   end

	 #
	 # Busca el Suppleir Dueño
	 #
	 def self.find_owner
		 first(:conditions => {:owner => true})
	 end

   #
   # Setera el valor de is_natural cuando aplique
   #
   def set_value_is_natural
       update_attribute(:is_natural,AppConfig::identification_personal_type.include?(identification_document.first.upcase))
   end
end
