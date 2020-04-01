require 'rest_client'
require 'json'
require 'csv'

# <%= select_tag(:seasonal_adjustment_code, options_for_select(@seasonal_adjustment_codes)) %><br/><br/>
# <%= select_tag(:occupation_code, options_for_select(@occupation_codes)) %><br/><br/>
# <%= select_tag(:industry_code, options_for_select(@industry_codes)) %><br/><br/>
# <%= select_tag(:area_code, options_for_select(@area_codes)) %><br/><br/>
# <%= select_tag(:area_type_code, options_for_select(@area_type_codes)) %><br/>
# <%= select_tag(:data_type_code, options_for_select(@data_type_codes)) %><br/>



class OesController < ApplicationController
  def index
    if params.has_key?(:year)
      generated_id = "ENU" + params[:area_code]
      generated_id = generated_id + params[:datatype]
      generated_id = generated_id + params[:size]
      generated_id = generated_id + params[:ownership]
      generated_id = generated_id + params[:industry]
      @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
      parsed_json = JSON(@manager.apiCall(generated_id, 2010, 2020))
      @reply = parsed_json
      session[:area_code] = params[:area_code]
      session[:datatype] = params[:datatype]
      session[:size] = params[:size]
      session[:ownership] = params[:ownership]
      session[:industry] = params[:industry]
    end

    @area_codes = CSV.read('csv_files/qcew/area_titles.csv')[1..]
    @data_types = CSV.read('csv_files/qcew/datatype_titles.csv')[1..]
    @industries = CSV.read('csv_files/qcew/industry_titles.csv')[1..]
    @ownership = CSV.read('csv_files/qcew/ownership_titles.csv')[1..]
    @sizes = CSV.read('csv_files/qcew/size_titles.csv')[1..]
    
    for area_code in @area_codes do
      tmp = area_code[0]
      area_code[0] = area_code[1]
      area_code[1] = tmp
    end
    for data_type in @data_types do
      tmp = data_type[0]
      data_type[0] = data_type[1]
      data_type[1] = tmp
    end
    for industry in @industries do
      tmp = industry[0]
      industry[0] = industry[1]
      industry[1] = tmp
    end
    for ownership in @ownership do
      tmp = ownership[0]
      ownership[0] = ownership[1]
      ownership[1] = tmp
    end
    for size in @sizes do
      tmp = size[0]
      size[0] = size[1]
      size[1] = tmp
    end
  end
  def download_csv
    @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
    generated_id = "ENU" + session[:area_code] + session[:datatype] + session[:size] + session[:ownership] + session[:industry]
    puts generated_id
    parsed_json = JSON(@manager.apiCall(:generated_id, 2010, 2020))
    @reply = parsed_json['Results']['series'][0]['data']
    file = CSV.generate do |csv|
      @reply.each do |hash|
        csv << hash.values
      end
    end
    # p "Hello!"
    # p file
    # send_data('Hello, pretty world :(', :type => 'text/plain', :disposition => 'attachment', :filename => 'hello.txt')
    send_data file, :type => 'text/csv; charset=iso-8859-1; header=present', :filename => "data.csv"
  end
end
