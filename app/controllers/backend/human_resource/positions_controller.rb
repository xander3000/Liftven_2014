class Backend::HumanResource::PositionsController < Backend::HumanResource::BaseController
	def index
		@title = "Recuros Humanos / Cargos"
		@payroll_positions = Payroll::Position.all
	end

	def new
		@title = "Recuros Humanos / Cargos / Nuevo"
		@payroll_position = Payroll::Position.new
	end

	def create
		@payroll_position = Payroll::Position.new(params[:payroll_position])
		@success = @payroll_position.valid?
		if @success
			@payroll_position.save
		end
	end

	def show
		@title = "Recuros Humanos / Cargos / Detalle del cargo"
		@payroll_position = Payroll::Position.find(params[:id])
	end

	def edit
		@title = "Recuros Humanos / Cargos /  Editar cargo"
		@payroll_position = Payroll::Position.find(params[:id])
	end

	def update
		@payroll_position = Payroll::Position.find(params[:id])
		@success = @payroll_position.update_attributes(params[:payroll_position])
	end
end
