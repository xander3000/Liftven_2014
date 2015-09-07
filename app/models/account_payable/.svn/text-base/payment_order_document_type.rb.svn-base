class AccountPayable::PaymentOrderDocumentType < ActiveRecord::Base
	def self.table_name_prefix
    'account_payable_'
  end

	NONE = "None"
	INCOMING_INVOICE = "incoming_invoice"

	named_scope :all_by_tag_name, lambda { |tag_name|  { :conditions => { :tag_name => tag_name } }    }

	#
	# Nombrte (id-tag)
	#
	def fullname
		"#{id.to_code("02")}-#{tag_name}"
	end

  #
  # Requiere documnto
  #
  def require_doc
    !model_relationship.eql?(NONE)
  end
end
