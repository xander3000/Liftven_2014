class CashBank::PosCardTerminalMovement < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	humanize_attributes		:total_amount_credit_debit => "Total en TDC/TDD",
												:diference_amount_credit_debit => "Diferencia en TDC/TDD"

	belongs_to :cash_bank_daily_cash_closing,:class_name => "CashBank::DailyCashClosing"
	has_many :cash_bank_pos_card_terminal_positions,:class_name => "CashBank::PosCardTerminalPosition",:foreign_key => "cash_bank_pos_card_terminal_movement_id"

	validates_presence_of :total_amount_credit_debit,:diference_amount_credit_debit



	#
	# consolidado para puntos de ventas
	#
	def consolidate_pos_card_terminal_positions
		consolidate = {}
		CashBank::PosCardTerminal.all.each do |pos_card_terminal|
			consolidate[pos_card_terminal.id] = {:name => pos_card_terminal.name,:values => {}}
		end
		cash_bank_pos_card_terminal_positions.each do |cash_bank_pos_card_terminal_position|
			consolidate[cash_bank_pos_card_terminal_position.cash_bank_pos_card_terminal_id][:values] = cash_bank_pos_card_terminal_position.attributes
		end
		consolidate
	end



end
