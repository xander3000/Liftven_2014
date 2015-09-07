class CreditNoteEntry < ActiveRecord::Base
	belongs_to :incoming_invoice


	#
	# Busca el elemnto por el termino
	#
	def self.find_by_autocomplete_term(attr,value,options={})
		options[:contact_categories] ||= Supplier.to_s
    rows = []
    items = all(:conditions => ["lower(#{attr}) LIKE ? AND contact_categories.category_type = ?","#{value}%",options[:contact_categories]],:joins => [:incoming_invoice => [:supplier => [:contact_category => :contact]]],:limit => 10)#all(:conditions => ["lower(#{attr}) LIKE ? AND contact_categories.category_type = ?","#{value}%",options[:contact_categories]],:joins => [:supplier => [:contact_category => :contact]],:limit => 10)
						
    items.each do |item|
      rows << {
                "value" => item[attr.to_sym],
                "label" => item.fullname,
                "id" => item[:id],
								"supplier_id" => item.incoming_invoice.supplier.id,
								"supplier_name" => item.incoming_invoice.supplier.name,
                "code_response" => "ok"
              }
    end
    if items.empty?
      rows = [{
          "value" => value,
          "label" => "Nota de Credito no Registrada",
          "code_response" => "no-found"
          }]
    end
    JSON.generate(rows)
	end

	#
	# Nombre completo
	#
	def fullname
		"#{id.to_code} #{supplier.name} (Ref: #{reference},Nº Ctrl: #{control_number})"
	end

	#
	# Obtener suppplier
	#
	def supplier
		incoming_invoice.supplier
	end
end
