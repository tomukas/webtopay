class PaymentsController < ApplicationController
  webtopay :order

  def order
    render text: 'ok'
  end
end