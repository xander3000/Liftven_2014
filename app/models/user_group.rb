class UserGroup < ActiveRecord::Base

#  SUPERVISOR = "supervisor"
#  DESIGNER = "designer"
#  PRINTER = "printer"
#  BILLER = "biller"
#  CONFIGURATOR = "configurator"

	ADMINISTRATOR = "Administrators"
  DIRECTOR = "Administrators"
  ANALISTA_ADMINISTRATIVO = "analista_administrativo"
  ASISTENTE_ADMINISTRATIVO = "asistente_administrativo"
  ASISTENTE_COMERCIAL = "asistente_comercial"
  SUPERVISOR_COMERCIAL = "supervisor_comercial"
  DISENADOR = "disenador"
  TECNICO_GRAFICO = "tecnico_grafico"






  has_many :state_by_user_groups
  has_many :states,:through => :state_by_user_groups
  has_many :states_to_order,:through => :state_by_user_groups, :source => :state,:conditions => {:apply_to => Order.to_s},:order => "sequence ASC"
  has_many :active_states_to_order,:through => :state_by_user_groups, :source => :state,:conditions => {:apply_to => Order.to_s,:final => false},:order => "sequence ASC"
  has_and_belongs_to_many :permissions
  has_and_belongs_to_many :users

  validates_presence_of :name

	def all_users
		User.find_by_sql <<-SQL
			select users.*
			from users, user_groups_users
			where users.id = user_groups_users.user_id
			and user_groups_users.user_group_id = #{self.id}
    SQL
	end


  #
  # Valida si el grupo posee el state asociado
  #
  def has_state?(state)
    all_actives_apply_to_orders.include?(state)
  end

  #
  # Estados activos para ordenes
  #
  def all_actives_apply_to_orders
   active_states_to_order.flatten.uniq
  end


  #
  # Grupo de usuarios para ordenes
  #
  def self.all_for_orders
    [DISENADOR]#[DISENADOR,TECNICO_GRAFICO,ASISTENTE_ADMINISTRATIVO,ASISTENTE_COMERCIAL,SUPERVISOR_COMERCIAL]
  end

  #
  # Grupo de usuarios para ordenes
  #
  def self.all_checker
    [ADMINISTRATOR,ASISTENTE_ADMINISTRATIVO,ANALISTA_ADMINISTRATIVO]#[DISENADOR,TECNICO_GRAFICO,ASISTENTE_ADMINISTRATIVO,ASISTENTE_COMERCIAL,SUPERVISOR_COMERCIAL]
  end

  #
  # Grupo de usuarios tecnicos
  #
  def self.all_technicals
    [DISENADOR,TECNICO_GRAFICO]
  end


  #
  # Grupo de usuarios adicionales para el seguimiento  de las ordenes
  #
  def self.all_additionals_for_orders
   [DIRECTOR,ASISTENTE_COMERCIAL,SUPERVISOR_COMERCIAL]#[DIRECTOR,ANALISTA_ADMINISTRATIVO,ASISTENTE_ADMINISTRATIVO,ASISTENTE_COMERCIAL,SUPERVISOR_COMERCIAL]
  end

  #
  # Grupo de suuarios directores
  #
  def self.all_directors
    [DIRECTOR]
  end

end
