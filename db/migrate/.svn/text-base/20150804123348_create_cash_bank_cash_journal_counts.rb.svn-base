class CreateCashBankCashJournalCounts < ActiveRecord::Migration
  def self.up
    create_table :cash_bank_cash_journal_counts do |t|
      t.references :cash_bank_cash_journal, :null => false
      t.string  :date,:null => false
      t.float	 :total_amount_register,:null => false
      t.float	 :difference_amount_count,:null => false
      t.float	 :total_amount_count,:null => false
      t.references	:responsible, :null => false
      t.text    :note
      t.timestamps
    end
  end

  def self.down
    drop_table :cash_bank_cash_journal_counts
  end
end
