class CashBank::CheckOffered < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	attr_accessor :cash_bank_bank,
								:cash_bank_bank_account

	humanize_attributes		:base => "Cheque contabilizado",
												:cash_bank_bank => "Banco",
												:cash_bank_bank_account => "Cuenta bancaria",
												:cash_bank_check_status_type => "Estatus",
												:reference => "Referencia",
												:amount => "Monto",
												:cash_bank_checkbook => "Chequera asociada",
												:responsible => "Resposable de emision",
												:beneficiary => "Beneficiario",
												:number => "Nro Cheque",
												:date => "Fecha"



	belongs_to :cash_bank_checkbook,:class_name => "CashBank::Checkbook"
	belongs_to :cash_bank_check_status_type,:class_name => "CashBank::CheckStatusType"
	belongs_to :reference,:class_name => "CashBank::BankMovement"
	belongs_to :responsible,:class_name => "User"

	validates_presence_of :cash_bank_checkbook,:cash_bank_check_status_type,:date,:amount,:number
	validate :number_check_belongs_to_checkbook
	#
	# anular cheque
	#
	def cancel
		check = CashBank::CheckOffered.find_by_number(number)
		if check
			update_attribute(:cash_bank_check_status_type_id, CashBank::CheckStatusType.find_by_tag_name("anulado"))
		else
			checkbook = cash_bank_checkbook
			checkbook.register_issued_check_offered(1,0,number,date,"No definido",nil,:status => "anulado")
		end
	end

	#
	# Valida si el numero de chuqte esta asociado a la chequerea
	#
	def number_check_belongs_to_checkbook
		if cash_bank_checkbook
			if !(cash_bank_checkbook.initial_check_number <= number and cash_bank_checkbook.final_check_number >= number)
				errors.add(:number,"no esta registrado en la chequera")
				return false
			end
		end
		true
	end

end
