class CreateCashBankCashJournalCountPositions < ActiveRecord::Migration
  def self.up
    create_table :cash_bank_cash_journal_count_positions do |t|
      t.references  :cash_bank_cash_journal_count, :null => false
      t.references	:measure_change_denomination, :null => false
			t.integer			:quantity, :null => false
			t.float			:total_amount, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :cash_bank_cash_journal_count_positions
  end
end
