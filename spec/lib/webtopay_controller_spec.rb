require 'spec_helper'

describe PaymentsController, type: :controller do

  describe '.webtopay' do
    it 'shoud fail' do
      get :order
      response.should be_successfull
    end
  end
end