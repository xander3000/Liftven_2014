class Backend::FinancialManagement::PaymentSchedulesController < Backend::FinancialManagement::BaseController
	def index
		@payment_schedules = AccountPayable::PaymentSchedule.all
		@title = "Compras y Cuentas por pagar / Programación de Pagos"
	end

	def new
		@payment_schedule = AccountPayable::PaymentSchedule.new
		default_values
		@title = "Compras y Cuentas por pagar / Programación de Pagos / Nueva programación de pagos"
	end

	def set_bank
		@voucher = ""
		@bank = CashBank::Bank.find_by_id(params[:account_payable_payment_schedule][:cash_bank_bank_id])
		@success = false
		if @bank
			@success = true
			@bank_accounts = @bank.cash_bank_bank_accounts
		end
	end

	def set_incoming_invoice
				
		@errors = {}
		@incoming_invoice = AccountPayable::IncomingInvoice.find_by_id(params[:account_payable_payment_schedule][:account_payable_incoming_invoice_id])
		@success = false
		if @incoming_invoice
			@success = true
		else
			@errors[AccountPayable::IncomingInvoice.human_attribute_name("incoming_invoice").to_s] = "no existe"
		end
	end

	def set_payment_plan
		@payment_schedule = AccountPayable::PaymentSchedule.new(params[:account_payable_payment_schedule])
		@payment_schedule_positions = @payment_schedule.payment_plan
		@success = !@payment_schedule_positions.empty?
	end

	def create
		@payment_schedule = AccountPayable::PaymentSchedule.new(params[:account_payable_payment_schedule])
		default_values
		@success = @payment_schedule.valid?
		if @success
			@payment_schedule.save
			@payment_schedule_positions = @payment_schedule.payment_plan
			@payment_schedule_positions.each do |payment_schedule_position|
				payment_schedule_position.account_payable_payment_schedule = @payment_schedule
				payment_schedule_position.save
			end
		end
	end

	def show

	end

	def edit

	end

	def update
		
	end

	protected
	
	def default_values
		@payment_schedule.create_by = current_user
		@payment_schedule.currency_type = CurrencyType.default
	end
end
