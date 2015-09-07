class CashBank::BankReconciliation < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	attr_accessor :diference,
								:transaction_not_registered_at_bank_currency,
								:balance_according_bank_currency,
								:balance_according_book_currency,
								:transaction_not_registered_at_bank_currency,
								:transaction_not_registered_at_book_currency,
								:automatic_reconciled_transaction_at_bank_currency,
								:automatic_reconciled_transaction_at_book_currency,
								:error_at_bank_currency,
								:error_at_book_currency,
								:balance_movement_reconciliation_currency,
								:diference_currency

		humanize_attributes	:cash_bank_bank => "Banco",
												:cash_bank_bank_account => "Cuenta Bancaria",
												:accounting_accountant_account => "Cta. Contable",
												:period => "Periodo",
												:initial_date => "Fecha de inicio",
												:final_date => "Fecha fín",
												:base => "Movimiento en Bancos",
												:id => "Conciliación Bancaria",
												:account_balance_to_date => "Balance a la fecha",
												:upload_filename_reconciliation => "Archivo de conciliación",
												:balance_according_bank => "Saldo según banco",
												:balance_according_book => "Saldo según libro",
												:transaction_not_registered_at_bank => "Transacciones no registradas en banco",
												:transaction_not_registered_at_book => "Transacciones no registradas en libro",
												:error_at_bank => "Error en banco",
												:error_at_book => "Error en libro",
												:balance_movement_reconciliation => "Saldo de movimientos conciliados",
												:diference => "Diferencia",
												:balance_according_bank_currency => "Saldo según banco",
												:balance_according_book_currency => "Saldo según libro",
												:automatic_reconciled_transaction_at_bank => "Transacciones autoconciliadas en banco",
												:automatic_reconciled_transaction_at_book => "Transacciones autoconciliadas en libro",
												:transaction_not_registered_at_bank_currency => "Transacciones no registradas en banco",
												:transaction_not_registered_at_book_currency => "Transacciones no registradas en libro",
												:automatic_reconciled_transaction_at_bank_currency => "Transacciones autoconciliadas en banco",
												:automatic_reconciled_transaction_at_book_currency => "Transacciones autoconciliadas en libro",
												:error_at_bank_currency => "Error en banco",
												:error_at_book_currency => "Error en libro",
												:balance_movement_reconciliation_currency => "Saldo de movimientos conciliados",
												:diference_currency => "Diferencia"


	has_many :cash_bank_bank_reconciliation_bank_statements,:class_name => "CashBank::BankReconciliationBankStatement",:foreign_key => "cash_bank_bank_reconciliation_id"
	belongs_to :cash_bank_bank,:class_name => "CashBank::Bank"
	belongs_to :cash_bank_bank_account,:class_name => "CashBank::BankAccount"
	belongs_to :accounting_accountant_account,:class_name => "Accounting::AccountantAccount"

	validates_presence_of :period,:initial_date,:final_date,:cash_bank_bank,:cash_bank_bank_account,:accounting_accountant_account,:balance_according_bank,
												:balance_according_book,:transaction_not_registered_at_bank,:transaction_not_registered_at_book,:error_at_bank,:error_at_book,:balance_movement_reconciliation,
												:diference,:transaction_not_registered_at_bank_currency,:balance_according_bank_currency,:balance_according_book_currency,:transaction_not_registered_at_bank_currency,
												:transaction_not_registered_at_book_currency,:automatic_reconciled_transaction_at_bank_currency,:automatic_reconciled_transaction_at_book_currency,:error_at_bank_currency,
												:error_at_book_currency,:balance_movement_reconciliation_currency,:diference_currency
							
	validates_uniqueness_of :period,:scope => [:cash_bank_bank_account_id]
	#validates_numericality_of :diference,:equal_to => 0.0
	validate :diference_is_zero?

	 #
	 # balance_according_bank_currency en formato currency
	 #
	 def balance_according_bank_currency
		 balance_according_bank.to_currency(false)
	 end

	 #
	 # balance_according_book en formato currency
	 #
	 def balance_according_book_currency
		 balance_according_book.to_currency(false)
	 end

	 #
	 # transaction_not_registered_at_bank en formato currency
	 #
	 def transaction_not_registered_at_bank_currency
		 transaction_not_registered_at_bank.to_currency(false)
	 end

	 #
	 # transaction_not_registered_at_book en formato currency
	 #
	 def transaction_not_registered_at_book_currency
		 transaction_not_registered_at_book.to_currency(false)
	 end

	 #
	 # transaction_not_registered_at_book en formato currency
	 #
	 def transaction_not_registered_at_book_currency
		 transaction_not_registered_at_book.to_currency(false)
	 end

	 
	 #
	 # error_at_bank en formato currency
	 #
	 def error_at_bank_currency
		 error_at_bank.to_currency(false)
	 end

	 #
	 # error_at_book en formato currency
	 #
	 def error_at_book_currency
		 error_at_book.to_currency(false)
	 end

	 #
	 # balance_movement_reconciliation en formato currency
	 #
	 def balance_movement_reconciliation_currency
		 balance_movement_reconciliation.to_currency(false)
	 end


	 #
	 # calculo automatic_reconciled_transaction_at_bank
	 #
	 def calculate_automatic_reconciled_transaction_at_bank(bank_movements_at_book)
		 allowed_movement_operations = CashBank::BankMovementOperationType.allowed_movement_operations_on_reconciliation_at_bank_from_book
		 bank_movements_at_book.each do |bank_movement_at_book|
			 if allowed_movement_operations.include?(bank_movement_at_book.cash_bank_bank_movement_operation_type.tag_name.downcase)
				 if bank_movement_at_book.cash_bank_bank_movement_operation_type.is_debit
					 self.automatic_reconciled_transaction_at_bank +=  bank_movement_at_book.amount
				 else
					 self.automatic_reconciled_transaction_at_bank -=  bank_movement_at_book.amount
				 end
			 else
				 if bank_movement_at_book.cash_bank_bank_movement_operation_type.is_debit
					 self.error_at_bank  -=  bank_movement_at_book.amount
				 else
					 self.error_at_bank  +=  bank_movement_at_book.amount
				 end

			 end
			 

		 end
	 end

	 #
	 # automatic_reconciled_transaction_at_bank en formato currency
	 #
	 def automatic_reconciled_transaction_at_bank_currency
		 automatic_reconciled_transaction_at_bank.to_currency(false)
	 end

	 #
	 # automatic_reconciled_transaction_at_book en formato currency
	 #
	 def automatic_reconciled_transaction_at_book_currency
		 automatic_reconciled_transaction_at_book.to_currency(false)
	 end



	 #
	 # diferencia entre saldos de banco y libro
	 #
	 def diference
		 transaction_not_registered_at_bank - transaction_not_registered_at_book + automatic_reconciled_transaction_at_bank + automatic_reconciled_transaction_at_book
	 end

	 #
	 # diferencia en formato currency
	 #
	 def diference_currency
		 diference.to_currency(false)
	 end

	 #
	 #
	 #
	 def diference_is_zero?
		 if not diference.zero?
			 errors.add(:diference, "debe ser igual a cero")
			 return false
		 end
		 return true
	 end

end
