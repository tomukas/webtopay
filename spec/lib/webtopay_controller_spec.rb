require 'spec_helper'

describe PaymentsController, type: :controller do

  describe '.webtopay' do
    it 'shoud work' do
      expect { get :order }.to_not raise_error
    end
  end
end