class ContactType < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  #
  # Contato dek tipo Cliente
  #
  def self.cliente
    first(:conditions => {:class_name => Client.to_s})
  end

  #
  # Contato dek tipo Acreedor
  #
  def self.supplier
    first(:conditions => {:class_name => Supplier.to_s})
  end
  
  #
  # Contato dek tipo Empleado
  #
  def self.employee
    first(:conditions => {:class_name => Employee.to_s})
  end

  #
  # Contato dek tipo Empleado
  #
  def self.user
    first(:conditions => {:class_name => User.to_s})
  end

  #
  # Contato dek tipo Empleado
  #
  def self.executive
    first(:conditions => {:class_name => Crm::Projects::Executive.to_s})
  end

end
