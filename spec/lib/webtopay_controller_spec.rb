require 'spec_helper'

describe PaymentsController, type: :controller do

  describe '.webtopay' do
    it 'ignores methods that are not mentioned on webtopay actions list' do
      get :index

      # if webtopay is not ignored then then we should get message "'projectid' is required but missing." with 500 status code
      response.should be_success 
    end

    context "when webtopay params are missing" do
      it 'should not be successfull' do
        get :order
        response.should_not be_success  
      end

      it 'displays error message' do
        expect { get :order }.to raise_error('"projectid" is invalid. Expected "12345", but was ""')
      end
    end
    
  end
end