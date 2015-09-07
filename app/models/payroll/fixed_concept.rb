class Payroll::FixedConcept < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end

	humanize_attributes	:unit => "Unidad",
												:amount => "Cantidad",
												:payroll_concept_personal_type => "Concepto por tipo personal",
												:payroll_concept_personal_type_id => "Concepto por tipo personal",
												:payroll_payment_frequency => "Frecuencia de pago",
												:payroll_employee => "Empleado",
                        :note => "Observaciones"

	belongs_to :payroll_concept_personal_type,:class_name => "Payroll::ConceptPersonalType"
	belongs_to :payroll_payment_frequency,:class_name => "Payroll::PaymentFrequency"
	belongs_to :payroll_employee,:class_name => "Payroll::Employee"



	validates_presence_of :payroll_concept_personal_type,:payroll_payment_frequency,:payroll_employee,:amount
	validates_numericality_of :amount
	validates_uniqueness_of :payroll_concept_personal_type_id,:scope => [:payroll_employee_id]

	#
	# Codigo d conceptp
	#
	def code
		payroll_concept_personal_type.payroll_concept.tag_name
	end

	#
	# Nombre d conceptp
	#
	def name
		payroll_concept_personal_type.payroll_concept.name
	end

	#
	# Fullname del conceptp
	#
	def fullname
		payroll_concept_personal_type.payroll_concept.fullname
	end

	#
	# Valor calculado
	#
	def value_for_concept
		salary = employee.salary
		if payroll_concept_personal_type.payroll_concept.is_basic_salary
			value = salary
		else
			value = salary
		end
		value
	end


end
