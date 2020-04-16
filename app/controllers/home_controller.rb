require 'rest_client'
require 'json'
require 'csv'

class HomeController < ApplicationController
  def index
  end

  def download_csv
    temp_read = IO.read("csv_files/temp.csv")
    puts "Read!"
    send_data temp_read, :type => 'text/csv; charset=iso-8859-1; header=present', :filename => "datapull_#{Time.now.strftime("%y-%m-%d_%I-%M")}.csv"
  end
  
end
