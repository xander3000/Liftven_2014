class CashBank::CashJournalPositionCategoryType < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	has_many :cash_bank_cash_journal_position_concept_types,:class_name => "CashBank::CashJournalPositionConceptType",:foreign_key => "cash_bank_cash_journal_position_category_type_id"
end
