class Payroll::Position < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end


	humanize_attributes		:name => "Nombre",
												:full_name => "Nombre completo",
												:payroll_position_type => "Tipo de cargo"

	belongs_to :payroll_position_type,:class_name => "Payroll::PositionType"


	validates_presence_of :name,:full_name, :payroll_position_type

	validates_uniqueness_of :name,:scope => [:payroll_position_type_id]
end
