require 'rest_client'
require 'json'
class HomeController < ApplicationController
  def index
    if params.has_key?(:series_id)
      url = 'https://api.bls.gov/publicAPI/v1/timeseries/data/'
      response = RestClient.post(url,
                            {'seriesid' => [params[:series_id]],
                              'startyear' => '2010',
                              'endyear' => '2020',
                              'registrationKey' => "8d6999649c42476c914b6d535d678ef5"
                            }.to_json,
                            :content_type => 'application/json')
      parsed_json = JSON(response)
      @reply = parsed_json
    end
  end
end
