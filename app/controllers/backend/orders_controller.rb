class Backend::OrdersController < Backend::BaseController

  def index
    respond_to do |format|
      format.html  do
        @orders = Order.all_by_user_and_states(current_user)
      end
      format.json  do
        render :json => Order.all_to_json
      end
    end
    
  end

	def paginate
		 @orders = Order.all_by_user_and_states(current_user,params)
	end

  def show
		@order = Order.find_by_id(params[:id])
		@delivery_notes = @order.delivery_notes

		respond_to do |format|
      format.html
      format.pdf do
				caso = @order.caso
				@budget = caso.budget
				@product_by_budgets = @budget.product_by_budgets

				render :pdf                            => "orden_#{@budget.id}",
               :disposition                    => 'attachment',
							 :layout												 =>	'backend/contable_document.html.erb',
							 :page_size                      => 'Letter',
							 :margin => {:top                => 18,
                           :bottom             => 30,
													 :right              => 2,
                           :left               => 5
 												 },
							 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																			},
														:left => '2'
														},
								:footer => {:html => { :template => 'shared/backend/layouts/footer_contable_document.erb'
																			},
														:left => '2'
														}
			end
		end
  end

  def change_state
    @order = Order.find_by_id(params[:order_id])
    current_tracker = @order.caso.actual_tracker(false).category
    state = State.find_by_id(params[:state][:id])
    attr = {
      :user_id => current_user.id,
      :state_id => state.id
    }
    options = {
      :user_tracker => (current_tracker.has_state_apply_to_orders_by_user_groups?(state) ? current_tracker : User.first_with_state_by_user_groups(state)),
      :user_tracker_actual => true
    }
    @order.caso.add_tracking_state(attr,options)
  end

  def search
    @orders = Order.search(params[:search_term])
  end
  
  def new_comment
    @order = Order.find_by_id(params[:order_id])
    @comment = Comment.new
  end
  
  def add_comment
    @order = Order.find_by_id(params[:order_id])
    comment = Comment.new(params[:comment])
    @success = comment.valid?
    if @success
      comment.user = current_user
      comment.category = @order.caso
      comment.save
    end
  end

  def upload
    
    multimedia_files  = []
    params[:files].each do |file|
      multimedia_file = MultimediaFile.new(:attach => file)
      success = multimedia_file.valid?
      if success
        multimedia_file.save
        multimedia_file_json = {:name => multimedia_file.attach_file_name,
                                :size => multimedia_file.attach_file_size,
                                :url => multimedia_file.attach.url,
                                :thumbnail_url => multimedia_file.thumbnail_url,
                                :delete_url => backend_multimedia_file_url(multimedia_file),
                                :delete_type => multimedia_file.delete_type}#
        # = multimedia_file.attach.to_json(:only => [:name],:methods => [:size,:url,:thumbnail_url])
        #multimedia_file_json = multimedia_file_json.to_json
        self.multimedia_files_uploads = multimedia_file.id
        multimedia_files << multimedia_file_json
      end
      
    end
    json = JSON.generate(multimedia_files)
    render :text => json
  end

	def new_delivery_note
		@order = Order.find_by_id(params[:order_id])
		@budget = @order.caso.budget
		@delivery_note = DeliveryNote.new
	end

	def create_delivery_note
		@order = Order.find_by_id(params[:order_id])
		@delivery_note = DeliveryNote.new(params[:delivery_note])
		@success = @delivery_note.valid?
		if @success
			@delivery_note.save
		end
	end

	def show_delivery_note
		@order = Order.find_by_id(params[:order_id])
		@case = @order.caso
		@budget = @case.budget
		@delivery_note = DeliveryNote.find(params[:delivery_note_id])
		@title = "Nota de entrega"


		respond_to do |format|
      format.html
      format.pdf do
				render :pdf                            => "delivery_note_#{@delivery_note.id}",
               :disposition                    => 'attachment',
							 :layout												 =>	'backend/contable_document.html.erb',
							 :page_size                      => 'Letter',
							 :margin => {:top                => 18,
                           :bottom             => 30,
													 :right              => 2,
                           :left               => 5
 												 },
							 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																			},
														:left => '2'
														},
								:footer => {:html => { :template => 'shared/backend/layouts/footer_contable_document.erb'
																			},
														:left => '2'
														}
			end
		end
	end

  def new_design
    multimedia_files_uploads_reset
    @order = Order.find_by_id(params[:order_id])
    @design = Design.new
  end

  def create_design
    @order = Order.find_by_id(params[:order_id])
    @design = Design.new(params[:design])
    @success = @design.valid?
    @success &= !multimedia_files_uploads.empty?
    if @success
      @design.save
      multimedia_files_uploads.each do |multimedia_file|
        multimedia_file = MultimediaFile.find(multimedia_file)
        multimedia_file.update_attributes(:proxy_id => @design.id,:proxy_type => @design.class.to_s)
      end
      multimedia_files_uploads_clear
      @design.associate_case(@order.caso)
      @design.send_notification_email
      flash[:notice] = "Diseño enviado satisfactoriamente al cliente #{@order.client.name}"
    else

    end
  end

	def digital_card
		@digital_card = DigitalCard.find(params[:digital_card_id])
		render :layout => "frontend/clear"
	end

  def show_tracker
    @order = Order.find_by_id(params[:order_id])
    @tracker = Tracker.find_by_id(params[:tracker_id])
    @trackers = User.find_all_for_orders_technicals
  end

  def reassign_tracker
    @order = Order.find_by_id(params[:order_id])
    tracker = Tracker.find_by_id(params[:tracker_id])
    tracker_name = tracker.name
    user = User.find_by_id((params[:user][:id]))
    if tracker.reassign_tracker(user)
      flash[:notice] = "Se ha reasignado el pedido #{@order.id} de #{tracker_name} a #{user.name}  de manera satisfactoria"
    else
      flash[:error] = "Se ha producido un error reasignando el pedido #{@order.id} del #{tracker.name} a #{user.name}"
    end
    
  end

  def show_design
    @order = Order.find_by_id(params[:order_id])
    @design = @order.caso.design
  end

  def new_decision_design
    @order = Order.find_by_id(params[:order_id])
    @design = @order.caso.design
    @notification = Notification.new
    render :layout => "backend/new_decision_design"
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
      #@notification.associate_case(@order.caso)
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

  def cancel
    @order = Order.find_by_id(params[:order_id])
    @order.update_attribute(:canceled, true)
  end

  protected

  def set_title
    @title = "Ordenes de Producción"
  end

  def multimedia_files_uploads=(multimedia_files_id)
    session[:orders_multimedia_files] = [] if session[:orders_multimedia_files].empty?
    session[:orders_multimedia_files] << multimedia_files_id
  end

  def multimedia_files_uploads
    session[:orders_multimedia_files] = [] if session[:orders_multimedia_files].empty?
    session[:orders_multimedia_files]
  end

  def multimedia_files_uploads_clear
    session[:orders_multimedia_files].clear
  end

  def multimedia_files_uploads_reset
    session[:orders_multimedia_files] = []
  end

  
end
