class Crm::Account < ActiveRecord::Base
	def self.table_name_prefix
    'crm_'
  end
	 humanize_attributes :name => "Nombre",
												:website => "Sito Web",
												:crm_sector_account_type => "Sector",
												:crm_account_type => "Tipo de cuenta",
												:assigned_to => "Asignada a",
												:member_of => "Miembro de",
												:billing_address => "Domicilio de facturación",
												:shipping_address => "Domicilio de envio",
												:principal_email => "Correo principal",
												:alternative_email => "Correo alternativo",
												:fax => "Fax",
												:postal_code => "Código Postal",
                        :office_phone => "Telf. Oficina",
												:ticker_symbol => "Código de envio",
												:annual_revenue => "Ingresos anuales",
												:employees => "Nº Empleados",
												:ownership => "",
												:rating => "",
												:other_phone => "Otro numero",
												:description => "Descripción",
												:created_at => "Creado el"

	validates_presence_of :name,:crm_sector_account_type,:crm_account_type,:assigned_to,:principal_email

	belongs_to :crm_account_type,:class_name => "Crm::AccountType"
	belongs_to :crm_sector_account_type,:class_name => "Crm::SectorAccountType"
	belongs_to :assigned_to,:class_name => "User"
	belongs_to :member_of,:class_name => "User"



	#
	# Nombre del modelo
	#
	def self.model_humanize_name
		"Cuenta"
	end


	#
	# BUsca por el campo dado para un autocomplete
	#
	def self.find_for_autocomplete(attr,value)
    rows = []
    items = all(:conditions => ["lower(#{attr}) LIKE lower(?)","#{value}%"],:limit => 10,:order => "name asc")
    items.each do |item|
      rows << {
                "value" => item[attr.to_sym],
                "label" => item[:fullname],
                "id" => item[:id],
                "name" => item[:name],
                "code_response" => "ok"
              }
    end
    if items.empty?
      rows = [{
          "value" => value,
          "label" => "Cuenta no registrada",
          "code_response" => "no-found"
          }]
    end
    JSON.generate(rows)
	end

end
