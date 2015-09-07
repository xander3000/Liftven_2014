class AddColumnCountToCashBankCashJournalPositions < ActiveRecord::Migration
  def self.up
    add_column :cash_bank_cash_journal_positions,:count,:boolean,:default => false
		add_column :cash_bank_cash_journal_positions,:cash_bank_cash_journal_count_id,:integer
    CashBank::CashJournalPosition.all.each  do |cash_journal_position|
      cash_journal_position.update_attribute(:count,false)
    end
  end

  def self.down
    remove_columns :cash_bank_cash_journal_positions,:count,:cash_bank_cash_journal_count_id
  end
end
