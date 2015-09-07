class Accounting::ReceivableAccount < ActiveRecord::Base
	def self.table_name_prefix
    'accounting_'
  end
	humanize_attributes		:doc => "Documento",
												:client => "Cliente",
												:payment_method_type => "Forma de pago",
												:date_doc => "Fecha documento",
												:date_doc_expiration => "Fecha de expiración",
												:note => "Descripción",
												:sub_total => "Base imponible",
												:tax => "Impuesto",
												:total => "Total",
												:paid => "Abonado",
												:balance => "Balance",
												:cashed => "¿Cobrado?"


	belongs_to :payment_method_type
	belongs_to :doc,:polymorphic => true
	belongs_to :client

	validates_presence_of :doc,:client,:date_doc,:date_doc_expiration,:sub_total,:tax,:total

	named_scope :all_not_cashed, :conditions => {:cashed => false,:canceled => false}

	after_create :set_value_date_doc_expiration


	#
	# Codigo
	#
	def code
		"CC-"+"%05d" % id
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
	def self.all_not_cashed_by_client
		all(:select => "client_id",:conditions => ["cashed = ? AND canceled = ? ", false, false],:group => "client_id")
	end
	

end
