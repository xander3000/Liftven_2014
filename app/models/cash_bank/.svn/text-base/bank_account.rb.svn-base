	class CashBank::BankAccount < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	attr_accessor :accounting_accountant_account_name

	humanize_attributes		:base => "Cuenta bancaria",
												:cash_bank_bank => "Banco",
												:bank_account_type => "Tipo de cuenta",
												:accounting_accountant_account => "Cuenta contable asociada",
												:accounting_accountant_account_name => "Cuenta contable asociada",
												:cash_bank_checkbook => "Chequera asociada",
												:name => "Nombre",
												:number => "Número de cuenta",
												:open_date => "Fecha de inicio",
												:initial_balance => "Saldo inicial",
												:current_balance => "Saldo actual",
												:used_checkbook => "Usa chequera para el manejo de movimientos",
												:deferred_balance => "Saldo diferido"


	has_many	 :cash_bank_checkbooks,:class_name => "CashBank::Checkbook",:foreign_key => "cash_bank_bank_account_id",:conditions => "active = true"
	has_many	 :cash_bank_bank_movements,:class_name => "CashBank::BankMovement",:foreign_key => "cash_bank_bank_account_id",:order => "date ASC"
	belongs_to :cash_bank_bank,:class_name => "CashBank::Bank"
	belongs_to :bank_account_type,:class_name => "CashBank::BankAccountType"
	belongs_to :accounting_accountant_account,:class_name => "Accounting::AccountantAccount",:conditions =>  ["parent_account_id != 0"]
	#has_one :cash_bank_checkbook,:class_name => "CashBank::Checkbook",:foreign_key => "cash_bank_bank_account_id",:conditions => "active = true"


	validates_presence_of :cash_bank_bank,
												:bank_account_type,
												:accounting_accountant_account,
												:name,
												:number,
												:open_date,
												:initial_balance,
												:current_balance

	#
	# Muestra el numero de cuenta con el balance actual
	#
	def number_with_current_balance
		"#{number} -- (#{current_balance.to_currency()})"
	end

	#
	# NOmbtre completo
	#
	def fullname
		"#{name} - (#{number})"
	end

	#
	# Cuenta contable
	#
	def accounting_accountant_account_name
		accounting_accountant_account.code if accounting_accountant_account
	end

	#
	# Si usa chuequera
	#
	def used_checkbook?(add_error=true)
		if not used_checkbook or cash_bank_checkbooks.empty?
			if add_error
				errors.add(:base, "no tiene chequera asociada")
			end
			return false
		else
			return true
		end
	end

	#
	# Muestra stodas las chuqeras inline
	#
	def checkbooks_inline
		cash_bank_checkbooks.map(&:full_name).join("<br/>")
	end

#
	# Bsuca los moviemientos del periodo establcido
	#
	def all_movement_by_period(period)
		month,year = period.split("/")
		period = "#{year}-#{month}"
		cash_bank_bank_movements.all(:conditions => ["SUBSTRING(date,1,7) = '#{period}'"])
	end

	#
	# Todas las untas po Banco
	#
	def self.all_by_cash_bank
		all(:select => "cash_bank_bank_id",:conditions => ["active = ?", true],:group => "cash_bank_bank_id")
	end

end
