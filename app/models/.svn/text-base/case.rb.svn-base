class Case < ActiveRecord::Base
  has_many  :comments,:as => :category, :order =>"created_at DESC", :dependent => :destroy
  has_many  :notifications,:as => :category, :order =>"created_at DESC", :dependent => :destroy
  has_many  :docs
  has_many  :tracking_states,:as => :proxy, :order =>"created_at DESC",:dependent => :destroy



  validates_presence_of :subject, :note

  #
  # Crea un nuevo caso
  #
  def self.guardar(attr,options={})
    object = new(attr)
    success = object.valid?
    if success
      object.save
      attr_tracking_state = {
        :user_id => options[:user].id
      }
      options_tracking_state = {
        :user_tracker => User.first_lower_load,
        :user_tracker_actual => true
      }
      options_tracking_state = options_tracking_state.merge(options)
      case options[:doc]
        when Order.to_s
          state = State.first_apply_to_orders
          attr_tracking_state[:state_id] = state.id
          success = object.add_tracking_state(attr_tracking_state,options_tracking_state)
          unless success
            object.destroy
          end
      end
    end
    {:success => success,:object => object}
  end

  #
  # Busca todos las ordenes por usuario
  #
  def self.all_by_user_and_states(user,options={})

    options[:sortorder] = options[:sortorder] || "desc"
    options[:sortname] = options[:sortname] || "cases.id"
    options[:rp] = options[:rp] || 15
    options[:page] = options[:page] || 1
    options[:qtype] = options[:qtype] || "cases.id"
    options[:query] = options[:query] || ""
    options[:date] ||=Date.today.year


   # states = user.all_actives_apply_to_orders_by_user_groups

    ## State.all_actives_apply_to_orders
    cases_by_state = []
    joins = []

    #states.each do |state|
      clausules = []
      values = []
      conditions  = []

      conditions << clausules.join(" AND ")
      conditions.concat( values )
      cases = all(:conditions => conditions,:joins => joins,:group => "cases.id",:limit => options[:rp])
      cases_paginate = cases.paginate(:page => options[:page], :per_page => options[:rp],:conditions => conditions,:joins => joins,:order => "#{options[:sortname]} #{options[:sortorder]}")
      cases_by_state << {:count => options[:rp],:paginate => cases_paginate}
    #end

    cases_by_state
  end

	#
	# Documentos asociados
	#
	def all_docs_by_category
		categories = docs.map(&:category_type).uniq
		docs_by_category = []
		categories.each do |category|
			clausules = []
      values = []
      conditions  = []

			clausules << "docs.category_type = ?"
			values << category
			conditions << clausules.join(" AND ")
      conditions.concat( values )
			objects = docs.all(:conditions => conditions,:group => "docs.id")
			docs_by_category << {:count => objects.size,:category => category,:docs => objects}
		end
		docs_by_category
	end

  #
  # Agregar un tracking
  #
  def add_tracking_state(attr,options={})
      object = TrackingState.new(attr)
      success = object.valid?

      if success
        object.proxy = self
        object.save
        ## Agregar los trackers
        #TODO: validar para varios tracker

        attr_tracker = {
          :category_id => options[:user_tracker].id,
          :category_type => options[:user_tracker].class.to_s,
          :actual => options[:user_tracker_actual]
        }
        object.add_user_tracker(attr_tracker)

        User.find_all_additionals_for_orders.each do  |user|
          attr_tracker = {
            :category_id => user.id,
            :category_type => user.class.to_s,
            :actual => false
          }
          object.add_user_tracker(attr_tracker)
        end
      end
      success
  end

  #
  # Obtener los seguidores actuales
  #
  def actual_trackers(category=true)
    trackers = actual_tracking_state.trackers.all(:conditions => {:actual => true})
    if category
      trackers.map(&:category).map(&:name)
    else
      trackers
    end

  end

  #
  # Obtener el seguidor actual
  #
  def actual_tracker(category=true)
    tracker = actual_tracking_state.trackers.first(:conditions => {:actual => true})
    if category
      tracker.category.name
    else
      tracker
    end

  end


  #
  # Obtener el ultimo tracking estado actual
  #
  def actual_tracking_state
    tracking_states.first(:conditions => {:actual => true})
  end
  
  #
  # Obtener la fecha del ultimo tracking estado actual
  #
  def actual_tracking_state_date
    actual_tracking_state.updated_at
  end


  #
  # Obtener el ultimo estado actual
  #
  def actual_state
    actual_tracking_state.state
  end

  #
  # Verifica si tiene un presupuesto asociado
  #
  def has_budget?
    !docs.first(:conditions => {:category_type => Budget.to_s}).nil?
  end

  #
  # Returna el presupuesto asociado
  #
  def budget
    return nil unless has_budget?
      docs.first(:conditions => {:category_type => Budget.to_s}).category
  end


  #
  # Verifica si tiene un tarjeta digital asociada
  #
  def has_digital_card?
    !docs.first(:conditions => {:category_type => DigitalCard.to_s}).nil?
  end


  #
  # Returna la tarjeta digital asociada
  #
  def digital_card
    return nil unless has_digital_card?
      docs.first(:conditions => {:category_type => DigitalCard.to_s}).category
  end


  #
  # Verifica si tiene un presupuesto asociado
  #
  def has_order?
    !docs.first(:conditions => {:category_type => Order.to_s}).nil?
  end

  #
  # Returna el presupuesto asociado
  #
  def order
    return nil unless has_order?
      docs.first(:conditions => {:category_type => Order.to_s}).category
  end

  #
  # Verifica si tiene un diseño asociado
  #
  def has_design?
    !docs.first(:conditions => {:category_type => Design.to_s}).nil?
  end

  #
  # Returna el diseño asociado
  #
  def design
    return nil unless has_design?
      docs.first(:conditions => {:category_type => Design.to_s}).category
  end

  #
  # Verifica si tiene un factura asociada
  #
  def has_invoice?
    result = false
    if has_budget?
      result = budget.has_invoice?
    end
    result
  end

  #
  # Returna el factura asociada
  #
  def invoice
    return nil unless has_invoice?
      budget.invoice
  end



  #
  # Verifica si se puede generar un diseño
  #
  def can_generate_new_diseno?
    actual_state.name.eql?(State::DISENO) and !has_design?
  end



  #
  # Verifica si se puede geenrar la factura
  #
  def can_generate_new_factura?
    actual_state.name.eql?(State::FACTURACION) and order.other_dependents_completed_orders? and !has_invoice?
  end

  #
  # Tiene nuevas notificaciones sin leer
  #
  def has_new_notifications?
    notifications.map(& :read).include?(false)
  end


  ####ESTADO

  #
  # Verifica si el estado actual es de diseño
  #
  def is_state_diseno?
    actual_state.name.eql?(State::DISENO)
  end

  #
  # Verifica si el estado actual es de facturar
  #
  def is_state_facturacion?
    actual_state.name.eql?(State::FACTURACION)
  end

end
