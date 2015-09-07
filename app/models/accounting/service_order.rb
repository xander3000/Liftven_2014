class Accounting::ServiceOrder < ActiveRecord::Base
  def self.table_name_prefix
    'accounting_'
  end

  attr_accessor :supplier_name

	humanize_attributes		:supplier => "Proveedor",
												:supplier_name => "Proveedor",
												:currency_type => "Moneda",
												:create_by => "Creado por",
												:delivery_date => "Fecha estima de entrega",
												:posting_date => "Contabilización",
												:base => "Pedido"

	belongs_to :supplier
	belongs_to :currency_type
	belongs_to :create_by,:class_name => "User"
	has_many :accounting_service_order_positions,:class_name => "Accounting::ServiceOrderPosition",:foreign_key => "accounting_service_order_id"
  has_one :account_payable_incoming_invoice,:class_name => "AccountPayable::IncomingInvoice",:foreign_key => "accounting_service_order_id"
	validates_presence_of :supplier,
												:currency_type,
												:create_by,
												:posting_date
	alias_method(:accounting_positions, :accounting_service_order_positions)

  


	#
	# Retorna true si fueron agragdos position al purchase
	#
	def has_added_item_positions?(accounting_service_order_positions_added)
		if accounting_service_order_positions_added.empty?
			 errors.add_to_base("debe registrar una posición")
			 false
		end
		true
	end



	#
	# Total del pediro
	#
	def total
		accounting_service_order_positions.map(&:total).sum
	end
	#
	# Total del pediro
	#
	def total_amount
		sub_total_amount*AppConfig.tax_percentage+sub_total_amount
	end
  #

	def tax
		AppConfig.tax
	end

	#
	# valor del impuesto
	#
	def tax_amount
		tax*sub_total_amount/100
	end

	# Total del pediro
	#
	def sub_total_amount
    accounting_service_order_positions.map(&:total).sum
	end

	#
	# Nombre del proveedor
	#
	def supplier_name
		supplier.name if supplier
	end


	#
	# Nombre completo
	#
	def fullname
		"#{id.to_code}  | #{supplier.name} | #{posting_date} | #{total.to_currency(true)}"
	end

	#
	# Nombre del modelo
	#
	def self.model_humanize_name
		"Orden de servicio"
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

end
