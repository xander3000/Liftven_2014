class Material::ProductionOrder < ActiveRecord::Base
  def self.table_name_prefix
    'material_'
  end
  attr_accessor :requesting_unit_name
  humanize_attributes   :material_production_orden_type => "Tipo orden de producción",
                        :requesting_unit => "Unidad Solicitante",
                        :requesting_unit_type => "Unidad Solicitante",
                        :requesting_unit_name => "Unidad Solicitante",
                        :delivery_date => "Fecha a despachar",
                        :description => "Descripción",
                        :proyect_name => "Nombre del proyecto",
												:material_production_orden_positions => "Posiciones"

  belongs_to :material_production_orden_type,:class_name => "Material::ProductionOrderType"
  belongs_to :requesting_unit,:polymorphic => true
	has_many :material_production_order_positions,:class_name => "Material::ProductionOrderPosition",:foreign_key => "material_production_order_id"

  validates_presence_of :material_production_orden_type,:requesting_unit,:delivery_date,:description

	alias_method(:material_positions, :material_production_order_positions)

	#
	# Nombred eunidad solicitante
	#
	def requesting_unit_name
		requesting_unit.name
	end
  
  #
	# Nombre del modelo
	#
	def self.model_humanize_name
		"Movimiento de mercancia"
	end
  
  
end
