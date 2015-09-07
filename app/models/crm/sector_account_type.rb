class Crm::SectorAccountType < ActiveRecord::Base
	def self.table_name_prefix
    'crm_'
  end
end
