class Payroll::HistoricalWageAdjustment < ActiveRecord::Base
  def self.table_name_prefix
    'payroll_'
  end
  

	humanize_attributes		:payroll_employee => "Empledado",
                        :user  => "Usuario",
                        :old_salary  => "Salario actual",
                        :new_salary => "Salario nuevo",
                        :date => "Fecha cambio",
                        :comment => "Comentario"
  belongs_to :payroll_employee,:class_name => "Payroll::Employee",:foreign_key => "payroll_employee_id"
  belongs_to :user


  validates_presence_of :payroll_employee,:user,:old_salary,:new_salary,:date
  validates_numericality_of :new_salary,:greater_than => 0
  validate :new_salary_greater_than_old_salary

  after_create :associate_salary_to_employee

  #
  # Validar que le nuero salario sea mayor al viejo
  #
  def new_salary_greater_than_old_salary
    if self.old_salary.to_f > self.new_salary.to_f
        errors.add(:new_salary,"debe ser mayor al salario actual")
      return false
    end
    true
  end

  #
  # Asociar el salario basico al empleado
  #
  def associate_salary_to_employee
    payroll_employee.update_attribute(:salary,new_salary.to_f.round(2))
    payroll_employee.update_value_salary_to_fixed_concept
  end
end
