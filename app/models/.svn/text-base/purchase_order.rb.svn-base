class PurchaseOrder < ActiveRecord::Base
	 humanize_attributes	:supplier => "Proveedor",
												:currency_type => "Moneda",
												:create_by => "Creado por",
												:delivery_date => "Fecha estima de entrega",
												:posting_date => "Contabilización",
												:base => "Pedido"

	belongs_to :supplier
	belongs_to :currency_type
	belongs_to :create_by,:class_name => "User"
	has_many :purchase_order_positions

	validates_presence_of :supplier,
												:currency_type,
												:create_by,
												:posting_date

	#
	# Retorna true si fueron agragdos position al purchase
	#
	def has_added_item_positions?(purchase_order_positions_added)
		if purchase_order_positions_added.empty?
			 errors.add_to_base("debe seleccionar al menos un material")
			 false
		end
		true
	end

	#
	# Busca el elemnto por el termino
	#
	def self.find_by_autocomplete_term(attr,value,options={})
		options[:contact_categories] ||= Supplier.to_s
    rows = []
    items = all(:conditions => ["lower(#{attr}) LIKE ? AND contact_categories.category_type = ?","#{value}%",options[:contact_categories]],:joins => [:supplier => [:contact_category => :contact]],:limit => 10)
    items.each do |item|
      rows << {
                "value" => item[attr.to_sym],
                "label" => item.fullname,
                "id" => item[:id],
								"supplier_id" => item.supplier.id,
								"supplier_name" => item.supplier.name,
                "code_response" => "ok"
              }
    end
    if items.empty?
      rows = [{
          "value" => value,
          "label" => "Orden de compra no Registrada",
          "code_response" => "no-found"
          }]
    end
    JSON.generate(rows)
	end


	#
	# Total del pediro
	#
	def total
		purchase_order_positions.map(&:total).sum
	end

	#
	# Nombre completo
	#
	def fullname
		"#{id.to_code}  | #{supplier.name} | #{posting_date} | #{total.to_currency(true)}"
	end

end
