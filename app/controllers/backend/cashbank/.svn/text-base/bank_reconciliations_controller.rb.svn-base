class Backend::Cashbank::BankReconciliationsController < Backend::Cashbank::BaseController

	def index
			@bank_reconciliations = CashBank::BankReconciliation.all
	end

	def new
		@bank_reconciliation = CashBank::BankReconciliation.new
	end

	def create
		@bank_reconciliation = CashBank::BankReconciliation.new(params[:cash_bank_bank_reconciliation])
		@success = @bank_reconciliation.valid?
		if @success
			@bank_reconciliation.save
			session[:bank_statements].each do |bank_statement_v|
				bank_statement = CashBank::BankReconciliationBankStatement.new
				bank_statement.date = bank_statement_v["date"]
				bank_statement.reference = bank_statement_v["reference"]
				bank_statement.debit_amount = bank_statement_v["debit"]
				bank_statement.credit_amount = bank_statement_v["credit"]
				bank_statement.description = bank_statement_v["description"]
				bank_statement.balance = bank_statement_v["balance"]
				bank_statement.movement_operation = bank_statement_v["type"]
				bank_statement.cash_bank_bank_reconciliation = @bank_reconciliation
				bank_statement.save
			end
			session[:bank_statements] = []
		end
	end

	def show
		@bank_reconciliation = CashBank::BankReconciliation.find(params[:id])
	end

	def bank_statement
		@bank_reconciliation = CashBank::BankReconciliation.find(params[:bank_reconciliation_id])
		@bank_statements = @bank_reconciliation.cash_bank_bank_reconciliation_bank_statements
		respond_to do |format|
				format.html 
				format.pdf	do
					render :pdf                            => "ConciliacionBancaria_#{@bank_reconciliation.id.to_code("06")}_ExtractoBancario",
								 :disposition                    => 'attachment',
								 #:file                           => "#{controller_path}/bank_statement.erb",
								 :layout                         => 'backend/report.html.erb',
								 :show_as_html                   =>  params[:debug].present?,
								 :orientation                    => 'Portrait',
								 :page_12												=> 'Letter',            # default A4
								 :save_to_file                   => Rails.root.join('public/pdfs', "ConciliacionBancaria_#{@bank_reconciliation.id.to_code("06")}_ExtractoBancario.pdf"),
								 :save_only                      => false,
								 :lowquality	=> true,
								 :footer => {
										:html => {
												#:template => "shared/backend/layouts/report_footer.erb",
												:layout => "shared/backend/layouts/report_footer.erb",
										}
								}
				end
		end
	end

	def bank_book
		@bank_reconciliation = CashBank::BankReconciliation.find(params[:bank_reconciliation_id])
		@bank_movements = @bank_reconciliation.cash_bank_bank_account.all_movement_by_period(@bank_reconciliation.period)
		respond_to do |format|
				format.html
				format.pdf	do
					render :pdf                            => "ConciliacionBancaria_#{@bank_reconciliation.id.to_code("06")}_LibroBanco",
								 :disposition                    => 'attachment',
								 #:file                           => "#{controller_path}/bank_statement.erb",
								 :layout                         => 'backend/report.html.erb',
								 :show_as_html                   =>  params[:debug].present?,
								 :orientation                    => 'Portrait',
								 :page_12												=> 'Letter',            # default A4
								 :save_to_file                   => Rails.root.join('public/pdfs', "ConciliacionBancaria_#{@bank_reconciliation.id.to_code("06")}_LibroBanco.pdf"),
								 :save_only                      => false,
								 :lowquality	=> true,
								 :footer => {
										:html => {
												#:template => "shared/backend/layouts/report_footer.erb",
												:layout => "shared/backend/layouts/report_footer.erb",
										}
								}
				end
		end
	end

	def set_period
		period = params[:cash_bank_bank_reconciliation][:period]
		period = period.split("/")
		@initial_date = Date.civil(period.last.to_i, period.first.to_i, 1).to_s.to_default_date
		@final_date = Date.civil(period.last.to_i, period.first.to_i, -1).to_s.to_default_date
	end

	def set_bank
		@voucher = ""
		@bank = CashBank::Bank.find_by_id(params[:cash_bank_bank_reconciliation][:cash_bank_bank_id])
		@success = false
		if @bank
			@success = true
			@bank_accounts = @bank.cash_bank_bank_accounts
		end
	end

	def set_bank_account
		@bank_account = CashBank::BankAccount.find_by_id(params[:cash_bank_bank_reconciliation][:cash_bank_bank_account_id])
		@success = false
		if @bank_account
			period = params[:bank_reconciliation_period]
			@bank_movements = @bank_account.all_movement_by_period(period)
			@bank_movements
			@success = true
		end
	end


	def upload_filename_reconciliation
		temp_file =  params[:qqfile]
		session[:bank_statements] = []
		bank = CashBank::Bank.find_by_id(params[:bank_id])
		@bank_statements = []
		rows_data = []
		header = false
		parsed_file = FasterCSV.read(temp_file.path, { :col_sep => bank.col_sep_bank_recon_file })
		parsed_file.each do |row|
			if header
				bank_statement = CashBank::BankReconciliationBankStatement.new

				bank_statement.date =  row[bank.column_position_date_bank_recon_file].from_format_to_date(bank.format_date_bank_recon_file,"/")
				bank_statement.reference =  row[bank.column_position_reference_bank_recon_file].to_i
				bank_statement.description =  row[bank.column_position_description_bank_recon_file]
				if bank.column_position_debit_amount_bank_recon_file.eql?(bank.column_position_credit_amount_bank_recon_file)
					value = row[bank.column_position_debit_amount_bank_recon_file].from_format_to_float(bank.formt_curre_bank_recon_file)
					bank_statement.debit_amount =  value < 0 ? value.abs : 0 #row[bank.column_position_debit_amount_bank_recon_file].from_format_to_float(bank.formt_curre_bank_recon_file)
					bank_statement.credit_amount = value >= 0 ? value.abs : 0# row[bank.column_position_credit_amount_bank_recon_file].from_format_to_float(bank.formt_curre_bank_recon_file)
				else
					bank_statement.debit_amount =  row[bank.column_position_debit_amount_bank_recon_file].from_format_to_float(bank.formt_curre_bank_recon_file)
					bank_statement.credit_amount =  row[bank.column_position_credit_amount_bank_recon_file].from_format_to_float(bank.formt_curre_bank_recon_file)
				end
				bank_statement.balance =  row[bank.column_position_balance_bank_recon_file].from_format_to_float(bank.formt_curre_bank_recon_file)
				bank_statement.movement_operation =  bank.column_position_movement_operation_bank_recon_file.eql?(-1) ? "N/D" : row[bank.column_position_movement_operation_bank_recon_file]
				@bank_statements << bank_statement
				rows_data << {"date" => bank_statement.date,"reference" => bank_statement.reference,"description" => bank_statement.description,"debit" => bank_statement.debit_amount,"debit_currency" => bank_statement.debit_amount.to_currency(false),"credit" => bank_statement.credit_amount,"credit_currency" => bank_statement.credit_amount.to_currency(false),"balance" => bank_statement.balance.to_currency(false),"type" => bank_statement.movement_operation}
			else
				header = true
			end
		end
		session[:bank_statements] = rows_data
		render :text => JSON.generate("success" => true,"data" => rows_data)
	end

	def process_reconciliation
		period = params[:cash_bank_bank_reconciliation][:period]
		bank_account = CashBank::BankAccount.find_by_id(params[:bank_account_id])
		bank = bank_account.cash_bank_bank
		
		@bank_reconciliation = CashBank::BankReconciliation.new
		@bank_movements = bank_account.all_movement_by_period(period)
		#TODO: buscar o crera un libro de peiodos
		@bank_reconciliation.balance_according_book = @bank_movements.first.account_balance_to_date
		@bank_reconciliation.balance_according_bank = @bank_movements.first.account_balance_to_date
		@bank_statements = session[:bank_statements].clone


		# BEGIN: Autoconciliacion Extracto Bancario
		bank_autoreconciliation_by_descriptions = bank.cash_bank_bank_autoreconciliation_by_descriptions.map(&:name).map(&:strip).map(&:upcase)
		@bank_statements.each do |bank_statement|
			if bank_autoreconciliation_by_descriptions.include?(bank_statement["description"].strip.upcase)
				@bank_reconciliation.balance_movement_reconciliation += bank_statement["credit"] - bank_statement["debit"]
				@bank_reconciliation.balance_according_bank += bank_statement["credit"] - bank_statement["debit"]
				@bank_reconciliation.automatic_reconciled_transaction_at_bank += bank_statement["credit"] - bank_statement["debit"]
				@bank_statements.delete(bank_statement)
			end
		end
		# END: Autoconciliacion Extracto Bancario

		# BEGIN: Conciliacion Libro de Banco vs Extracto Bancario
		@bank_movements.each do |bank_movement|
			@bank_reconciliation.balance_according_book += bank_movement.credit_amount -  bank_movement.debit_amount
				@bank_statements.each do |bank_statement|
				if bank_movement.debit_amount.eql?(bank_statement["debit"].to_f) and bank_movement.credit_amount.eql?(bank_statement["credit"].to_f) # and bank_movement.date.to_date.to_s.to_default_date.eql?(bank_statement["date"])
					@bank_reconciliation.balance_movement_reconciliation += bank_statement["credit"] - bank_statement["debit"]
					@bank_reconciliation.balance_according_bank += bank_statement["credit"] - bank_statement["debit"]
					@bank_movements[@bank_movements.index(bank_movement)] = nil
					@bank_statements.delete(bank_statement)
					break
				end
			end
		# END: Conciliacion Libro de Banco vs Extracto Bancario
		end
		@bank_movements = @bank_movements.compact
		@bank_reconciliation.transaction_not_registered_at_bank = @bank_movements.map(&:credit_amount).sum - @bank_movements.map(&:debit_amount).sum
		@bank_reconciliation.calculate_automatic_reconciled_transaction_at_bank(@bank_movements)
		#@bank_reconciliation.transaction_not_registered_at_book = @bank_statements.map(&:debit).sum - @bank_movements.map(&:credit).sum
	end



	def set_title
    @title = "Conciliación Bancaria"
  end
end
