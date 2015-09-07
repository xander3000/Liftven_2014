  class CustomerDetail < ActiveRecord::Base

  humanize_attributes :customer_client_requirement_type => "Requerimiento",
                      :customer_client_elevator_type => "Tipo de elevador",
											:contact_name => "Nombre",
                      :business_name => "Razón social",
                      :phone => "Telefono",
                      :email => "Correo electronico",
                      :address => "Dirección",
                      :time_check => "Hora de visita"


  belongs_to :customer_client_elevator_type
  belongs_to :customer_client_requirement_type

    validates_presence_of :contact_name,:business_name,:phone,:email,:address,:time_check,:customer_client_elevator_type,:customer_client_requirement_type

end
