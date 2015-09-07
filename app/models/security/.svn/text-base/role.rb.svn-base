class Security::Role < ActiveRecord::Base
  def self.table_name_prefix
    'security_'
  end

	ADMINISTRATOR = "administrator"
  DIRECTOR = "Administrators"
  ANALISTA_ADMINISTRATIVO = "analista_administrativo"
  ASISTENTE_ADMINISTRATIVO = "asistente_administrativo"
  ASISTENTE_COMERCIAL = "asistente_comercial"
  SUPERVISOR_COMERCIAL = "supervisor_comercial"
  DISENADOR = "disenador"
  TECNICO_GRAFICO = "tecnico_grafico"


  humanize_attributes		:name => "Nombre",
                        :tag_name => "Etiqueta",
                        :note => "Descripción"

  validates_presence_of :name,:tag_name,:note
  validates_uniqueness_of :name,:tag_name

  has_many :security_permissions,:class_name => "Security::Permission",:foreign_key => "security_role_id"
	has_and_belongs_to_many :users,:join_table => "security_roles_users",:association_foreign_key =>  "user_id",:foreign_key => "security_role_id"


	
end
