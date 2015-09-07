class FinishedProductCategoryType < ActiveRecord::Base
  has_many :finished_products
  has_many :products


	#
	# Verifica si tiene un producto asociados
	#
	def has_products?
		!products.empty?
	end
end