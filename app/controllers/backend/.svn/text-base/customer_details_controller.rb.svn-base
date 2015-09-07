class Backend::CustomerDetailsController < Backend::BaseController

  def new
    @customer_detail = CustomerDetail.new
  end

  def create
    @customer_detail = CustomerDetail.new(params[:customer_detail])
    @success = @customer_detail.valid?
    if @success
      #@customer_detail.save
    end
  end
end
