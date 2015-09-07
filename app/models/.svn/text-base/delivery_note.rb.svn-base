class DeliveryNote < ActiveRecord::Base
	humanize_attributes :quantity => "Cantidad",
											:note => "Observación"

	validates_presence_of :quantity
	validate :quantity_maximun_allow

	after_create :associate_case

	belongs_to :order

	#
	# Obtiene el mas id presente en la BD
	#
	def code
     max = self.class.maximum("id")
    ((max ? max : 0) + 1)
  end

	#
	# Validador que verifica la maxima cantidad permitida para la nota de entrega
	#
	def quantity_maximun_allow
		return true if !order.product_by_budget
		if order.product_by_budget.quantity < quantity.to_i
			errors.add(:quantity, "no puede ser mayor a la cantidad presupuestada (#{order.product_by_budget.quantity} items)")
			false
		end
		true
	end

	#
	# Asocia la nota de entrega a al orden
	#
	def associate_case
		 object_doc = Doc.new
		 object_doc.case = order.caso
		 object_doc.category = self
		 object_doc.save
	end
end
