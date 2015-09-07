class Backend::HumanResource::DepartmentsController < Backend::HumanResource::BaseController
	def index
		@title = "Recuros Humanos / Departamentos"
		@payroll_departments = Payroll::Department.all
	end

	def new
		@title = "Recuros Humanos / Departamentos / Nuevo"
		@payroll_department = Payroll::Department.new
	end

	def create
		@payroll_department = Payroll::Department.new(params[:payroll_department])
		@success = @payroll_department.valid?
		if @success
			@payroll_department.save
		end
	end

	def show
		@title = "Recuros Humanos / Departamentos / Detalle del cargo"
		@payroll_department = Payroll::Department.find(params[:id])
	end

	def edit
		@title = "Recuros Humanos / Departamentos /  Editar cargo"
		@payroll_department = Payroll::Department.find(params[:id])
	end

	def update
		@payroll_department = Payroll::Department.find(params[:id])
		@success = @payroll_department.update_attributes(params[:payroll_department])
	end
end
