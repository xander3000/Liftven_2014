class Backend::HumanResource::ConceptsController < Backend::HumanResource::BaseController
  def index
		@title = "Recursos Humanos / Conceptos"
    @payroll_concepts = Payroll::Concept.all
  end

  def new
		@title = "Recursos Humanos / Conceptos / Nuevo Concepto"
    @payroll_concept = Payroll::Concept.new
  end

  def create
    @payroll_concept = Payroll::Concept.new(params[:payroll_concept])
    @success = @payroll_concept.valid?
    if @success
      @payroll_concept.save
    end
  end

  def show

  end

  def edit

  end

  def update

  end
end
