class CashBank::PosCardTerminalPosition < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	attr_accessor :total_amount

	humanize_attributes		:cash_bank_pos_card_terminal => "Punto de Venta",
												:lot_number => "Numero de Lote",
												:credit_total => "Total en TDC",
												:debit_total => "Total en TDD"


	belongs_to :cash_bank_pos_card_terminal,:class_name => "CashBank::PosCardTerminal"
	belongs_to :cash_bank_pos_card_terminal_movement,:class_name => "CashBank::PosCardTerminalMovement"

	validates_presence_of :cash_bank_pos_card_terminal,:lot_number,:credit_total,:debit_total
	validates_numericality_of :credit_total,:debit_total,:greater_than_or_equal_to => 0

	#
	# Monto total entre trajetas de credito y debito
	#
	def total_amount
		credit_total.to_f + debit_total.to_f
	end
end
