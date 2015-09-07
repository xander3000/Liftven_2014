class Backend::HumanResource::EmployeesController < Backend::HumanResource::BaseController
	def index
				@title = "Recursos Humanos / Empleados"
        @payroll_employees = Payroll::Employee.all_actives
        respond_to do |format|

				format.html
				format.csv do
          path_to_save = "#{RAILS_ROOT}/public/csv"
          file_name = "#{path_to_save}/empleados.csv"
          if !File.exist?(path_to_save)
            system 'mkdir', '-p', path_to_save
          end
          	 owner = Supplier.find_owner
              contact = owner.contact
              CSV.open(file_name, "wb",  ';' ) do |csv|
                          csv << [Iconv.iconv('iso8859-1','utf-8', contact.fullname.upcase).first]
                          csv << [Iconv.iconv('iso8859-1','utf-8',contact.address).first]
                         
                          csv << []
                          csv << [
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Staff.human_attribute_name("identification_document")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Staff.human_attribute_name("fullname")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("payroll_personal_type")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("payroll_position")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("payroll_department")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("salary")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("income_date")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("discharge_date")).first,
                                    Iconv.iconv('iso8859-1','utf-8', Payroll::Employee.human_attribute_name("account_number")).first
                                    
                                    ]
                          @payroll_employees.each do |payroll_employee|
                            csv << [
                                    Iconv.iconv('iso8859-1','utf-8', payroll_employee.payroll_staff.identification_document).first,
                                    Iconv.iconv('iso8859-1','utf-8', payroll_employee.payroll_staff.fullname).first,
                                    Iconv.iconv('iso8859-1','utf-8', payroll_employee.payroll_personal_type.name).first,
                                    Iconv.iconv('iso8859-1','utf-8', payroll_employee.payroll_position.name).first,
                                    Iconv.iconv('iso8859-1','utf-8', payroll_employee.payroll_department.name).first,
                                    Iconv.iconv('iso8859-1','utf-8', payroll_employee.salary.to_currency(false)).first,
                                    Iconv.iconv('iso8859-1','utf-8', payroll_employee.income_date.to_default_date).first,
                                    Iconv.iconv('iso8859-1','utf-8', payroll_employee.discharge_date).first,
                                    Iconv.iconv('iso8859-1','utf-8', payroll_employee.account_number).first
                                    ]
                          end
                    end
          send_file file_name,:type => "text/csv;"
				end
		end

	end

	def show
		@title = "Recursos Humanos / Empleados / Detalle empleado"
		@payroll_employee = Payroll::Employee.find(params[:id])
    @payroll_staff  = @payroll_employee.payroll_staff
    @employee_fixed_concept = Payroll::FixedConcept.new
    
	end

	def new
		@title = "Recursos Humanos / Empleados / Nuevo empleado"
		@payroll_employee = Payroll::Employee.new
		@payroll_staff  = Payroll::Staff.new
	end

	def create
		@payroll_employee = Payroll::Employee.new(params[:payroll_employee])
		@payroll_staff  = Payroll::Staff.new(params[:payroll_staff])

		@success = @payroll_staff.valid?
		@success &= @payroll_employee.valid?

		if @success
			@payroll_staff.save
			@payroll_employee.payroll_staff = @payroll_staff
			@payroll_employee.save
		end

	end

  def new_fixed_concept
    @payroll_employee = Payroll::Employee.find(params[:employee_id])
		@employee_fixed_concept = Payroll::FixedConcept.new
    @payroll_concept_personal_types = Payroll::ConceptPersonalType.all_by_personal_type(@payroll_employee.payroll_personal_type)
  end


	def add_fixed_concept
		
		@payroll_employee = Payroll::Employee.find(params[:employee_id])
		@employee_fixed_concept = Payroll::FixedConcept.new(params[:payroll_fixed_concept])
		@employee_fixed_concept.payroll_employee = @payroll_employee
		@success = @employee_fixed_concept.valid?
		if @success
			@employee_fixed_concept.save
		end
	end

  def new_variable_concept
    @employee = Payroll::Employee.find(params[:employee_id])
		@employee_variable_concept = Payroll::VariableConcept.new
    @payroll_concept_personal_types = Payroll::ConceptPersonalType.all_by_personal_type(@employee.payroll_personal_type)
  end


	def add_variable_concept

		@payroll_employee = Payroll::Employee.find(params[:employee_id])
		@employee_variable_concept = Payroll::VariableConcept.new(params[:payroll_variable_concept])
		@employee_variable_concept.payroll_employee = @payroll_employee
		@success = @employee_variable_concept.valid?
		if @success
			@employee_variable_concept.save
		end
	end

  def remove_variable_concept
    @payroll_employee = Payroll::Employee.find(params[:employee_id])
		@employee_variable_concept = Payroll::VariableConcept.find(params[:payroll_variable_concept_id])
    @success = @employee_variable_concept.destroy
	end


  def edit
    @title = "Recursos Humanos / Editar empleado"
		@payroll_employee = Payroll::Employee.find(params[:id])
    @payroll_staff  = @payroll_employee.payroll_staff
  end

  def update
    @payroll_employee = Payroll::Employee.find(params[:id])
    @payroll_staff  = @payroll_employee.payroll_staff
    @success = @payroll_employee.update_attributes(params[:payroll_employee])
    @success &= @payroll_staff.update_attributes(params[:payroll_staff])
  end

	def autocomplete_by_name
    result = Payroll::Employee.find_by_employee_autocomplete("payroll_staffs.first_name",params[:term])
    render :json => result
  end

  def new_historical_wage_adjustment
    @payroll_employee = Payroll::Employee.find(params[:employee_id])
    @historical_wage_adjustment = Payroll::HistoricalWageAdjustment.new
    @historical_wage_adjustment.payroll_employee = @payroll_employee
    @historical_wage_adjustment.user = current_user
    @historical_wage_adjustment.old_salary = @payroll_employee.salary
  end

  def add_historical_wage_adjustment
      @payroll_employee = Payroll::Employee.find(params[:employee_id])
      @historical_wage_adjustment = Payroll::HistoricalWageAdjustment.new(params[:payroll_historical_wage_adjustment])
      @historical_wage_adjustment.payroll_employee = @payroll_employee
      @historical_wage_adjustment.user = current_user
      @historical_wage_adjustment.old_salary = @payroll_employee.salary
      @success = @historical_wage_adjustment.valid?
      if @success
        @historical_wage_adjustment.save
        @payroll_employee.reload
      end
  end

  def change_personal_type
    @payroll_employee = Payroll::Employee.find(params[:employee_id])
    @historical_personal_type_change = Payroll::HistoricalPersonalTypeChange.new
    @historical_personal_type_change.payroll_employee = @payroll_employee
    @historical_personal_type_change.user = current_user
    @historical_personal_type_change.payroll_old_personal_type = @payroll_employee.payroll_personal_type
  end

  def process_change_personal_type
    @payroll_employee = Payroll::Employee.find(params[:employee_id])
    @historical_personal_type_change = Payroll::HistoricalPersonalTypeChange.new(params[:payroll_historical_personal_type_change])
    @historical_personal_type_change.payroll_employee = @payroll_employee
    @historical_personal_type_change.user = current_user
    @historical_personal_type_change.payroll_old_personal_type = @payroll_employee.payroll_personal_type

    @success = @historical_personal_type_change.valid?
    if @success
      @historical_personal_type_change.save
    end
  end
  

	def graduation
		@payroll_employee = Payroll::Employee.find(params[:employee_id])
		@payroll_employee.payroll_employee_status_type = Payroll::EmployeeStatusType.find_by_tag_name(Payroll::EmployeeStatusType::GRADUATE)
	end

	def process_graduation
		@payroll_employee = Payroll::Employee.find(params[:employee_id])
		@payroll_employee.update_attributes(params[:payroll_employee])
	end

	def proof_employment
		@payroll_employee = Payroll::Employee.find(params[:employee_id])
					render :pdf                            => "proof_employment_#{@payroll_employee.fullname.to_underscore}",
								 :disposition                    => 'attachment',
								 :layout												 =>	'backend/contable_document.html.erb',
								 :orientation                    => 'Portrait',
								 :page_size												=> 'Letter',
							 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																			},
														:left => '-1'
														},
							 :margin => {:top                => 18,
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

	def report_status
		@payroll_employees = Payroll::Employee.all_by_status(params[:status])
					render :pdf                            => "employess",
								 :disposition                    => 'attachment',
								 :layout												 =>	'backend/contable_document.html.erb',
								 :orientation                    => 'Landscape',
								 :page_size												=> 'Letter',
								 :template											=> "#{controller_path}/reports/report_status",
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

	protected


end
