class Crm::Projects::Executive < ActiveRecord::Base
  def self.table_name_prefix
    'crm_projects_'
  end

has_one  :contact_category,:as => :category

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
