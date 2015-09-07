class Tax < ActiveRecord::Base


	#
	# Tax or defecto
	#
	def self.default
		self.find_by_general(true)
	end


	#
	# Tipo de alicuto
	#
	def category_type
		if additional
			"Adicional"
		elsif exempt
			"Exento"
		elsif reduced
			"Reducido"
		else
			"General"
		end
	end
end
