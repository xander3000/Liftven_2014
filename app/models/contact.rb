class Contact < ActiveRecord::Base
  LETTERS = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]

  humanize_attributes :fullname => "Nombre Completo",
                      :identification_document => "Doc. Identificación",
                    	:phone => "Teléfono",
											:salulation => "Saludos",
                      :email => "Correo electrónico",
                      :website => "Pagina Web",
                      :address => "Dirección",
                      :contact_types => "Tipo de contacto",
                      :cellphone => "Teléfono celular",
											:islr_retained => "¿Retiene ISLR?",
											:retention_rate_islr	=> "Porcentaje de retención sobre impuesto",
											:retention_rate_islr_2	=> "Porcentaje de retención sobre la base",
											:active => "¿Activo?",
											:id => "Contacto"


  attr_accessor :contact_types,:validate_presence_of_email
#  ,
#                :position,
#                :in_case_of_emergency_notify,
#                :emergency_phone,
#                :position,
#                :salary
  
#  has_one :user
  belongs_to :identification_document_type
	belongs_to :salulation
  has_many :contact_categories, :dependent => :destroy
  #has_many :type_contacts#,:through => :contact_categories
  #has_many :contact_types,:through => :contact_categories

  validates_presence_of :fullname,:phone,:identification_document#,:identification_document_type
  validates_uniqueness_of :identification_document
	validates_presence_of :email,:if => Proc.new { |contact| contact.validate_presence_of_email }
	validates_numericality_of :retention_rate_islr,:retention_rate_islr_2,:greater_than => 0,:if => Proc.new { |contact| contact.islr_retained }
	validate :select_contact_types

  after_create :create_contact_categories,:set_value_identification_document_type
	before_validation	:delete_dash_to_identification_document

  alias_method(:categories, :contact_categories)
  alias_attribute(:rif, :identification_document)
  alias_attribute(:name, :fullname)


  #
  # Tipo de contactos asociados
  #
  def contact_types
    values = categories.map(&:contact_type_id)
    values.empty? ? @contact_types : values
  end

	#
  # Tipo de contactos asociados
  #
  def first_name
    name.split(" ").first
  end


  # Verifica si tiene un usuario asociado
  #
  def has_user?
    !user.nil?
  end

  #
  # Devuelve el cliente asociado al contacto
  #
  def client
    result = contact_categories.first(:conditions => {:category_type => Client.to_s})
    result ? result.category : nil
  end

  #
  # Devuelve true si el contact es un client
  #
  def is_client?
    client ? true : false
  end

  #
  # Devuelve true si el contact es un natural
  #
  def is_natural?
    identification_document_type.is_natural
  end

  #
  # Devuelve el empleado asociado al contacto
  #
  def employee
    result = contact_categories.first(:conditions => {:category_type => Employee.to_s})
    result ? result.category : nil
  end

  #
  # Devuelve true si el contact es un employee
  #
  def is_employee?
    employee ? true : false
  end


  #
  # Devuelve el proveedor asociado al contacto
  #
  def supplier
    result = contact_categories.first(:conditions => {:category_type => Supplier.to_s})
    result ? result.category : nil
  end

	#
  # Devuelve true si el contact es un supplier
  #
  def is_supplier?
    supplier ? true : false
  end

  #
  # Devuelve el proveedor asociado al contacto
  #
  def user
    result = contact_categories.first(:conditions => {:category_type => User.to_s})
    result ? result.category : nil
  end


  #
  # Devuelve true si el contact es un user
  #
  def is_user?
    user ? true : false
  end

  #
  # Devuelve true si el contact es un supplier
  #
  def is_executive?
    executive ? true : false
  end

  #
  # Devuelve el proveedor asociado al contacto
  #
  def executive
    result = contact_categories.first(:conditions => {:category_type => Crm::Projects::Executive.to_s})
    result ? result.category : nil
  end

	#
	# Devuelve true si el contacto por document_identification existe
	#
	def exist?
		!self.class.first(:conditions => {:identification_document => identification_document}).nil?
	end

  #
  # asocia a el nuevo contacto como cliente
  #
  def associated_with_client
    self.contact_types = [ContactType.cliente.id]
  end

  #
  # asocia a el nuevo contacto como cliente
  #
  def associated_with_supplier
    self.contact_types = [ContactType.supplier.id]
  end

	#
  # asocia a el nuevo contacto como empeado
  #
  def associated_with_employee
    self.contact_types = [ContactType.employee.id]
  end

	#
  # asocia a el nuevo contacto como empeado
  #
  def associated_with_user
    self.contact_types = [ContactType.user.id]
  end

  #
  # asocia a el nuevo contacto como empeado
  #
  def associated_with_executive
    self.contact_types = [ContactType.employee.id]
  end

  #
  #Categorias de los contactos
  #
  def self.categories
    StaticContactCategory.find(:all, :select => 'id, contact_category, label')
  end

  #
  # Ordenes asociadas al client del contact
  #

  def orders
    return [] if !is_client?
    client.orders
  end

  #
  # Ordenes asociadas al client del contactcon etstaus facturado
  #

  def invoiced_orders
    return [] if !is_client?
    client.orders
  end

  #
  # Ordenes asociadas al employee del contact
  #

  def tracking_orders
    return [] if !is_employee?
    employee.orders
  end
  

  #
  #Crear Categoria a un contacto por tipo de contacto (Cliente, Proveedor, Empleados, etc)
  #
  def create_contact_categories
    contacts_types = self.contact_types
    contacts_types.delete("")
    contacts_types.each do |contact_type|
      contact_type = ContactType.find(contact_type)
			associante_and_create_contact_categories(contact_type)
    end
  end

	#
  #Crear Categoria a un contacto por tipo de contacto (Cliente, Proveedor, Empleados, etc)
  #
  def associante_and_create_contact_categories(contact_type,attributes={})
      category = eval(contact_type.class_name)
      category = category.new(attributes)
      if category.valid?
        category.save
        contact_category = ContactCategory.new
        contact_category.contact_id = id
        contact_category.category_id = category.id
        contact_category.category_type = category.class.to_s
        contact_category.contact_type_id = contact_type.id
        contact_category.save
      end
  end

	#
  #Asocia Categoria a un contacto por tipo de contacto (Cliente, Proveedor, Empleados, etc)
  #
  def associante_category_to_contact_categories(contact_type,category)
      contact_category = ContactCategory.new
      contact_category.contact_id = id
      contact_category.category_id = category.id
      contact_category.category_type = category.class.to_s
      contact_category.contact_type_id = contact_type.id
      contact_category.save
  end



  #
  # Crea una cuenta en el sistema
  #
  def create_account

  end

	#
	# Valida si selecciono una categoria
	#
	def select_contact_types
		if contact_types
			contact_types.delete("")
			if contact_types.empty?
				errors.add(:contact_types, "debe seleccionar uno")
				return false
			end
		end
			return true
	end

	#
	#
	#
	def delete_dash_to_identification_document
		 self.identification_document = self.identification_document.upcase
		 self.fullname = self.fullname.upcase
		 self.identification_document = self.identification_document.chop if self.identification_document.end_with?("-")
	end


  #
  #
  #
  def set_value_identification_document_type
    letter = self.identification_document.first
     identification_document_type_v = IdentificationDocumentType.find_by_short_name(letter)
     if identification_document_type_v
       self.update_attribute(:identification_document_type_id, identification_document_type_v.id)
     end
  end

  #
  #Busca tdoos los contactos por letra segun <m>self.LETTERS</m> odenados alfabeticamente
  #
  def self.all_by_letters(options={})
    contacts_by_leters = {}

    LETTERS.each do |letter|
      contacts = []
      clausules = []
      values = []
      conditions = []
			joins = []

      clausules << "lower(fullname) LIKE ? "
      values << "#{letter}%"

      if(options.has_key?(:filter_by_contact_type))
        clausules << "contact_categories.contact_type_id IN (?) "
        values << options[:filter_by_contact_type]
				joins << :contact_categories
				clausules << "active = ? "
				values << true
      end
      
      conditions << clausules.join(" AND ")
      conditions.concat( values )

      contacts = all(:conditions => conditions,:joins => joins,:order => "fullname ASC")
      contacts = contacts.uniq
      contacts_by_leters[letter.to_sym] = contacts
    end
    contacts_by_leters
  end
  
  #
  #Busca de acuerdo al parametro <b>attr</b>, cualquier contacto del tipo cliente con el valor <b>value<b/>
  #
  def self.find_by_client_autocomplete(attr,value)
		value = value.chop if value.end_with?("-")
    rows = []
    contacts = all(:conditions => ["lower(#{attr}) LIKE lower(?) AND contacts.active = ? AND contact_categories.category_type = ?","%#{value}%",true,Client.to_s],:include => :contact_categories,:limit => 10)
    contacts.each do |contact|
      rows << {
                "value" => contact[attr.to_sym],
                "label" => contact[:fullname],
                "id" => contact[:id],
                "client_id" => contact.client[:id],
                "fullname" => contact[:fullname],
                "phone" => contact[:phone],
                "identification_document" => contact[:identification_document],
                "address" => contact[:address],
                "email" => contact[:email],
								"islr_retained" => contact[:islr_retained],
								"retention_rate_islr" => contact[:retention_rate_islr],
								"retention_rate_islr_2" => contact[:retention_rate_islr_2],
                "code_response" => "ok"
              }
    end
    if contacts.empty?
      rows = [{
          "value" => value,
          "label" => "Cliente no Registrado",
          "code_response" => "no-found"
          }]
    end
    JSON.generate(rows)
  end

	#
  #Busca de acuerdo al parametro <b>attr</b>, cualquier contacto del tipo proveedror con el valor <b>value<b/>
  #
  def self.find_by_contact_autocomplete(attr,value)
    rows = []
    contacts = all(:conditions => ["lower(#{attr}) LIKE lower(?)","%#{value}%"],:limit => 10)
    contacts.each do |contact|
      rows << {
                "value" => contact[attr.to_sym],
                "label" => contact[:fullname],
                "id" => contact[:id],
                "fullname" => contact[:fullname],
                "phone" => contact[:phone],
                "identification_document" => contact[:identification_document],
                "address" => contact[:address],
                "email" => contact[:email],
                "code_response" => "ok"
              }
    end
    JSON.generate(rows)
  end

	#
  #Busca de acuerdo al parametro <b>attr</b>, cualquier contacto del tipo proveedror con el valor <b>value<b/>
  #
  def self.find_by_supplier_autocomplete(attr,value)
    rows = []
    contacts = all(:conditions => ["lower(#{attr}) LIKE lower(?) AND contacts.active = ? AND contact_categories.category_type = ?","%#{value}%",true,Supplier.to_s],:include => :contact_categories,:limit => 10)
    contacts.each do |contact|
      rows << {
                "value" => contact[attr.to_sym],
                "label" => contact[:fullname],
                "id" => contact[:id],
                "supplier_id" => contact.supplier[:id],
                "fullname" => contact[:fullname],
                "phone" => contact[:phone],
                "identification_document" => contact[:identification_document],
                "address" => contact[:address],
                "email" => contact[:email],
								"incoming_invoices" => contact.supplier.account_payable_payable_incoming_invoices.map(&:id_fullname),
                "code_response" => "ok"
              }
    end
    if contacts.empty?
      rows = [{
          "value" => value,
          "label" => "Proveedor no Registrado",
          "code_response" => "no-found"
          }]
    end
    JSON.generate(rows)
  end

	#
	# Busca usuaior masivo V-00000000
	#

	def self.masive_user
		find_by_identification_document("V-00000000")
	end

  def self.update_column_active
    all.each do |contact|
      contact.update_attribute(:active, true)
    end
  end
	
#
#  def self.identification_document
#    all.each do |contact|
#      identification_document = contact.identification_document
#        type = identification_document.first
#        raya = identification_document.subs
#      if identification_document.first.upcase == "1"
#        contact.update_attribute(:identification_document, "V-#{identification_document}")
#      else
#        contact.update_attribute(:identification_document, "#{identification_document.upcase}")
#      end
#
#    end
#    "DONE"
#  end
end
