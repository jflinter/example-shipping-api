require 'sinatra'
require 'EasyPost'
require 'dotenv'
Dotenv.load

EasyPost.api_key = ENV['EASYPOST_API_KEY']

get '/rates' do
  content_type :json

  toAddress = {
    :street1 => params[:address_line1],
    :street2 => params[:address_line2],
    :city =>    params[:city],
    :state =>   params[:state],
    :zip =>     params[:zip],
    :country => params[:country],
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
    {
      :carrier => rate.carrier,
      :service => rate.service,
      :amount => rate.rate,
      :currency => rate.currency,
    }
  end.to_json

end
