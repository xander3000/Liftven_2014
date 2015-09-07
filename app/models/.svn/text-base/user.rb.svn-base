class User < ActiveRecord::Base

  acts_as_authentic

  humanize_attributes :login => "Usuario",
                      :password => "Clave",
                      :password_confirmation => "Confirmación",
											:last_login_at => "Ultimo fecha de ingreso",
											:last_login_ip => "Ultima dirección de acceso",
											:user_groups => "Perfil",
											:active => "¿Activo?",
											:name => "Nombre"

	has_attached_file :avatar, :styles => { :thumb => ["80x80#", :png]},
                    :url  => "/uploads/users/:attachment/:id/:style/:filename",
                    :path => ":rails_root/public:url"

 
	has_one  :contact_category,:as => :category
	has_many :assignments
  has_many :roles, :through => :assignments
	has_many :tracking_states
  has_and_belongs_to_many :user_groups
	has_and_belongs_to_many :security_roles,:class_name => "Security::Role",:association_foreign_key =>  "security_role_id",:join_table => "security_roles_users"
  #belongs_to :contact
	has_one :cash_bank_cash,:class_name => "CashBank::Cash",:foreign_key => "responsible_id"
  #validates_presence_of :login,:password,:password_confirmation
	#validates_uniqueness_of :login



  #
  # Retorna el nombre del contacto
  #
  def name
    contact.name
  end

	#
  # Retorna el primer nombre del contacto
  #
  def first_name
    contact.first_name
  end

  #
  # Retorna la informacion de contacto del cliente
  #
  def contact
    contact_category.contact
  end

	#
	# Verifica si un usuario tiene un grupo en partiuclar
	#
	def user_has_user_group?(user_group)
		user_groups.map(&:name).include?(user_group)
	end

	#
	# Verifica si un usuario tiene un rol an aprticular
	#
	def user_has_role?(role)
		security_roles.map(&:tag_name).include?(role)
	end


  #
  # Verifica si el usuario actual es adminitrador
  #
  def is_administrator?
		user_has_user_group?(UserGroup::ADMINISTRATOR) or user_has_role?(Security::Role::ADMINISTRATOR)
  end


	#
	##
	#
	def has_avatar?
		!avatar_file_name.empty?
	end
	#
	#
	def has_action_for_controller_by_role?(controller_module,action)
		roles_id = security_roles.map(&:id)
		permission = Security::Permission.first(:conditions =>["security_role_id IN (?) AND config_panel_submodules.controller_module = ?",roles_id,controller_module],:include => :config_panel_submodule)
		if permission
			permission.action_name.split(",").map(&:strip).include?(action)
		else
			false
		end
	end

	#
	# Verifica si teine el rol indicado
	#
	def has_role?(role_sym)
		roles.any? { |r| r.name.underscore.to_sym == role_sym }
	end

	 # The necessary method for the plugin to find out about the role symbols
	# Roles returns e.g. [:admin]
	def role_symbols
	@role_symbols ||= (roles || []).map {|r| r.to_sym}
	end
	# End of declarative_authorization code


  #
  # Verifica si un usuario pertenece a un grupo en particular
  #
  def belogns_to_user_group?(user_groups_name)
    return true if is_administrator?
    user_groups_name = [user_groups_name] unless user_groups_name
    user_groups_name.each do |user_group|
			#TODO: CAMBIAR LOCKDOWN
      return true if user_has_user_group?(user_group)
    end
    false
  end

  #
  # Valida si para los grupos asociados posee el state
  #
  def has_state_apply_to_orders_by_user_groups?(state)
    all_actives_apply_to_orders_by_user_groups.include?(state)
  end

  #
  # Estados activos para ordenes pro grupo de usuarios asignados
  #
  def all_actives_apply_to_orders_by_user_groups
    user_groups.map(&:active_states_to_order).flatten.uniq
  end

  #
  # Verifica si el usuario tiene asociado en su UserGroup el  persmission actual
  #
  def has_permission?(permission_name)
    return true if is_administrator?
    permission = Permission.find_by_name(permission_name)
    user_groups.map(&:permissions).flatten.include?(permission)
  end

	#
	# Valida si el cajero tiene caja asociada
	#
	def has_associate_cash?
		cash_bank_cash ? true : false
	end

	#
	#
	#
	def active?
		active
	end

	#
	# Lista de submodulos asigando po modulo
	#
	def cpanel_submodules
		cpanel_modules = []
		ConfigPanel::Module.all_cpanel.each do |cpanel|
			submodules = (is_administrator? ? cpanel.active_config_panel_submodules : ConfigPanel::Submodule.all(:conditions => ["config_panel_submodules.config_panel_module_id = ? AND users.id = ?",cpanel.id,id],:include => [:security_permissions => [:security_role => :users]]))
			cpanel_modules << {:module => cpanel,:submodules => submodules.uniq}
		end
		cpanel_modules
	end

  #
  # Busca el usuario quye posea el state actual y sea principal en su defecto el primero que consiga
  #
  def self.first_with_state_by_user_groups(state)
    user_selected = nil
    state_by_user_group = StateByUserGroup.first(:conditions => {:state_id => state.id,:principal => true})
    if state_by_user_group
      users = state_by_user_group.user_group.users.flatten
      r = rand(users.size)
      user_selected = users[r]
    end
    if not user_selected
      state_by_user_groups = StateByUserGroup.all(:conditions => {:state_id => state.id})
      user_groups = state_by_user_groups.map(&:user_group)
      users = user_groups.map(&:users).flatten
      r = rand(users.size)
      user_selected = users[r]
    end
    user_selected
  end

  #
  # Usuario o empleado con menor carga laboral para una orden
  #

  def self.first_lower_load
    users = {}
    find_all_for_orders.each do |user|
      orders = Order.count_by_user_for_selection(user)
      users[user.id.to_s] = orders
    end
    users = users.sort {|a,b| a[1] <=> b[1]}
    users.first ? find(users.first.first) : nil
  end


  #
  # Seguidores por ordenes de estado (States)
  #

  def self.find_all_by_order_states
    users = []
    find_all_for_orders.each do |user|
      users << {:user => user,:orders => Order.all_by_user_and_states(user)}
    end
    users
  end


  #
  # Seguidores por ordenes de estado activos (States)
  #

  def self.find_all_by_active_order_states(states = State.all_actives_apply_to_orders_with_presence)
    users = []
    find_all_for_active_orders.each do |user|
      users << {:user => user,:orders => Order.all_by_active_user_and_states(user,:state => states)}
    end
    users
  end

	#
  # Seguidores por status de ordenes activas (no vencidas, por vencerse, vencidas)
  #

  def self.find_all_by_active_order_status(states = State.all_actives_apply_to_orders_with_presence)
    users = []
		#states = State.all_actives_apply_to_orders_with_presence
    find_all_for_active_orders.each do |user|
			orders = Order.all_by_user(user,:state => states)
      users << {:user => user,:orders => {:unexpired => Order.all_unexpired_by_user(user,:state => states,:orders => orders),:expired => Order.all_expired_by_user(user,:state => states,:orders => orders),:warning => Order.all_warning_by_user(user,:state => states,:orders => orders)}}
    end
    users
  end

  #
  # Seguidores por status de ordenes (no vencidas, por vencerse, vencidas)
  #

  def self.find_all_by_order_status
    users = []
    find_all_for_orders.each do |user|
      users << {:user => user,:orders => {:unexpired => Order.all_unexpired_by_user(user),:expired => Order.all_expired_by_user(user),:warning => Order.all_warning_by_user(user)}}
    end
    users
  end
	


  #
  # Seguidores adicionales para las ordenes
  #

  def self.find_all_additionals_for_orders
    find_all_by_user_groups(UserGroup.all_additionals_for_orders)
  end

  #
  # Seguidores para los ordenes de produccion o pedidos
  #
  def self.find_all_for_orders
    find_all_by_user_groups(UserGroup.all_for_orders)
  end

	#
  # Seguidores para los ordenes de produccion o pedidos activos
  #
	def self.find_all_for_active_orders
		find_all_by_active_tracking_states
	end

  #
  # Seguidores para los ordenes de produccion o pedidos
  #
  def self.find_all_for_orders_technicals
    find_all_by_user_groups(UserGroup.all_technicals)
  end

  #
  # Seguidores por Grupo de usuarios
  #
  def self.find_all_by_user_groups(user_groups_name)
    all(:conditions => ["user_groups.name IN (?) AND active = ?",user_groups_name,true],:include => :user_groups)
  end

	#
	# Seguidores por tracking activos
	#
	def self.find_all_by_active_tracking_states
		TrackingState.all(:select => "tracking_states.id",:conditions => ["tracking_states.actual = ? and trackers.actual = ? AND trackers.category_type = ? AND users.active = ?",true,true,User.to_s,true],:joins => [:trackers => :user],:group => "tracking_states.id").map(&:actual_tracker).map(&:category).uniq#.delete_if { |item| item.active? }
		#all(:conditions => ["tracking_states.actual = ? and trackers.actual = ?",true,true],:joins => [:tracking_states => :trackers],:group => "users.id")
	end

	#
	# USuarios con perfil de resposibilidad en Caja
	#

	def self.all_checker_responsibles
		all(:conditions => ["user_groups.name IN (?) AND active = ?",UserGroup.all_checker,true],:include => :user_groups)
	end

  #
  # Numero de Ordenes asiganadas
  #
  def assigned_orders
    Order.count_by_user_for_selection(self)
  end


end
