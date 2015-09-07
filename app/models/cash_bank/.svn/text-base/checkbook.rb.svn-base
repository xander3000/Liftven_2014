class CashBank::Checkbook < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	attr_accessor :cash_bank_bank

	humanize_attributes		:base => "Chequera",
												:cash_bank_bank => "Banco",
												:cash_bank_bank_account => "Cuenta Bancaria asociada",
												:initial_check_number => "Ultimos 6 números primer cheque",
												:final_check_number => "Ultimos 6 números ultimo cheque"

	has_many :cash_bank_check_offereds,:class_name => "CashBank::CheckOffered",:foreign_key => "cash_bank_checkbook_id"
	belongs_to :cash_bank_bank_account,:class_name => " CashBank::BankAccount"
	#belongs_to :cash_bank_bank,:class_name => " CashBank::Bank"

	validates_presence_of :cash_bank_bank_account,
												:initial_check_number,
												:final_check_number

	validates_numericality_of :initial_check_number,:final_check_number,:only_integer => true
	validates_uniqueness_of :initial_check_number,:final_check_number, :scope => [:cash_bank_bank_account_id]
	validate :initial_check_number_minor_than_final_check_number,:allow_blank => true


	#
	# Siguiente numero de cheuque
	#
	def next_check_number
		maximum = cash_bank_check_offereds.maximum("number")
		(maximum ? maximum+1 : initial_check_number).to_s
	end
	
	#
	# Emitir cheuqe
	#
	def register_issued_check_offered(resposible,amount,number,date,beneficiary,reference=nil,options={:status => "emitido"})
		check_offered = CashBank::CheckOffered.new
		check_offered.cash_bank_check_status_type = CashBank::CheckStatusType.find_by_tag_name(options[:status])
		check_offered.responsible_id = resposible
		check_offered.number = number
		check_offered.amount = amount
		check_offered.date = date
		check_offered.reference = reference
		check_offered.beneficiary = beneficiary
		self.cash_bank_check_offereds << check_offered
		check_offered.save
	end



	#
	# Validar que le numero de chque inical sea menor al final
	#
	def initial_check_number_minor_than_final_check_number
		if initial_check_number.to_i >= final_check_number.to_i
			errors.add(:initial_check_number,"debe ser menor al número de cheque final")
			return false
		end
		true
	end

	#
	# Nombre completo
	#
	def full_name
		"#{initial_check_number} - #{final_check_number}"
	end

end
