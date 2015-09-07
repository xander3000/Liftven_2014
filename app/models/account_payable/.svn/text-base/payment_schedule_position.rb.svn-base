class AccountPayable::PaymentSchedulePosition < ActiveRecord::Base
	def self.table_name_prefix
    'account_payable_'
  end

	belongs_to :account_payable_payment_schedule,:class_name => "AccountPayable::PaymentSchedule"
end
