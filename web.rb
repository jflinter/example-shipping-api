require 'sinatra'
require 'easypost'
require 'dotenv'
Dotenv.load

EasyPost.api_key = ENV['EASYPOST_API_KEY']

get '/rates' do
  content_type :json

  toAddress = {
    :street1 => params[:address],
    :city =>    params[:city],
    :state =>   params[:state],
    :zip =>     params[:zip],
    :country => params[:country]
  }

  fromAddress = {
    :company => 'EasyPost',
    :street1 => '164 Townsend Street',
    :street2 => 'Unit 1',
    :city => 'San Francisco',
    :state => 'CA',
    :zip => '94107',
    :phone => '415-528-7555'
  }

  parcel = {
    :length => 9,
    :width => 6,
    :height => 2,
    :weight => 10
  }

  shipment = EasyPost::Shipment.create(
    :to_address => toAddress,
    :from_address => fromAddress,
    :parcel => parcel
  )

  shipment.rates.map do |rate|

    # Annoyingly, we don't have very good information here in testmode, so we'll just make up a value. cc @easypost :)
    arrival_days_from_now = (((rate.carrier + rate.service).hash) % shipment.rates.count) + 1
    arrival_date = Time.now + arrival_days_from_now * (60*60*24)
    formatted_arrival_date = arrival_date.strftime("Will arrive by %A, %b %-e")

    {
      :id => rate.id,
      :carrier => rate.carrier,
      :service => rate.service,
      :amount => rate.rate,
      :currency => rate.currency,
      :formatted_arrival_date => formatted_arrival_date
    }
  end.to_json

end
