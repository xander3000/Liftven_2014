class Frontend::OrdersController < Frontend::BaseController
  def new_decision_design
    @order = Order.find_by_id(params[:order_id])
    @design = @order.caso.design
    @notification = Notification.new
  end

  def accept_design
    @order = Order.find_by_id(params[:order_id])
    @notification = Notification.new(params[:notification])
    design = Design.find_by_id(params[:code_design])
    multimedia_files = MultimediaFile.find_by_id(params[:code_multimedia_file])
    @notification = @order.accept_design(@notification,multimedia_files)
    @success = @notification.valid?
    if @success
      @notification.save
    end
  end

  def discard_design
    @order = Order.find_by_id(params[:order_id])
    @notification = Notification.new(params[:notification])
    @notification = @order.discard_design(@notification)
    @success = @notification.valid?
    if @success
      @notification.save
      @notification.associate_case(@order.caso)
    end
  end
end
