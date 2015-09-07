class CashBank::CashJournalCount < ActiveRecord::Base
    def self.table_name_prefix
     'cash_bank_'
    end
    	humanize_attributes		:base => "Arqueo des Caja menor",
                            :cash_bank_cash_journal => "Caja menor",
                            :cash_bank_cash_journal_id => "Caja menor",
                            :date => "Fecha de arqueo",
                            :total_amount_register => "Balance registrado",
                            :difference_amount_count => "Diferencia al arqueo",
                            :total_amount_count => "Balance arqueado",
                            :responsible => "Responsable",
                            :note => "Nota"

    validates_presence_of :cash_bank_cash_journal,:date,:total_amount_register,:responsible,:difference_amount_count,:total_amount_count
    validates_numericality_of :total_amount_register,:greater_than => 0,:message => "debe ser mayor a cero"

    belongs_to :cash_bank_cash_journal,:class_name => "CashBank::CashJournal"
    belongs_to :responsible,:class_name => "User"
		has_many :cash_bank_cash_journal_count_positions,:class_name => "CashBank::CashJournalCountPosition",:foreign_key => :cash_bank_cash_journal_count_id
		has_many :cash_bank_cash_count_positions,:class_name => "CashBank::CashJournalPosition",:foreign_key => "cash_bank_cash_journal_count_id"
		
		after_create :set_cash_journal_count_to_cash_journal_positions

	#
	# consolidado para el arqueo de caja
	#
	def consolidate_count_positions
		consolidate = {}
		MeasureChangeDenomination.all.each do |measure_change_denomination|
			consolidate[measure_change_denomination.measure_change_type_id] = {:name => measure_change_denomination.measure_change_type.name,:total_amount => 0,:denominations => {}} if !consolidate.has_key?(measure_change_denomination.measure_change_type_id)
			consolidate[measure_change_denomination.measure_change_type_id][:denominations][measure_change_denomination.id] = {:total_amount => 0,:quantity => 0,:name => measure_change_denomination.name}
		end
		cash_bank_cash_journal_count_positions.each do |cash_bank_cash_journal_count_position|
			measure_change_type_id = cash_bank_cash_journal_count_position.measure_change_denomination.measure_change_type_id
			measure_change_denomination_id = cash_bank_cash_journal_count_position.measure_change_denomination_id
			if consolidate[measure_change_type_id][:denominations].has_key?(measure_change_denomination_id)
				consolidate[measure_change_type_id][:total_amount] += cash_bank_cash_journal_count_position.total_amount
				consolidate[measure_change_type_id][:denominations][measure_change_denomination_id][:total_amount] += cash_bank_cash_journal_count_position.total_amount
				consolidate[measure_change_type_id][:denominations][measure_change_denomination_id][:quantity] += cash_bank_cash_journal_count_position.quantity
			end
		end
		consolidate
	end

	#
	# consolidado de posiciones del arqueo de caja
	#
	def consolidate_concept_cash_journal_positions
		consolidate = {}
		CashBank::CashJournalPositionCategoryType.all.each do |cash_journal_position_category_type|
			consolidate[cash_journal_position_category_type.id] = {:name => cash_journal_position_category_type.name,:total_amount => 0} 
		end
		cash_bank_cash_count_positions.each do |cash_bank_cash_count_position|
			consolidate[cash_bank_cash_count_position.cash_bank_cash_journal_position_category_type_id][:total_amount] += cash_bank_cash_count_position.total
		end
		consolidate
	end

	#
	# Asocia el arqueo a las posiciones de la caja menor actual
	#
	def set_cash_journal_count_to_cash_journal_positions
			cash_bank_cash_journal.cash_bank_cash_count_positions.all(:conditions => {:count => false}).each do |cash_count_position|
				cash_count_position.update_attributes(:count => true,:cash_bank_cash_journal_count_id => id)
			end
	end
end
