class Client < ActiveRecord::Base

  humanize_attributes :client_type => "Tipo de cliente",
                      :price_list => "Lista de precio",
                      :client_discount_type => "Descuento",
                      :client_reputation_type => "Reputación",
                      :bank => "Entidad bancaria",
											:bank_account_number => "Número de cuenta",
											:bank_account_name => "Titular de cuenta",
											:is_national => "¿Es un acreedor nacional?",
											:is_retention_agent => "¿Es un agente de retección?",
											:is_taxpayer => "¿Es contribuyente IVA?",
											:rate_retention => "Tasa de retención"

  has_one  :contact_category,:as => :category
  belongs_to :client_type
  belongs_to :price_list
  belongs_to :client_discount_type
  belongs_to :client_reputation_type
  has_many :invoices
	has_many :budgets
	has_many :budgets_active,:conditions => ["(balance) > 0"],:class_name => "Budget"
  has_many :credit_notes
  has_many :orders
  has_many :invoiced_orders,:class_name => "Order",:conditions => ["tracking_states.state_id IN (?)",[State.find_by_name(State::FACTURACION)]],:include => [:doc => [:case => :tracking_states]]
  has_many :crm_projects,:class_name => "Crm::Project"
	has_many :accounting_advances,:class_name => "Accounting::Advance"
  has_many :accounting_receivable_accounts,:class_name => "Accounting::ReceivableAccount"
	has_many :accounting_paid_receivable_accounts,:class_name => "Accounting::ReceivableAccount",:conditions => ["balance > 0"]

  before_create :set_default_values

  #
  #Define los valores o atributos por defectos si estos no son definidos al momento de crearlos
  #
  def set_default_values
    if price_list.nil?
      self.price_list = PriceList.find_default
    end
  end

  #
  # Facturas activas para el cliente especifico
  #

  def active_invoices
    Invoice.all_actives_by_client(self.id)
  end
  
  

  #
  # Retorna la informacion de contacto del cliente
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
  # Retorna el telefono del cliente
  #
  def phone
    contact.phone
  end

  #
  # Retorna la direccion del cliente
  #
  def address
    contact.address
  end

  #
  # Retorna el correo del cliente
  #
  def email
    contact.email
  end



end
