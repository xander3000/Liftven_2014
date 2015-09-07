class Order < ActiveRecord::Base
  #TODO: Pedir al sr Guillermo
  SUBJECT_CASE = "se ha creado un caso para"
  NOTE_CASE = "se requiere crear "
  SUBJECT_DISCARD_DESIGN = "Rechazado diseño(s) order no"
  SUBJECT_ACCEPT_DESIGN = "Aceptado diseño(s) order no"
  NOTE_ACCEPT_DESIGN = "El cliente esta conforme con el diseño no"
  UNEXPIRED = "unexpired"
  EXPIRED = "expired"
  WARNING = "warning"

  humanize_attributes :credit_debit_card_number => "Número de la tarjeta",
                      :credit_debit_card_name => "Nombre del tarjetahabiente",
                      :credit_debit_card_expiry_date => "Fecha de expiración",
                      :mercantil_transfer_deposit_bank_number => "Número de la transferencia o depósito",
                      :mercantil_transfer_deposit_bank_date => "Fecha de la transferencia o depósito",
                      :payment_method_type => "Método de pago",
											:user => "Usuario",
											:client => "Cliente",
											:base => "Orden de producción"

  has_many :notifications,:as => :category
	has_many :delivery_notes
  has_one :doc,:as => :category, :dependent => :destroy
	belongs_to :associate,:polymorphic => true
  belongs_to :client
  belongs_to :user

  validates_presence_of :client
  validates_presence_of :user
#  validates_presence_of :payment_method_type,:message => "debe seleccionar una forma de pago"
#  validates_presence_of :credit_debit_card_number,:credit_debit_card_name,:credit_debit_card_expiry_date, :if => Proc.new { |order| order.payment_method_type and order.payment_method_type.is_credit_debit_card? }
#  validates_presence_of :mercantil_transfer_deposit_bank_number,:mercantil_transfer_deposit_bank_date, :if => Proc.new { |order| order.payment_method_type and order.payment_method_type.is_transfer_deposit_bank? }

	alias_method(:product_by_budget, :associate)


  #
  # Crea una orden y la asocia con un caso
  #
  def self.guardar(attr,options={})
    object = new(attr)
    success = object.valid?
    #object.errors.each { |e,r| puts "#{e}: #{r}" }
    if success
      attr_case = {
        :subject => options[:subject_case],
        :note => options[:note_case]
      }
      options_case = {
        :doc => to_s
      }
      options_case = options_case.merge(options)
      
      result = Case.guardar(attr_case,options_case)
      if result[:success]
       object.save
       object_doc = Doc.new
       object_doc.case = result[:object]
       object_doc.category = object
       object_doc.principal = true
       object_doc.save
      end
    end
    {:success => success,:object => object}
  end

  #
  # Busca todas las ordenes creadas y llleva json
  #

  def self.all_to_json
    data = []
    names = []
    last_year = Time.now - 1.year
    count(:select => "created_at",:conditions => ["(date_format(created_at, '%Y%M')) >= ?",last_year.strftime("%Y%m")],:group => "date_format(created_at, '%Y/%M')").to_a.each do |item|
      names << item.first
      data << item.last
    end
    JSON.generate("NAME" => "Pedidos","CATEGORIES" => names,"DATA" => data)
    #rows
  end

  #
  # Busca todos las ordenes por usuario
  #
  def self.by_user_for_selection(user,options={})

    states = user.all_actives_apply_to_orders_by_user_groups
    joins = [:doc => [:case => [:tracking_states => [:trackers]]]]

      clausules = []
      values = []
      conditions  = []
      clausules << "orders.canceled = ?"
      values << false
      clausules << "tracking_states.state_id IN (?)"
      values << states.map(&:id)
      clausules << "tracking_states.actual = ?"
      values << true
      clausules << "trackers.category_id = ?"
      values << user.id
      clausules << "trackers.category_type = ?"
      values << user.class.to_s
      clausules << "trackers.actual = ?"
      values << true

      conditions << clausules.join(" AND ")
      conditions.concat( values )
      all(:conditions => conditions,:joins => joins)
  end
  #
  # Busca todos las ordenes por usuario
  #
  def self.count_by_user_for_selection(user,options={})
    by_user_for_selection(user).size
  end



  #
  # Busca todas las ordenes NO VENCIDAS
  #

  def self.all_unexpired_by_user(user,options={})
    options[:sortorder] = options[:sortorder] || "desc"
    options[:sortname] = options[:sortname] || "orders.id"
    options[:rp] = options[:rp] || 15
    options[:page] = options[:page] || 1
    options[:qtype] = options[:qtype] || "orders.id"
    options[:query] = options[:query] || ""
    options[:date] ||=Date.today.year
		options[:state] ||= State.all_actives_apply_to_orders
		options[:orders] ||= all

    states = options[:state]

    orders = options[:orders]
    joins = [:doc => [:case => [:tracking_states => :trackers]]]

    
      clausules = []
      values = []
      conditions  = []
			clausules << "orders.id IN (?)"
      values << orders.map(&:id)
      clausules << "orders.canceled = ?"
      values << false
      clausules << "tracking_states.state_id IN (?)"
      values << states.map(&:id)
      clausules << "tracking_states.actual = ?"
      values << true
      clausules << "tracking_states.updated_at >= ?"
      values << Time.now - AppConfig.get_value_by_name(AppConfig::TIME_ORDER_UNEXPIRED).to_i.days
      clausules << "tracking_states.actual = ?"
      values << true
      clausules << "trackers.category_id = ?"
      values << user.id
      clausules << "trackers.category_type = ?"
      values << user.class.to_s
			clausules << "trackers.actual = ?"
      values << true

      conditions << clausules.join(" AND ")
      conditions.concat( values )
      all(:conditions => conditions,:include => joins)
  end

  #
  # Busca todas las ordenes  VENCIDAS
  #

  def self.all_expired_by_user(user,options={})
    options[:sortorder] = options[:sortorder] || "desc"
    options[:sortname] = options[:sortname] || "orders.id"
    options[:rp] = options[:rp] || 15
    options[:page] = options[:page] || 1
    options[:qtype] = options[:qtype] || "orders.id"
    options[:query] = options[:query] || ""
    options[:date] ||=Date.today.year
		options[:state] ||= State.all_actives_apply_to_orders
		options[:orders] ||= all

    states = options[:state]

    orders = options[:orders]
    joins = [:doc => [:case => [:tracking_states => :trackers]]]


      clausules = []
      values = []
      conditions  = []
			clausules << "orders.id IN (?)"
      values << orders.map(&:id)
      clausules << "orders.canceled = ?"
      values << false
      clausules << "tracking_states.state_id IN (?)"
      values << states.map(&:id)
      clausules << "tracking_states.actual = ?"
      values << true
      clausules << "tracking_states.updated_at < ?"
      values << Time.now - AppConfig.get_value_by_name(AppConfig::TIME_ORDER_WARNING).to_i.days
      clausules << "tracking_states.actual = ?"
      values << true
      clausules << "trackers.category_id = ?"
      values << user.id
      clausules << "trackers.category_type = ?"
      values << user.class.to_s
			clausules << "trackers.actual = ?"
      values << true

      conditions << clausules.join(" AND ")
      conditions.concat( values )
      all(:conditions => conditions,:include => joins)
  end

  #
  # Busca todas las ordenes POR VENCERSE
  #

  def self.all_warning_by_user(user,options={})
    options[:sortorder] = options[:sortorder] || "desc"
    options[:sortname] = options[:sortname] || "orders.id"
    options[:rp] = options[:rp] || 15
    options[:page] = options[:page] || 1
    options[:qtype] = options[:qtype] || "orders.id"
    options[:query] = options[:query] || ""
    options[:date] ||=Date.today.year
		options[:state] ||= State.all_actives_apply_to_orders
		options[:orders] ||= all

    states = options[:state]

    orders = options[:orders]
    joins = [:doc => [:case => [:tracking_states => :trackers]]]


      clausules = []
      values = []
      conditions  = []
			clausules << "orders.id IN (?)"
      values << orders.map(&:id)
      clausules << "orders.canceled = ?"
      values << false
      clausules << "tracking_states.state_id IN (?)"
      values << states.map(&:id)
      clausules << "tracking_states.updated_at >= ?"
      values << Time.now - AppConfig.get_value_by_name(AppConfig::TIME_ORDER_WARNING).to_i.days
      clausules << "tracking_states.updated_at < ?"
      values << Time.now - AppConfig.get_value_by_name(AppConfig::TIME_ORDER_UNEXPIRED).to_i.days
      clausules << "tracking_states.actual = ?"
      values << true
      clausules << "trackers.category_id = ?"
      values << user.id
      clausules << "trackers.category_type = ?"
      values << user.class.to_s
			clausules << "trackers.actual = ?"
      values << true

      conditions << clausules.join(" AND ")
      conditions.concat( values )
      all(:conditions => conditions,:include => joins)
  end

	#
	# Busca todas las ordenes po usuario
	#
	def self.all_by_user(user,options={})
		options[:sortorder] = options[:sortorder] || "desc"
    options[:sortname] = options[:sortname] || "orders.id"
    options[:rp] = options[:rp] || 15
    options[:page] = options[:page] || 1
    options[:qtype] = options[:qtype] || "orders.id"
    options[:query] = options[:query] || ""
    options[:date] ||=Date.today.year
		options[:state] ||= State.all_actives_apply_to_orders

    states = options[:state]
    orders = []
    joins = [:doc => [:case => [:tracking_states => :trackers]]]


      clausules = []
      values = []
      conditions  = []
      clausules << "orders.canceled = ?"
      values << false
      clausules << "tracking_states.state_id IN (?)"
      values << states.map(&:id)
     
      clausules << "tracking_states.actual = ?"
      values << true
      clausules << "trackers.category_id = ?"
      values << user.id
      clausules << "trackers.category_type = ?"
      values << user.class.to_s
			clausules << "trackers.actual = ?"
      values << true

      conditions << clausules.join(" AND ")
      conditions.concat( values )
      all(:conditions => conditions,:include => joins)
	end


	#
  # Busca todos las ordenes activas por usuario
  #
  def self.all_by_active_user_and_states(user,options={})

    options[:sortorder] = options[:sortorder] || "desc"
    options[:sortname] = options[:sortname] || "orders.id"
    options[:rp] = options[:rp] || 15
    options[:page] = options[:page] || 1
    options[:qtype] = options[:qtype] || "orders.id"
    options[:query] = options[:query] || ""
    options[:date] ||=Date.today.year
		options[:state] ||= State.all_actives_apply_to_orders_with_presence

    states = options[:state]

    
    ## State.all_actives_apply_to_orders
    orders_by_state = []
    joins = [:doc => [:case => [:tracking_states => :trackers]]]

    states.each do |state|
      clausules = []
      values = []
      conditions  = []
      clausules << "orders.canceled = ?"
      values << false
      clausules << "tracking_states.state_id = ?"
      values << state.id
      clausules << "tracking_states.actual = ?"
      values << true
      clausules << "trackers.category_id = ?"
      values << user.id
      clausules << "trackers.category_type = ?"
      values << user.class.to_s
			clausules << "trackers.actual = ?"
      values << true

      conditions << clausules.join(" AND ")
      conditions.concat( values )
      orders = all(:conditions => conditions,:include => joins,:group => "orders.id")
      orders_paginate = orders.paginate(:page => options[:page], :per_page => options[:rp],:conditions => conditions,:joins => joins,:order => "#{options[:sortname]} #{options[:sortorder]}")
      orders_by_state << {:state => state,:count => orders.size,:paginate => orders_paginate}
    end
    orders_by_state
  end

  #
  # Busca todos las ordenes por usuario
  #
  def self.all_by_user_and_states(user,options={})


		
    options[:sortorder] = options[:sortorder] || "desc"
    options[:sortname] = options[:sortname] || "orders.id"
    options[:rp] = options[:rp] || 15
    options[:page] = (options[:page] || 1).to_i
    options[:qtype] = options[:qtype] || "orders.id"
    options[:query] = options[:query] || ""
    options[:date] ||=Date.today.year


    states = user.all_actives_apply_to_orders_by_user_groups

    ## State.all_actives_apply_to_orders
    orders_by_state = []
    joins = [:doc => [:case => [:tracking_states => [:trackers]]]]

    states.each do |state|
      clausules = []
      values = []
      conditions  = []
      clausules << "orders.canceled = ?"
      values << false
      clausules << "tracking_states.state_id = ?"
      values << state.id
      clausules << "tracking_states.actual = ?"
      values << true
      clausules << "trackers.category_id = ?"
      values << user.id
      clausules << "trackers.category_type = ?"
      values << user.class.to_s
      

      conditions << clausules.join(" AND ")
      conditions.concat( values )
      orders = all(:conditions => conditions,:include => joins,:group => "orders.id")
      orders_paginate = orders.paginate(:page => options[:page], :per_page => options[:rp],:conditions => conditions,:joins => joins,:order => "#{options[:sortname]} #{options[:sortorder]}")
      orders_by_state << {:state => state,:count => orders.size,:paginate => orders_paginate,:total_page => (orders.size.to_f/options[:rp].to_f).ceil,:current_page =>options[:page]  }
    end
		
    orders_by_state
  end

	#
	# Buscador de ordener por term
	#
	def self.search(term,options={})
    options[:sortorder] = options[:sortorder] || "desc"
    options[:sortname] = options[:sortname] || "orders.id"
    options[:rp] = (options[:rp] || 15).to_i
    options[:page] = options[:page] || 1
    options[:qtype] = options[:qtype] || "orders.id"
    options[:query] = options[:query] || ""
    options[:date] ||=Date.today.year

    states = State.all_apply_to_orders
    orders_by_state = []
    joins = [:doc => [:case => [:tracking_states ]],:client => [:contact_category => [:contact]]]

    states.each do |state|
      clausules = []
      values = []
      conditions  = []
      clausules << "tracking_states.state_id = ?"
      values << state.id
      clausules << "tracking_states.actual = ?"
      values << true
			clausules << "orders.canceled = ?"
      values << false
      clausules << "(contacts.identification_document LIKE ?)"
      #values << "#{term}"
      values << "%#{term}"

      conditions << clausules.join(" AND ")
      conditions.concat( values )
      orders = all(:conditions => conditions,:joins => joins,:group => "orders.id")
      orders_paginate = orders.paginate(:page => options[:page], :per_page => options[:rp],:conditions => conditions,:joins => joins,:order => "#{options[:sortname]} #{options[:sortorder]}")
      orders_by_state << {:state => state,:count => orders.size,:paginate => orders_paginate,:total_page => (orders.size.to_f/options[:rp].to_f).ceil,:current_page =>options[:page]  }
    end
    orders_by_state
  end

  #
  # Busca todos las ordenes de un clinete
  #

  def self.all_by_client(client,options={})

    options[:sortorder] = options[:sortorder] || "desc"
    options[:sortname] = options[:sortname] || "orders.id"
    options[:rp] = options[:rp] || 15
    options[:page] = options[:page] || 1
    options[:qtype] = options[:qtype] || "orders.id"
    options[:query] = options[:query] || ""
    options[:date] ||=Date.today.year


    states = State.all_apply_to_orders
    orders_by_state = []
    joins = [:doc => [:case => [:tracking_states]]]

    states.each do |state|
      clausules = []
      values = []
      conditions  = []
      clausules << "orders.client_id = ?"
      values << client.id
      clausules << "tracking_states.state_id = ?"
      values << state.id
      clausules << "tracking_states.actual = ?"
      values << true
      conditions << clausules.join(" AND ")
      conditions.concat( values )
      orders = all(:conditions => conditions,:joins => joins)
      orders_paginate = orders.paginate(:page => options[:page], :per_page => options[:rp],:conditions => conditions,:joins => joins,:order => "#{options[:sortname]} #{options[:sortorder]}")
      orders_by_state << {:state => state,:count => orders.size,:paginate => orders_paginate}
    end
    orders_by_state
  end

  #
  # Optiene el aso asociado al pedido
  #
  def caso
    doc.case
  end

  #
  # Devuelve <tt>true</tt>, si tiene un caso asociado
  #
  def has_case?
    !caso.nil?
  end

  #
  # Verifica si existen otros item de presupeustos completados
  #
  def other_dependents_completed_orders?
    if has_case? and caso.has_budget?
      budget = caso.budget
      docs = Doc.all(:conditions => {:category_id => budget.id,:category_type => Budget.to_s})
      cases = docs.map(&:case)
      cases.delete(caso)
      result = cases.map(&:actual_state).map(&:is_invoicing_state?)
      !result.include?(false)
    else
      false
    end
  end
  #
  # Current status
  #
  def actual_status
    if is_expired?
      EXPIRED
    elsif is_unexpired?
      UNEXPIRED
    else
      WARNING
    end
  end

  #
  # Verifica si la orden esta en status NO VENCIDA
  #

  def is_unexpired?
    days = (delivery_date - Date.today).to_i
    days >= AppConfig.time_order_unexpired
  end

  #
  # Verifica si la orden esta en status VENCIDA
  #

  def is_expired?
    days = (delivery_date - Date.today).to_i
    days <= AppConfig.time_order_expired
  end

  #
  # Verifica si la orden esta en status POR VENCERSE
  #

  def is_warning?
    days = (delivery_date - Date.today).to_i
    days > AppConfig.time_order_expired and days <= AppConfig.time_order_warning
  end

  #
  # Tiempo transcurrido tras ultima modificacion
  #

  def days_after_last_tracking_state
    (DateTime.now - caso.actual_tracking_state_date.to_datetime).to_i
  end
 

  #
  # Crea una notificacion rechanzando el diseño
  #


  def discard_design(notification)
    notification.category = caso
    notification.transmitter = client
    notification.subject = "#{SUBJECT_DISCARD_DESIGN} #{id}"
    notification
  end

  #
  # Crea una notificacion aceptando el diseño
  #


  def accept_design(notification,multimedia_file)
    notification.category = caso
    notification.transmitter = client
    notification.subject = "#{SUBJECT_ACCEPT_DESIGN} #{id}"
    notification.note = "#{NOTE_ACCEPT_DESIGN} #{multimedia_file.name}"
    notification
  end

	#
	# Cerra orden
	#
	def to_close(options={})
			attr_tracking_state = {
        :user_id => options[:user].id,
				:state_id => State.first_final_apply_to_orders.id
      }
			
      options_tracking_state = {
        :user_tracker => options[:user],
        :user_tracker_actual => true
      }
			caso.add_tracking_state(attr_tracking_state, options_tracking_state)
	end


  #
  #
  #
  def  mail_notify
    Mailer::deliver_test
  end

  #
  # Verifica Caso nulos o inavlidos y los elimina
  #
  def self.delete_order_with_invalid_cases
    self.all.each do |order|
      unless order.has_case?
        order.destroy
      end
    end
  end


	#
	# Cerrar ordernes facturadas
	#
	def self.close_all_with_invoice
		options = {
			:user => User.find_by_login("admin")
		}
		Invoice.all(:conditions => ["from_budget_id > ?",0]).each do |invoice|
			invoice.from_budget.orders.each do |item|
					item.to_close(options)
			end
		end
		
	end


	def self.test
		all.each do |order|
			if order.caso and order.caso.budget.product_by_budgets.size > 2
				order.caso.budget.product_by_budgets.each do |product_by_budget|
				
				subject = "#{product_by_budget.quantity} #{product_by_budget.product.name}"
				note = product_by_budget.elements_products_description_inline
				
				if order.caso.subject.eql?(subject) and order.caso.note.eql?(note)
					order.update_attributes(:associate_id => product_by_budget.id,:associate_type => "ProductByBudget")
				end



				end
				#order.update_attributes(:associate_id => order.caso.budget.product_by_budgets.first.id,:associate_type => "ProductByBudget")
			end
		end
		"0"
	end

end
