class Backend::ReportsController < Backend::BaseController

  def index
    
  end


  def report_1
    @reports = {}
#    invoices = Invoice.all(:conditions => ["DATE_FORMAT(updated_at,'%Y') >= ?",Time.now.year - AppConfig.get_value_by_name("REPORT_PREVIEWS_YEAR").to_i])

    invoices = Invoice.find_by_sql("SELECT * FROM invoice_last_years")


      @reports["Total"] = invoices.collect{|x| [ Date.strptime("{ #{x['date']} }", "{ %Y-%m-%d }").to_time.to_i*1000, (x["total"]).to_f.round(2)/100] }
      @reports["SubTotal"] = invoices.collect{|x| [Date.strptime("{ #{x['date']} }", "{ %Y-%m-%d }").to_time.to_i*1000,(x["subtotal"]).to_f.round(2)/100] }
      @reports["IVA"] = invoices.collect{|x| [Date.strptime("{ #{x['date']} }", "{ %Y-%m-%d }").to_time.to_i*1000,(x["total"]).to_f.round(2)/25] }
    
#
#    @reports["SubTotal"] = [
#                            [Date.new(2012,1,2).to_time.to_i*1000,12.3],
#                            [Date.new(2012,1,3).to_time.to_i*1000,5.3],
#                            [Date.new(2012,1,4).to_time.to_i*1000,36.3],
#                            [Date.new(2012,1,5).to_time.to_i*1000,45.3]
#                            ]

  end

  def export_report_1
    respond_to do |format|
      format.xls { send_data Invoice.all(:order => "created_at asc").to_xls,:filename => "resumen_facturación_mes.xls" }
    end
  end

  def report_1
    @reports = {}
    invoices = Invoice.find_by_sql("SELECT * FROM invoice_last_years")

      @reports["Total"] = invoices.collect{|x| [ Date.strptime("{ #{x['date']} }", "{ %Y-%m-%d }").to_time.to_i*1000, (x["total"]).to_f.round(2)/100] }
      @reports["SubTotal"] = invoices.collect{|x| [Date.strptime("{ #{x['date']} }", "{ %Y-%m-%d }").to_time.to_i*1000,(x["subtotal"]).to_f.round(2)/100] }
      @reports["IVA"] = invoices.collect{|x| [Date.strptime("{ #{x['date']} }", "{ %Y-%m-%d }").to_time.to_i*1000,(x["total"]).to_f.round(2)/25] }
  end

  def report_2
    
  end

  def export_report_2
    respond_to do |format|
      format.xls { send_data Invoice.all(:order => "created_at asc").to_xls(:report => "2"),:filename => "resumen_facturación_mes.xls" }
    end
  end

  def report_3
    
  end

  def export_report_4
    respond_to do |format|
      format.xls { send_data Invoice.all(:order => "created_at asc").to_xls(:report => "4"),:filename => "resumen_facturación_mes.xls" }
    end
  end

  def report_5
      @reports = {}
#    invoices = Invoice.all(:conditions => ["DATE_FORMAT(updated_at,'%Y') >= ?",Time.now.year - AppConfig.get_value_by_name("REPORT_PREVIEWS_YEAR").to_i])

    invoices = Invoice.find_by_sql("SELECT * FROM invoice_last_years")


      @reports["Total"] = invoices.collect{|x| [ Date.strptime("{ #{x['date']} }", "{ %Y-%m-%d }").to_time.to_i*1000, (x["total"]).to_f.round(2)/100] }
      @reports["SubTotal"] = invoices.collect{|x| [Date.strptime("{ #{x['date']} }", "{ %Y-%m-%d }").to_time.to_i*1000,(x["subtotal"]).to_f.round(2)/100] }
      @reports["IVA"] = invoices.collect{|x| [Date.strptime("{ #{x['date']} }", "{ %Y-%m-%d }").to_time.to_i*1000,(x["total"]).to_f.round(2)/25] }

#
#    @reports["SubTotal"] = [
#                            [Date.new(2012,1,2).to_time.to_i*1000,12.3],
#                            [Date.new(2012,1,3).to_time.to_i*1000,5.3],
#                            [Date.new(2012,1,4).to_time.to_i*1000,36.3],
#                            [Date.new(2012,1,5).to_time.to_i*1000,45.3]
#                            ]

  end

  def report_6
    
  end
  protected

  def set_title
    @title = "Reportes"
  end

end
