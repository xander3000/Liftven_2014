class Crm::Quote < ActiveRecord::Base
	def self.table_name_prefix
    'crm_'
  end


	humanize_attributes		:crm_account => "Cuenta",
												:crm_opportunity => "Oportunidad",
												:crm_quote_stage_type => "Fase",
												:crm_contact => "Contacto",
												:name => "Asunto",
												:valid_until_date => "Valido hasta",
												:billing_account_name => "Facturación",
												:shipping_account_name => "Envío",
												:shipping_contact_name => "Contacto de envío",
												:shipping_street => "Calle de envío",
												:shipping_city => "Ciudad de envío",
												:shipping_state => "Estado de envío",
												:shipping_postal_code => "Codigo postal de envío",
												:shipping_country => "País de envío",
												:shipping_address => "Domicilio de envío",
												:billing_contact_name => "Contacto de facturación",
												:billing_address => "Domicilio de facturación",
												:billing_street => "Calle de facturación",
												:billing_city => "Ciudad de facturación",
												:billing_state => "Estado de facturación",
												:billing_postal_code => "Codigo postal de facturación",
												:billing_country => "País de facturación",
												:copy_address_from_left => "Copiar dirección",
												:assigned_to => "Asignada a",
												:term_conditions => "Términos y condiciones",
												:description => "Descripción",
												:created_at => "Creado el",
												:sub_total => "Base imponible",
												:tax => "Impuesto",
												:total => "Total"

	validates_presence_of :name,:crm_account,:crm_quote_stage_type,:valid_until_date,:assigned_to

	belongs_to :crm_account,:class_name => "Crm::Account"
	belongs_to :crm_opportunity,:class_name => "Crm::Opportunity"
	belongs_to :crm_quote_stage_type,:class_name => "Crm::QuoteStageType"
	belongs_to :crm_contact,:class_name => "Crm::Contact"
	belongs_to :assigned_to,:class_name => "User"
	has_many :crm_quote_positions,:class_name => "Crm::QuotePosition",:foreign_key => "crm_quote_id"

 


	#
  # Calcula el sub_total y total del presupuesto
  #
  def set_values_sub_total_total
    aux_sub_total = 0
    crm_quote_positions.each do |quote_position|
      aux_sub_total += quote_position.total_price
    end
    self.sub_total = aux_sub_total
    self.tax = self.sub_total*AppConfig.tax_percentage
		aux_sub_total = self.sub_total + self.tax
    self.total = aux_sub_total
    self.save
  end


	#
	# Nombre del modelo
	#
	def self.model_humanize_name
		"Presupuesto"
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
          "label" => "Presupuesto no registrado",
          "code_response" => "no-found"
          }]
    end
    JSON.generate(rows)
	end



end
