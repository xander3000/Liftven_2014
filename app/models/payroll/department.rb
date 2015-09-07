class Payroll::Department < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end

	humanize_attributes		:name => "Nombre",
												:tag_name => "Código"

	
	validates_presence_of :name,:tag_name

	validates_uniqueness_of :tag_name
end
