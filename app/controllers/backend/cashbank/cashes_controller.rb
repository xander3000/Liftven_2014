class Backend::Cashbank::CashesController < Backend::Cashbank::BaseController
	def index
		@cashes = CashBank::Cash.all
		@title = "Cajas"
	end

	def new
    @title = "Cajas / nueva caja"
		@cash = CashBank::Cash.new
		@responsibles = User.all_checker_responsibles
	end

	def create
		@cash = CashBank::Cash.new(params[:cash_bank_cash])
		@success = @cash.valid?
		if @success
			@cash.save
		end
	end

  def show
    @title = "Cajas / Detalle caja"
    @cash = CashBank::Cash.find(params[:id])
  end
end