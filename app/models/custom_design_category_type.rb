class CustomDesignCategoryType < ActiveRecord::Base
	humanize_attributes :name => "Nombre",
											:custom_design_type => "Tipo de diseño"

	belongs_to :custom_design_type

	validates_presence_of :name,:custom_design_type
end