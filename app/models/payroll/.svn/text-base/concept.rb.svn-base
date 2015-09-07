class Payroll::Concept < ActiveRecord::Base

  BASIC = "0001"
	SSO = "5001"
	SPF = "5002"
	FAOV = "5003"
	ISLR = "9999"


	def self.table_name_prefix
    'payroll_'
  end

  	humanize_attributes		:name => "Nombre",
                          :fullname => "Nombre descriptivo",
                          :tag_name => "Codigo",
                          :is_basic_salary => "¿Representa salario básico?",
                          :is_allocation => "¿Asociado a asignación?"


  validates_presence_of :name,:tag_name
  validates_numericality_of :tag_name,:greater_than => 0,:less_than => 5000,:only_integer => true,:if => Proc.new { |concept| concept.is_allocation},:message => "debe ser mayor a cero y menor que 5000 si es asignación"
  validates_numericality_of :tag_name,:greater_than_or_equal_to => 5000,:less_than => 10000,:only_integer => true,:if => Proc.new { |concept| !concept.is_allocation},:message => "debe ser mayor o igual a 5000 y menor que 10000 si es deducción"
  validates_uniqueness_of :name,:tag_name

  #before_save :set_fullname_value

#	#
#	# Nombre completo
#	#
#	def fullname
#		"#{tag_name}&nbsp;&nbsp;&nbsp;#{name}"
#	end

	#
	# Suedo basico
	#
	def self.basic_salary
		first(:conditions => {:is_basic_salary => true})
	end
  #
  # Concpeto de obligaciones LEY
  #
  def self.all_deductions
    [SSO,SPF,FAOV,ISLR]
  end

  #
  # Conceptos basicos
  #
  def self.all_basic
    [BASIC,SSO,SPF,FAOV,ISLR]
  end
  
#
#  def set_fullname_value
#    self.fullname = "#{tag_name}&nbsp;&nbsp;&nbsp;#{name}"
#  end


end