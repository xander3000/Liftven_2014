class Backend::Cpanel::HomeController < Backend::Cpanel::BaseController
	def index
    @title = "Módulos"
		@accountant_accounts = Accounting::AccountantAccount.all_base
		@modules =  ConfigPanel::Module.all_cpanel
		@modules =  current_user.cpanel_submodules
	end
end
