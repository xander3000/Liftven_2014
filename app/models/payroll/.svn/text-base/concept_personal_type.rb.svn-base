class Payroll::ConceptPersonalType < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end

	belongs_to :payroll_personal_type,:class_name => "Payroll::PersonalType"
	belongs_to :payroll_concept,:class_name => "Payroll::Concept"
	belongs_to :payroll_amount_type,:class_name => "Payroll::AmountType"
	belongs_to :payroll_payment_frequency,:class_name => "Payroll::PaymentFrequency"

  	humanize_attributes		:payroll_personal_type => "Tipo personal",
                          :payroll_concept => "Concepto",
                          :payroll_concept_id => "Concepto",
                          :payroll_amount_type => "Tipo de monto",
                          :payroll_payment_frequency => "Frecuencia de pago",
                          :unit => "Unidad",
                          :value  => "Valor",
                          :retains_spf => "¿Retiene SPF?",
                          :retains_fju => "¿Retiene FJU?",
                          :retains_sso => "¿Retiene SSO?",
                          :retains_faov => "¿Retiene FAOV?",
                          :retains_islr => "¿Retiene ISLR?"

  validates_presence_of :payroll_personal_type,:payroll_concept,:payroll_amount_type,:payroll_payment_frequency,:value,:unit
	validates_uniqueness_of :payroll_concept_id,:scope => [:payroll_personal_type_id]

  #
	# Find by concepto tag
	#
	def self.find_by_code_concept(code_concept,personal_type)
		first(:conditions => ["payroll_concept_personal_types.payroll_personal_type_id = ? AND lower(payroll_concepts.tag_name) = ?",personal_type.id,code_concept.downcase],:joins => [:payroll_concept])
	end

	#
	# Nombre
	#
	def name
		payroll_concept.name
	end

	#
	# Suedo basico
	#
	def self.basic_salary_payroll_personal_type(payroll_personal_type)
		first(:conditions => {:payroll_concept_id =>Payroll::Concept.basic_salary.id,:payroll_personal_type_id => payroll_personal_type})
	end

  #
	# Suedo basico
	#
	def self.all_by_personal_type(payroll_personal_type)
		all(:conditions => {:payroll_personal_type_id => payroll_personal_type.id})
	end
	


end