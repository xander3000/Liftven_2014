class Backend::SupplyChain::Lift::MaterialForManufacturingPhasesController < Backend::SupplyChain::Lift::BaseController
	helper_method :current_lift_material_for_manufacturing_phases


	def index
		@title = "Asociación materiales por modelo"
		@lift_models = Crm::Projects::LiftModel.all_by_category
	end

	def new
		@title = "Asociación materiales por modelo / Nuevo"
		@lift_model = Crm::Projects::LiftModel.new
		current_lift_material_for_manufacturing_phases_clear
	end

	def create
		
		@lift_model = Crm::Projects::LiftModel.new(params[:crm_projects_lift_model])
		@success = @lift_model.valid?
		if @success
			@lift_model.save
			current_lift_material_for_manufacturing_phases.each do |lift_material_for_manufacturing_phase|
				lift_material_for_manufacturing_phase.crm_projects_lift_model = @lift_model
				lift_material_for_manufacturing_phase.save
#				lift_material_for_manufacturing_phase.reload
#				crm_projects_lift_manufacturing_phase_lift_model = Crm::Projects::LiftManufacturingPhaseLiftModel.new
#				crm_projects_lift_manufacturing_phase_lift_model.crm_projects_lift_manufacturing_phase = lift_material_for_manufacturing_phase
#				crm_projects_lift_manufacturing_phase_lift_model.crm_projects_lift_model = @lift_model
#				crm_projects_lift_manufacturing_phase_lift_model.save
			end
			current_lift_material_for_manufacturing_phases_clear
		end
	end

	def show
    current_lift_material_for_manufacturing_phases_clear
		@title = "Asociación materiales por modelo / Detalle"
		@lift_model = Crm::Projects::LiftModel.find(params[:id])
    @lift_model.crm_projects_lift_material_for_manufacturing_phases.each do |lift_material_for_manufacturing_phase|
      self.current_lift_material_for_manufacturing_phases=lift_material_for_manufacturing_phase.attributes
    end

	end


	def edit

	end

	def update

	end

	def new_lift_material_for_manufacturing_phase
		@lift_material_for_manufacturing_phase = Crm::Projects::LiftMaterialForManufacturingPhase.new
	end

	def add_lift_material_for_manufacturing_phase
		@lift_material_for_manufacturing_phase = Crm::Projects::LiftMaterialForManufacturingPhase.new(params[:crm_projects_lift_material_for_manufacturing_phase])
		@success = @lift_material_for_manufacturing_phase.valid?
		if @success
			
			@lift_material_for_manufacturing_phase[:id_temporal] = timestamp
			self.current_lift_material_for_manufacturing_phases=@lift_material_for_manufacturing_phase.attributes
		end
	end

	def delete_lift_material_for_manufacturing_phase
		current_lift_material_for_manufacturing_phases_remove(params[:id_temporal])
	end

	protected

	def current_lift_material_for_manufacturing_phases
		lift_material_for_manufacturing_phases = []
		session[:lift_material_for_manufacturing_phases].each do |item|
      lift_material_for_manufacturing_phase = Crm::Projects::LiftMaterialForManufacturingPhase.new(item)
      lift_material_for_manufacturing_phase[:id_temporal] = item[:id_temporal]
      lift_material_for_manufacturing_phases << lift_material_for_manufacturing_phase
    end
    lift_material_for_manufacturing_phases
	end

	private

	def current_lift_material_for_manufacturing_phases=(supplier_withholding_tax)
    session[:lift_material_for_manufacturing_phases] = [] if session[:lift_material_for_manufacturing_phases].nil?
    session[:lift_material_for_manufacturing_phases] << supplier_withholding_tax
  end

  def current_lift_material_for_manufacturing_phases_remove(id_temporal)
	
    session[:lift_material_for_manufacturing_phases].each do |item|
			
			session[:lift_material_for_manufacturing_phases].delete(item) if item["id_temporal"].to_i.eql?(id_temporal.to_i)
    end
  end



  def current_lift_material_for_manufacturing_phases_clear
    session[:lift_material_for_manufacturing_phases] = []
  end


end
