class Payroll::HistoricalPersonalTypeChange < ActiveRecord::Base
  def self.table_name_prefix
    'payroll_'
  end


	humanize_attributes		:payroll_employee => "Empledado",
                        :user  => "Usuario",
                        :payroll_old_personal_type  => "Tipo de personal actual",
                        :payroll_new_personal_type => "Tipo de personal nuevo",
                        :date => "Fecha cambio",
                        :comment => "Comentario"
                      
  belongs_to :payroll_employee,:class_name => "Payroll::Employee",:foreign_key => "payroll_employee_id"
  belongs_to :payroll_old_personal_type,:class_name => "Payroll::PersonalType",:foreign_key => "payroll_old_personal_type_id"
  belongs_to :payroll_new_personal_type,:class_name => "Payroll::PersonalType",:foreign_key => "payroll_new_personal_type_id"
  belongs_to :user


  validates_presence_of :payroll_employee,:user,:payroll_old_personal_type,:payroll_new_personal_type,:date
  validate :all_presence_fixed_concept_to_new_payroll_personal_type
  after_create :associate_new_payroll_personal_type_to_employee



  #
  # Valida que todos los conceptos fijos del empleados del actual personal_type, esten asociados al nuevo personal_type
  #
  def all_presence_fixed_concept_to_new_payroll_personal_type

  end


  #
  # Asocioa los conceptos fijos al nuevo tipo Personal
  #
  def associate_new_payroll_personal_type_to_employee
    payroll_employee.update_attribute(:payroll_personal_type_id,payroll_new_personal_type.id)
    payroll_employee.reload
    payroll_employee.update_payroll_personal_type_to_fixed_concept
  end
end
