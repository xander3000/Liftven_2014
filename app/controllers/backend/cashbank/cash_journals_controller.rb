class Backend::Cashbank::CashJournalsController < Backend::Cashbank::BaseController
  def index
		@title = "Caja menor"
		@cash_journal = CashBank::CashJournal.all_opened
  end
  
  def new
    @title = "Caja menor / Nueva caja"
    @cash_journal = CashBank::CashJournal.new
    @cashs = CashBank::Cash.all_only_for_journal
		@accounting_accounting_concepts = Accounting::AccountingConcept.all_mbe
    default
  end

  def create
    @cash_journal = CashBank::CashJournal.new(params[:cash_bank_cash_journal])
    default
    @success = @cash_journal.valid?
    if @success
      @cash_journal.save
    end
  end

  def show
    @cash_journal = CashBank::CashJournal.find(params[:id])
    @title = "Caja menor / Detalle caja #{@cash_journal.cash_bank_cash.name}"
    respond_to do |format|

				format.html
				format.csv do
          path_to_save = "#{RAILS_ROOT}/public/csv"
          file_name = "#{path_to_save}/detalle_caja_#{@cash_journal.cash_bank_cash.name.to_underscore}.csv"
          if !File.exist?(path_to_save)
            system 'mkdir', '-p', path_to_save
          end
          	 owner = Supplier.find_owner
              contact = owner.contact
CSV.open(file_name, "wb",  ';' ) do |csv|
            csv << [Iconv.iconv('iso8859-1','utf-8', contact.fullname.upcase).first]
            csv << [Iconv.iconv('iso8859-1','utf-8',contact.address).first]
            csv << [Iconv.iconv('iso8859-1','utf-8', @cash_journal.cash_bank_cash.name).first]
            csv << [Iconv.iconv('iso8859-1','utf-8', CashBank::CashJournal.human_attribute_name(:id)),Iconv.iconv('iso8859-1','utf-8', @cash_journal.cash_bank_cash.name).first]
            csv << [Iconv.iconv('iso8859-1','utf-8', CashBank::CashJournal.human_attribute_name(:id)),Iconv.iconv('iso8859-1','utf-8', @cash_journal.cash_bank_cash.name).first]
            csv << [Iconv.iconv('iso8859-1','utf-8', CashBank::CashJournal.human_attribute_name(:id)),Iconv.iconv('iso8859-1','utf-8', @cash_journal.cash_bank_cash.name).first]
            csv << []
            csv << [
                      Iconv.iconv('iso8859-1','utf-8', CashBank::CashJournalPosition.human_attribute_name(:id)).first,
                      Iconv.iconv('iso8859-1','utf-8', CashBank::CashJournal.human_attribute_name(:cash_bank_cash_journal_position_category_type)).first,
                      CashBank::CashJournalPosition.human_attribute_name(:cash_bank_cash_journal_position_concept_type),
                      CashBank::CashJournalPosition.human_attribute_name(:total),
                      CashBank::CashJournalPosition.human_attribute_name(:invoice_tenderer),
                      CashBank::CashJournalPosition.human_attribute_name(:invoice_date),
                      Iconv.iconv('iso8859-1','utf-8', CashBank::CashJournalPosition.human_attribute_name(:is_fiscal)).first,
                      CashBank::CashJournalPosition.human_attribute_name(:invoice_sub_total),
                      CashBank::CashJournalPosition.human_attribute_name(:invoice_tax),
                      CashBank::CashJournalPosition.human_attribute_name(:invoice_control_number),
                      CashBank::CashJournalPosition.human_attribute_name(:invoice_reference)
                      ]
            @cash_journal.cash_bank_cash_count_positions.each do |position|
              csv << [
                      position.id.to_code,
                      Iconv.iconv('iso8859-1','utf-8', position.cash_bank_cash_journal_position_category_type.name).first,
                      Iconv.iconv('iso8859-1','utf-8', position.cash_bank_cash_journal_position_concept_type.name).first,
                      position.total,
                      Iconv.iconv('iso8859-1','utf-8', position.invoice_tenderer.name).first,
                      position.invoice_date,
                      position.is_fiscal ? "Si" : "No",
                      position.invoice_sub_total.to_currency,
                      position.invoice_tax.to_currency,
                      position.invoice_reference,
                      position.invoice_control_number,
                      ]
            end

          end

          send_file file_name,:type => "text/csv;"
				end
		end

  end

  def new_position
    @cash_journal = CashBank::CashJournal.find(params[:id])
    @cash_journal_position = CashBank::CashJournalPosition.new
  end
  
  def add_position
		@cash_journal = CashBank::CashJournal.find(params[:cash_journal_id])
    @cash_journal_position = CashBank::CashJournalPosition.new(params[:cash_bank_cash_journal_position])
		@cash_journal_position.cash_bank_cash_journal = @cash_journal
		@cash_journal_position.create_by = current_user
		@success = @cash_journal_position.valid?
		if @success
			@cash_journal_position.save
			@cash_journal.reload
		end
  end

	def set_concept_position
		@position_category_type = CashBank::CashJournalPositionCategoryType.find_by_id(params[:cash_bank_cash_journal_position][:cash_bank_cash_journal_position_category_type_id].to_i)
		if @position_category_type
			@position_concept_types = @position_category_type.cash_bank_cash_journal_position_concept_types
		else
			@position_concept_types = []
		end
	end

  def new_cash_journal_count
    @cash_journal = CashBank::CashJournal.find(params[:cash_journal_id])
    @title = "Caja menor / Arqueo caja #{@cash_journal.cash_bank_cash.name}"
    @cash_journal_count = CashBank::CashJournalCount.new
    @cash_count_journal_position = CashBank::CashJournalCountPosition.new
    default_cash_journal_count
    current_cash_jounal_count_position_clear

  end

  def create_cash_journal_count
     @cash_journal = CashBank::CashJournal.find(params[:cash_journal_id])
     @cash_journal_count = CashBank::CashJournalCount.new(params[:cash_bank_cash_journal_count])
     default_cash_journal_count
     @success = @cash_journal_count.valid?
     if @success
       @cash_journal_count.save
       self.current_cash_jounal_count_position.each do |cash_jounal_count_position|
         cash_jounal_count_position.cash_bank_cash_journal_count = @cash_journal_count
         cash_jounal_count_position.save
       end
			 current_cash_jounal_count_position_clear
     end
  end

  def add_cash_journal_count_position
    @cash_journal = CashBank::CashJournal.find(params[:cash_journal_id])
    @cash_journal_count = CashBank::CashJournalCount.new
    @cash_count_journal_position = CashBank::CashJournalCountPosition.new(params[:cash_bank_cash_journal_count_position])
    @success = @cash_count_journal_position.valid?
    if @success
      self.current_cash_jounal_count_position=params[:cash_bank_cash_journal_count_position]
			@cash_count_journal_positions = self.current_cash_jounal_count_position
			@cash_journal_count.total_amount_count = @cash_count_journal_positions.map(&:total_amount).to_sum
    end
    default_cash_journal_count
  end

	def show_cash_journal_count
		@cash_journal = CashBank::CashJournal.find(params[:cash_journal_id])
    @title = "Caja menor / Arqueo caja #{@cash_journal.cash_bank_cash.name}"
		@cash_journal_count = CashBank::CashJournalCount.find(params[:cash_journal_count_id])
		@consolidate_count_positions = @cash_journal_count.consolidate_count_positions
		@consolidate_concept_cash_journal_positions = @cash_journal_count.consolidate_concept_cash_journal_positions
		respond_to do |format|
      format.html
      format.pdf do
				render :pdf                            => "cash_journal_count_#{@cash_journal_count.id}",
               :disposition                    => 'attachment',
							 :layout												 =>	'backend/contable_document.html.erb',
							 :page_size                      => 'Legal',
							 :orientation										 => 'Portrait',
							 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																			},
														:left => '2'
														},
							 :margin => {:top                => 15,
                           :bottom             => 30,
													 :right              => 2,
                           :left               => 5
 												 }
			end
		end
	end

  protected

  def default
    @cash_journal.create_by = current_user
  end

  def default_cash_journal_count
    @cash_journal_count.cash_bank_cash_journal = @cash_journal
    @cash_journal_count.total_amount_register = @cash_journal.current_total_amount_positions
    @cash_journal_count.responsible = current_user
    @cash_journal_count.date = Time.now.to_date
  end

  def current_cash_jounal_count_position=cash_count_position
		session[:cash_journal_count_positions] = [] if session[:cash_journal_count_positions].nil?
		session[:cash_journal_count_positions] << cash_count_position
	end

	def current_cash_jounal_count_position
		cash_count_positions = []
		session[:cash_journal_count_positions] = [] if session[:cash_journal_count_positions].nil?
    session[:cash_journal_count_positions].each do |item|
      cash_count_positions << CashBank::CashJournalCountPosition.new(item)
    end
    cash_count_positions
	end

	def current_cash_jounal_count_position_clear
		session[:cash_journal_count_positions] = []
	end

end
