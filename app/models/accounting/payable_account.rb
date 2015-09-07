class Accounting::PayableAccount < ActiveRecord::Base
	def self.table_name_prefix
    'accounting_'
  end
	humanize_attributes		:doc => "Documento",
												:tenderer => "Beneficiario/Proveedor",
												:date_doc => "Fecha documento",
												:date_doc_expiration => "Fecha de expiración",
												:note => "Descripción",
												:reference => "N° Factura",
												:control_number => "Número de control",
												:sub_total => "Base imponible",
												:tax => "Impuesto",
												:total => "Total",
												:paid => "Abonado",
												:balance => "Balance",
												:cashed => "¿Cobrado?"


	
	belongs_to :doc,:polymorphic => true
	belongs_to :tenderer,:polymorphic => true

	named_scope :all_not_cashed, :conditions => {:cashed => false,:canceled => false}


	#after_create :set_value_date_doc_expiration


	#
	# Codigo
	#
	def code
		"CP-"+"%05d" % id
	end

	#
	# Setear fecha de expiracion segun forma de pago
	#
	def set_value_date_doc_expiration
		if payment_method_type
			expiration = date_doc.to_date + payment_method_type.expiration_days
    else
      expiration = date_doc.to_date unless date_doc_expiration
		end
    update_attribute(:date_doc_expiration,expiration)
	end

	#
	# Tiene orden de pago
	#
	def has_payment_order?
		doc.account_payable_payment_order ? true : false
	end

  #
  #
  #
  def semaphore_time_to_expiration
    expiration = date_doc_expiration.to_date - Time.now.to_date
      if expiration < 0
        "red"
      elsif expiration == 0
        "orange"
      else expiration > 0
         "green"
    end
  end

	#
	# Dias para expirar
	#
	def expiration_days(to_words=false)
		expiration =  (date_doc_expiration.to_date - Time.now.to_date).to_i
		if to_words
			expiration > 0 ? "<span>#{expiration} días plazo</span>" : "<span class='red'>#{expiration.abs} días venc.</span>"
		else
			expiration
		end
	end



	#
	# Cuentas por pagar agrupadas por cliente
	#
	def self.all_not_cashed_by_tenderer(options={})
		options[:cashed] ||= false
		options[:canceled]  ||= false
		all(:select => "tenderer_id,tenderer_type",:conditions => ["cashed = ? AND canceled = ?", options[:cashed], options[:canceled]],:group => "tenderer_id,tenderer_type")
	end
	
end
