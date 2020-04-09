require 'rest_client'
require 'json'
require 'csv'

class LaunempController < ApplicationController
  def index
    if params.has_key?(:year)
      generated_id = "LAU" + params[:area]
      generated_id = generated_id + params[:measure]
      @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
      parsed_json = JSON(@manager.apiCall(generated_id, 2010, 2020))
      @reply = parsed_json
      IO.write("csv_files/temp.csv", parsed_json)

      # Store filters in session hash so that any subsequent downlaod requests
      # have access to them
      # session[:area_code] = params[:area_code]
      # session[:datatype] = params[:datatype]
      # session[:size] = params[:size]
      # session[:ownership] = params[:ownership]
      # session[:industry] = params[:industry]
    end

    # Read the fitlers from the CSV file
    @area_types = CSV.read('csv_files/la_unemployment/la.area_type.txt', {col_sep: "\t"})[1..]
    @areas = CSV.read('csv_files/la_unemployment/la.area.txt', {col_sep: "\t"})[1..]
    @measures = CSV.read('csv_files/la_unemployment/la.measure.txt', {col_sep: "\t"})[1..]

    # Switch the key-value pairs to make sure that the correct one appears
    # in the drop down for each filter
    for area_type in @area_types do
      tmp = area_type[0]
      area_type[0] = area_type[1]
      area_type[1] = tmp
    end
    for area in @areas do
      area.slice!(0)
      area.slice!(2..)

      tmp = area[0]
      area[0] = area[1]
      area[1] = tmp
      p area
    end
    for measure in @measures do
      tmp = measure[0]
      measure[0] = measure[1]
      measure[1] = tmp
    end
  end
  def download_csv
    # @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
    # generated_id = "ENU" + session[:area_code] + session[:datatype] + session[:size] + session[:ownership] + session[:industry]
    # puts generated_id
    # parsed_json = JSON(@manager.apiCall(:generated_id, 2010, 2020))
    # @reply = parsed_json['Results']['series'][0]['data']

    # # Create a file that can be sent to the client browser as a download
    # file = CSV.generate do |csv|
    #   @reply.each do |hash|
    #     csv << hash.values
    #   end
    # end
    # send_data file, :type => 'text/csv; charset=iso-8859-1; header=present', :filename => "data.csv"
  end
end
