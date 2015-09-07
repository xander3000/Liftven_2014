class Crm::AccountType < ActiveRecord::Base
	def self.table_name_prefix
    'crm_'
  end
end
