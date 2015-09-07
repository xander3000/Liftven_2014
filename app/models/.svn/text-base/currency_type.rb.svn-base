class CurrencyType < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name


	#
	# Modeda por defecto
	#
	def self.default
		find_by_iso4217(AppConfig.currency)

	end
end
