class Accounting::TransactionMovementAccountingConcept < ActiveRecord::Base
	def self.table_name_prefix
    'accounting_'
  end

	humanize_attributes		:date => "Fecha"

belongs_to :accounting_accountant_account,:class_name => "Accounting::AccountantAccount"
belongs_to :create_by,:class_name => "User"
belongs_to :reference_document,:polymorphic => true


	validates_presence_of :accounting_accountant_account,:create_by,:date



	#
	# Busqueda de registros por critrrios
	#
	def self.find_by_criterion(options={})
			clausules = []
      values = []
      conditions  = []

		clausules << "accounting_accountant_account_id = ?"

		if !options[:accountant_account_id].eql?("")
			values << options[:accountant_account_id]
		else
			values << "-1"
		end

		if !options[:date_from].eql?("")
			clausules << "date >= ?"
			values << options[:date_from]
		end

		if !options[:date_to].eql?("")
			clausules << "date <= ?"
			values << options[:date_to]
		end
		conditions << clausules.join(" AND ")
		conditions.concat( values )
		all(:conditions => conditions,:order => "date asc")
	end

end
