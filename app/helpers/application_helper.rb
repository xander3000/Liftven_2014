# Methods added to this helper will be available to all templates in the application.
include ActionView::Helpers::PrototypeHelper
include ActionView::Helpers::UrlHelper

module ApplicationHelper
  def include_javascript(javascript,options = {})
    content_for :head_javascript, javascript_include_tag(javascript,options)
  end

  def include_stylesheet(stylesheet,options = {})
    content_for :head_stylesheet, stylesheet_link_tag(stylesheet,options)
  end

  def globals
    @GLOBALS
  end

  def site_url
    @GLOBALS.SITE_URL
  end

  def css_globals
    @GLOBALS.ASSETS.CSS
  end

  def scripts_globals
    @GLOBALS.ASSETS.SCRIPTS
  end

	def render_topnav_menunav
			path = controller.controller_path.split("/")
			path.pop

		  render :partial => "shared/#{path.join("/")}/menunav"
	end


  def current_locale
    I18n.locale
  end
  
  def format_code(code,format="010")
    "%#{format}d" % code
  end

  def is_active_nav?(controller_name)
    controller.controller_name.eql?(controller_name) ? "active" : ""
  end

  def form_layout(options = {},&block)
		options[:container_id] ||= controller.controller_name
    block_to_partial("shared/layouts/form",options,true,&block)
  end

  def block_to_partial(partial_name, options = {}, include_body = true, &block)
    if include_body
      options.merge!(:body => capture(&block)) if block_given?
    else
      capture(&block) if block_given?
    end
    if block_given?
      concat(render(:partial => partial_name, :locals => options))
    else
      render :partial => partial_name, :locals => options
    end
  end

  def print_to(url,options={})
    render :partial => "shared/layouts/widget_print_to", :locals => {:options => options,:url => url}
  end

	def generate_qrcode(code)
		qr = RQRCode::QRCode.new(code, :size => 4, :level => :h )
		png = qr.to_img
		qr_filepath = "#{RAILS_ROOT}/public/images"
		qr_tempfile = "tmp/qrcodes"
		qr_filename = "#{Time.now.to_i + rand(99)}.png"
		qr_savefile = "#{qr_filepath}/#{qr_tempfile}/"
		FileUtils.mkdir_p(qr_savefile) unless File.exist?(qr_savefile)
		@qr_source = "#{qr_tempfile}/#{qr_filename}"
		png.resize(90, 90).save("#{qr_savefile}#{qr_filename}")
		@qr_source
	end
    




  alias old_remote_function remote_function
  def remote_function(options = {})
    loading = {:x => 450, :y => 10}
    unless options[:loading].nil?
      unless options[:loading][:x].nil?
        loading[:x] = options[:loading][:x]
        options[:loading].delete(:x)
      end
      unless options[:loading][:y].nil?
        loading[:y] = options[:loading][:y]
        options[:loading].delete(:y)
      end
    end

    before = options[:before].nil? ? "" : options[:before]
    success = options[:success].nil? ? "" : options[:success]
  
    options[:before] = "$('#loading').show();"
    #options[:success] = "$('#loading').hide('slow');resizeAllSelect();"
		options[:success] = "$('#loading').hide('slow');resizeAllSelect();"

#    options[:before] = "if ($('#loading')){ $('#loading').style.top = '#{loading[:y]}px'; $('loading').style.left = '#{loading[:x]}px'; Element.show('loading'); } #{before}"
#    options[:success] = "if ($('loading')){ Element.hide('loading'); } #{success}"

    old_remote_function options
  end


	#####################################
	########OVERRIDE LINK_TO ############
	#####################################
	alias old_link_to link_to
  def link_to(*args, &block)
    old_link_to(*args, &block)
  end


	#######################################33
	def shoppping_cart_count
    self.current_cart.size
  end


	#############################################

  def translate_status(status)
    I18n.t "order.labels.status.#{status}"
  end

  def count_active_orders
    Order.count_by_user_for_selection(current_user)
  end

end


