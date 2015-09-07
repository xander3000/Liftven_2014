class Crm::Projects::Lift < ActiveRecord::Base
  def self.table_name_prefix
    'crm_projects_'
  end

humanize_attributes :crm_project => "Proyecto",
										:crm_projects_lift_category_type => "Categoria",
										:crm_projects_lift_model => "Modelo",
										:module => "Módulo",
										:tower => "Torre",
										:route => "Recorrido",
										:about_travel => "Sobre recorrido",
										:levels => "Niveles",
										:stops => "Paradas",
										:passenger_capacity => "Capacidad persona",
										:load_capacity => "Capacidad carga",
										:width_pit => "Ancho pozo",
										:fund_pit => "Fondo pozo",
										:moat => "Foso",
										:well => ""
										

	belongs_to :crm_projects_lift_category_type,:class_name => "Crm::Projects::LiftCategoryType"
	belongs_to :crm_projects_lift_model,:class_name => "Crm::Projects::LiftModel"
	belongs_to :crm_project,:class_name => "Crm::Project"

	validates_presence_of :crm_projects_lift_category_type,:crm_projects_lift_model,:module,:tower,:route,:about_travel,:levels,:stops,
												:passenger_capacity,:load_capacity,:width_pit,:fund_pit,:moat

	after_create	:generate_production_order_and_purchase_requisition


	def name
		"Ascensor Proyecto #{crm_project.name}"
	end

	#
	# Crea las ordenes de
	#
	def generate_production_order_and_purchase_requisition
		crm_projects_lift_model.crm_projects_lift_manufacturing_phases.each do |phase|
				generate_purchase_requisition_for_phase(phase)
				generate_production_order_for_phase(phase)
		end
	end

	#
	# Crear una orden de pedido en base a la fase
	#
	def generate_purchase_requisition_for_phase(phase)
		
		purchase_requisition = Material::PurchaseRequisition.new
		purchase_requisition.create_by = User.first
		purchase_requisition.posting_date = Time.now.to_date.to_s
		purchase_requisition.delivery_date = crm_project.init_date
		purchase_requisition.material_purchase_requisition_status_type = Material::PurchaseRequisitionStatusType.default
		purchase_requisition.note = "Proyecto: #{crm_project.name} Cliente: #{crm_project.client.name} Ejecutivo: #{crm_project.crm_projects_executive.name} Fase: #{phase.name}"
		if purchase_requisition.valid?
			phase.crm_projects_lift_material_for_manufacturing_phases.each do |lift_material_for_manufacturing_phase|
				material = lift_material_for_manufacturing_phase.material_raw_material
				material_unrestricted_use_stock = material.unrestricted_use_stock
				phase_quantity = lift_material_for_manufacturing_phase.quantity
				require = material_unrestricted_use_stock - phase_quantity
				if require < 0
					purchase_requisition_position = Material::PurchaseRequisitionPosition.new
					purchase_requisition_position.material_purchase_requisition_position_status_type = Material::PurchaseRequisitionPositionStatusType.default
					purchase_requisition_position.material_raw_material = material
					purchase_requisition_position.material_order_measure_unit = material.material_issue_measure_unit
					purchase_requisition_position.reason = "Fase: #{phase.name} Proyecto #{crm_project.name}"
					purchase_requisition_position.quantity = require.abs
					if purchase_requisition_position.valid?
						purchase_requisition.save
						purchase_requisition_position.material_purchase_requisition = purchase_requisition
						purchase_requisition_position.save
					end
				end
			end
		end

		
		
	end

	#
	# Crear una movieminto de mercancia en base a la fase
	#
	def generate_production_order_for_phase(phase)
		
		production_order = Material::ProductionOrder.new

		production_order.material_production_orden_type = Material::ProductionOrderType.first
		production_order.delivery_date = crm_project.init_date
		production_order.description = "Proyecto: #{crm_project.name} Cliente: #{crm_project.client.name} Ejecutivo: #{crm_project.crm_projects_executive.name} Fase: #{phase.name}"
		production_order.requesting_unit = self
		production_order.proyect_name = crm_project.name

		if production_order.valid?
			phase.crm_projects_lift_material_for_manufacturing_phases.each do |lift_material_for_manufacturing_phase|
				material = lift_material_for_manufacturing_phase.material_raw_material
				material_unrestricted_use_stock = material.unrestricted_use_stock
				phase_quantity = lift_material_for_manufacturing_phase.quantity
				require = material_unrestricted_use_stock - phase_quantity
				if material_unrestricted_use_stock > 0 and require != 0

					production_order_position = Material::ProductionOrderPosition.new
					production_order_position.material_raw_material = material
					production_order_position.quantity = (require > 0 ?  phase_quantity : (phase_quantity + require))

					if production_order_position.valid?
						production_order.save
						production_order_position.material_production_order = production_order
						production_order_position.save
					end
				end
			end
		end
	end
end
