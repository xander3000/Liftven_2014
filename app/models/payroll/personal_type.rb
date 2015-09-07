class Payroll::PersonalType < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end

	has_many :payroll_concept_personal_types,:class_name => "Payroll::ConceptPersonalType",:foreign_key => "payroll_personal_type_id"#,:include => [:payroll_employee_status_type]
	has_many :payroll_employees,:class_name => "Payroll::Employee",:foreign_key => "payroll_personal_type_id"
	has_many :active_payroll_employees,:class_name => "Payroll::Employee",:foreign_key => "payroll_personal_type_id",:conditions => ["payroll_employee_status_types.tag_name = ?",Payroll::EmployeeStatusType::ACTIVE],:include => [:payroll_employee_status_type],:order => "payroll_employees.income_date ASC"
	has_many :payroll_regular_payroll_checks,:class_name => "Payroll::RegularPayrollCheck",:foreign_key => "payroll_personal_type_id"

  #
  # tiene todas las obligaciones de ley
  #
  def has_all_deductions?
    Payroll::ConceptPersonalType.all(:conditions => ["payroll_personal_type_id =  ? AND payroll_concepts.tag_name IN (?)",id ,Payroll::Concept.all_deductions],:joins => [:payroll_concept]).size.eql?(Payroll::Concept.all_deductions.size)
  end


end