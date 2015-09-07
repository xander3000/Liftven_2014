class State < ActiveRecord::Base
  DISENO = "Diseño"
  FACTURACION = "Facturación"
  COBRADO = "Cobrado"
  POR_COBRAR = "Por Cobrar"

  has_many :state_by_user_groups
  has_many :states,:through => :state_by_user_groups
  has_many :tracking_states
  has_many :state_matrices,:foreign_key => "state_from_id"
  has_many :destination_states, :class_name => "State",:through => :state_matrices,:source => "state_to"

  #
  # Estados que aplican a Ordenes
  #
  def self.all_apply_to_orders
    all(:conditions => {:apply_to => Order.to_s},:order => "sequence ASC")
  end

  #
  # Estados activos para ordenes
  #
  def self.all_actives_apply_to_orders
    all(:conditions => {:apply_to => Order.to_s,:final => false},:order => "sequence ASC")
  end

	#
  # Estados activos para ordenes con presencia
  #
  def self.all_actives_apply_to_orders_with_presence
    all(:conditions =>  ["apply_to = ? AND final = ? AND tracking_states.actual = ?", Order.to_s,false,true],:include => :tracking_states,:order => "sequence ASC")
  end


  #
  # Estado inical para una Orden
  #
  def self.first_apply_to_orders
    first(:conditions => {:apply_to => Order.to_s,:initial => true},:order => "sequence ASC")
  end

  #
  # Estado final para una orden
  #
  def self.first_final_apply_to_orders
    all_final_apply_to_orders.first
  end

  #
  # Estados finales para una orden
  #
  def self.all_final_apply_to_orders
    all(:conditions => {:apply_to => Order.to_s,:final => true},:order => "sequence ASC")
  end

  #
  # Estados que aplican a Facturas
  #
  def self.all_apply_to_invoices(options={})

    clausules = []
    values = []
    conditions  = []

    clausules << "apply_to = ?"
    values << Invoice.to_s

    unless options[:not_in].eql?("")
      clausules << "#{options[:not_in][:key]} NOT IN (?)"
      values << "#{options[:not_in][:value]}"
    end

    conditions << clausules.join(" AND ")
    conditions.concat( values )


    all(:conditions => conditions,:order => "sequence ASC")
  end

  #
  # Estado de facturacion
  #
  def is_invoicing_state?
    name.downcase.eql?("facturación")
  end

  #
  # Es una stado inicial
  #
  def is_initial?
    initial
  end
  
  

  
end
