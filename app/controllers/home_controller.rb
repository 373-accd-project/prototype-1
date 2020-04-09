require 'rest_client'
require 'json'
require 'csv'
# require '../services/json_manager'
class HomeController < ApplicationController
  def index
  end
  def download_csv
    temp_read = IO.read("csv_files/temp.csv")
    # p "Hello!"
    # p file
    # send_data('Hello, pretty world :(', :type => 'text/plain', :disposition => 'attachment', :filename => 'hello.txt')
    # send_data file, :type => 'text/csv; charset=iso-8859-1; header=present', :filename => "data.csv"
    puts "Read!"
    send_data temp_read, :type => 'text/csv; charset=iso-8859-1; header=present', :filename => "data.csv"

  end
end
