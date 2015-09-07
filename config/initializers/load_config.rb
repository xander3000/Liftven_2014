#Cargador de la configuracion del sitio
if File.exist?("#{RAILS_ROOT}/config/config.yml")
  c = YAML::load(File.open("#{RAILS_ROOT}/config/config.yml"))
else
  c = YAML::load(File.open("#{RAILS_ROOT}/config/config_draft.yml"))
end

#configuracion de correo
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default_url_options = { :host => 'localhost:3000' }
ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => c[RAILS_ENV]['email']['smtp_tls'] || false,
  :address => c[RAILS_ENV]['email']['address'] || c[RAILS_ENV]['email']['server'],
  :port => c[RAILS_ENV]['email']['port'],
  :domain => c[RAILS_ENV]['email']['domain'],
  :authentication => c[RAILS_ENV]['email']['authentication'],
  :user_name => c[RAILS_ENV]['email']['username'],
  :password => c[RAILS_ENV]['email']['password'],
  :tls => c[RAILS_ENV]['email']['smtp_tls'] || false,
}
ActionMailer::Base.perform_deliveries = :true
ActionMailer::Base.raise_delivery_errors = :true
ActionMailer::Base.default_charset = "utf-8"
CONTACT_RECIPIENT = c[RAILS_ENV]['email']['contact_recipient']
CONTACT_REPLY_TO = c[RAILS_ENV]['email']['contact_reply_to']

#configuracion del proyecto
PROJECT_NAME = c[RAILS_ENV]['project']['name']

#configuracion de sitio
SITE_NAME = c[RAILS_ENV]['site']['name']
#SITE_LOCALE = c[RAILS_ENV]['site']['locale']

#configuracion LDAP
#LDAP_HOST = c[RAILS_ENV]['ldap']['host']
#LDAP_PORT = c[RAILS_ENV]['ldap']['port']
#LDAP_BASE = c[RAILS_ENV]['ldap']['base']
#LDAP_SSL = c[RAILS_ENV]['ldap']['ssl']
#LDAP_admin_user: cn=admin,dc=mydomain
#LDAP_admin_password: password

#configuracion del la compañia
COMPANY_NAME = c[RAILS_ENV]['company']['name']
COMPANY_URL = c[RAILS_ENV]['company']['url']
COMPANY_PHONE = c[RAILS_ENV]['company']['phone']
COMPANY_EMAIL = c[RAILS_ENV]['company']['email']
COMPANY_IDENTIFICATION_DOCUMENT = c[RAILS_ENV]['company']['identification_document']

#Configuracion dela impresora
PRINTER_HOST = c[RAILS_ENV]['printer']['host']
PRINTER_PORT = c[RAILS_ENV]['printer']['port']
#Crear link simbolicos
#system "ln -s #{RAILS_ROOT}/lib/platforms/v#{c[RAILS_ENV]['platform']['version']}/rails #{RAILS_ROOT}/app/controllers/platform" unless File.exist?("#{RAILS_ROOT}/app/controllers/platform")
#system "ln -s #{RAILS_ROOT}/lib/platforms/v#{c[RAILS_ENV]['platform']['version']}/rails #{RAILS_ROOT}/app/views/platform" unless File.exist?("#{RAILS_ROOT}/app/views/platform")
#system "ln -s #{RAILS_ROOT}/lib/platforms/v#{c[RAILS_ENV]['platform']['version']}/assets #{RAILS_ROOT}/public/assets" unless File.exist?("#{RAILS_ROOT}/public/assets")
system "ln -fs #{RAILS_ROOT}/public/stylesheets/fonts/* ~/.fonts; fc-cache"


#load "#{RAILS_ROOT}/app/controllers/platform/base.rb"