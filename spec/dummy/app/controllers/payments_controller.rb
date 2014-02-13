class PaymentsController < ApplicationController
  webtopay :order

  def index
    render text: 'it\'s index'
  end

  def order
    render text: 'ok'
  end
end