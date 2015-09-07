class Backend::HumanResource::ConceptPersonalTypesController < Backend::HumanResource::BaseController
  def index
		@title = "Recursos Humanos / Conceptos por Tipo Personal"
    @payroll_concept_personal_types = Payroll::ConceptPersonalType.all
  end

  def new
		@title = "Recursos Humanos / Conceptos por Tipo Personal / Nuevo Concepto por tipo Personal"
    @payroll_concept_personal_type = Payroll::ConceptPersonalType.new
  end

  def create
    @payroll_concept_personal_type = Payroll::ConceptPersonalType.new(params[:payroll_concept_personal_type])
    @success = @payroll_concept_personal_type.valid?
    if @success
      @payroll_concept_personal_type.save
    end
  end

  def show
    @title = "Recursos Humanos / Conceptos por Tipo Personal / Detalle Concepto por tipo Personal"
    @payroll_concept_personal_type = Payroll::ConceptPersonalType.find(params[:id])
  end

  def edit
    @title = "Recursos Humanos / Conceptos por Tipo Personal / Editar Concepto por tipo Personal"
    @payroll_concept_personal_type = Payroll::ConceptPersonalType.find(params[:id])
  end

  def update
    @payroll_concept_personal_type = Payroll::ConceptPersonalType.find(params[:id])
    @success = @payroll_concept_personal_type.update_attributes(params[:payroll_concept_personal_type])
  end

  def resumen_concept_personal_type_by_payroll_report
    @payroll_personal_types = Payroll::PersonalType.all
  end

  def process_resumen_concept_personal_type_by_payroll_report
		@payroll_regular_payroll_check = Payroll::RegularPayrollCheck.find_resumen_concept_personal_type(params[:concept_payroll])
		render :pdf                            => "resumen_concept_personal_type_by_payroll",
								 :disposition                    => 'attachment',
								 :layout												 =>	'backend/contable_document.html.erb',
								 :orientation                    => 'Portrait',
								 :page_size												=> 'Letter',
							 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																			},
														:left => '-1'
														},
							 :margin => {:top                => 15,
                           :bottom             => 25,
													 :right              => 5,
                           :left               => 5
 												 },

							 :footer => {
										:html => {
												:template => "shared/backend/layouts/footer_contable_document_note.erb",
												#:layout => "shared/backend/layouts/footer_contable_document_note.erb",
										}
								}
  end

	def concepts_by_personal_type
		personal_type = Payroll::PersonalType.find(params[:concept_payroll][:payroll_personal_type_id])
		@concept_personal_types = personal_type.payroll_concept_personal_types
		@payroll_regular_payroll_checks = personal_type.payroll_regular_payroll_checks
		@years = @payroll_regular_payroll_checks.map(&:year).uniq
		@months = @payroll_regular_payroll_checks.map(&:month).uniq.sort
		@fortnights = @payroll_regular_payroll_checks.map(&:fortnight).uniq.sort
	end
end
