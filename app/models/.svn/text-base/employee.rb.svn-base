class Employee < ActiveRecord::Base

   humanize_attributes :in_case_of_emergency_notify => "En caso de emergencia notificar a",
                      :emergency_phone => "Número de emergencia",
                      :join_date => "Fecha de ingreso",
                      :position => "Cargo",
                      :salary => "Salario"

  has_one  :contact_category,:as => :category
  belongs_to :position
	belongs_to :payroll_personal_type,:class_name => "Payroll::PersonalType"
	has_many :payroll_fixed_concepts,:class_name => "Payroll::FixedConcept"
	has_many :payroll_last_payrolls,:class_name => "Payroll::LastPayroll"

  #has_many :orders,:conditions => ["trackers.category_id = ? AND trackers.category_type = ?",

#  validates_presence_of :position,:in_case_of_emergency_notify,:emergency_phone,:position,:salary

	#
  # Retorna la informacion de contacto del cliente
  #
  def name
    contact.name
  end


  #
  # Retorna la informacion de contacto del cliente
  #
  def contact
    contact_category.contact
  end

  #
  # Retorna el usuario asociado a este empelado
  #
  def user
    contact.user
  end

  #
  # Retorna las ordenes del empleado
  #

  def orders
    return [] if user.nil?
#    clausules = []
#    values = []
#    conditions  = []
#
#    joins = [:doc => [:case => [:tracking_states => [:trackers]]]]
#
#
#    clausules << "trackers.category_id = ?"
#    values << user.id
#    clausules << "trackers.category_type = ?"
#    values << user.class.to_s
#
#			user.all_actives_apply_to_orders_by_user_groups
#
#			clausules = []
#      values = []
#      conditions  = []
#      clausules << "orders.canceled = ?"
#      values << false
#      clausules << "tracking_states.state_id IN (?)"
#      values << states.map(&:id)
#      clausules << "tracking_states.actual = ?"
#      values << true
#      clausules << "trackers.category_id = ?"
#      values << user.id
#      clausules << "trackers.category_type = ?"
#      values << user.class.to_s
#      clausules << "trackers.actual = ?"
#      values << true
#
#
#
#
#    clausules << "trackers.actual = ?"
#    values << true
#    conditions << clausules.join(" AND ")
#    conditions.concat( values )
#    Order.all(:conditions => conditions,:joins => joins)

		Order.by_user_for_selection(user)
  end

	#
	# Todos ls activos
	#
	def self.all_actives
		all(:conditions => {:status => "A"})
	end
	#
	# Empleados por tipo de personal
	#
	def self.all_by_personal_type(options={})
		options[:sortorder] = options[:sortorder] || "desc"
    options[:sortname] = options[:sortname] || "employees.id"
    options[:rp] = options[:rp] || 15
    options[:page] = options[:page] || 1
    options[:qtype] = options[:qtype] || "employees.id"
    options[:query] = options[:query] || ""
    options[:date] ||=Date.today.year


    personal_types = Payroll::PersonalType.all
  
    employees_by_personal_type = []
    joins = [:contact_category => [:contact],:payroll_personal_type => []]

    personal_types.each do |personal_type|
      clausules = []
      values = []
      conditions  = []
      clausules << "employees.status = ?"
      values << "A"
      clausules << "payroll_personal_types.id = ?"
      values << personal_type.id
      

      conditions << clausules.join(" AND ")
      conditions.concat( values )
      employees = all(:conditions => conditions,:joins => joins,:group => "employees.id")
      employees_paginate = employees.paginate(:page => options[:page], :per_page => options[:rp],:conditions => conditions,:joins => joins,:order => "#{options[:sortname]} #{options[:sortorder]}")
      employees_by_personal_type << {:personal_type => personal_type,:count => employees.size,:paginate => employees_paginate}
    end
    employees_by_personal_type
	end

	#
	# Conceptos fijos Asigandos
	#
	def payroll_fixed_allocation_concepts
		payroll_fixed_concepts.all(:conditions => ["payroll_concepts.is_allocation = ?",true],:joins => [:payroll_concept_personal_type => [:payroll_concept]])
	end

	#
	# Conceptos fijos Deducibles
	#
	def payroll_fixed_not_allocation_concepts
		payroll_fixed_concepts.all(:conditions => ["payroll_concepts.is_allocation = ?",false],:joins => [:payroll_concept_personal_type => [:payroll_concept]])
	end



end
