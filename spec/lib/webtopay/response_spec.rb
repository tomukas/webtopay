# coding: UTF-8
require 'spec_helper'

describe WebToPay::Response do
  let(:response_data) {
    {
      "data" => "cHJvamVjdGlkPTQzMjcyJm9yZGVyaWQ9MSZhbW91bnQ9MTQwMCZwX2VtYWlsPWJsb29tcmFpbiU0MGdtYWlsLmNvbSZwX25hbWU9VG9tYXMmcF9zdXJuYW1lPUJ1dGtldmljaXVzJnBheW1lbnQ9dmIyJnRlc3Q9MSZ2ZXJzaW9uPTEuNiZ0eXBlPUVNQSZsYW5nPSZjdXJyZW5jeT1MVEwmcGF5dGV4dD1VJUM1JUJFc2FreW1hcytuciUzQSsxK2h0dHAlM0ElMkYlMkZsb2NhbGhvc3QrcHJvamVrdGUuKyUyOFBhcmRhdiVDNCU5N2phcyUzQStQb3ZpbGFzK0p1ciVDNCU4RHlzJTI5JmNvdW50cnk9TFQmX2NsaWVudF9sYW5ndWFnZT1saXQmc3RhdHVzPTEmcmVxdWVzdGlkPTUzODgwMzk0Jm5hbWU9VUFCJnN1cmVuYW1lPU1vayVDNCU5N2ppbWFpLmx0JnBheWFtb3VudD0xNDAwJnBheWN1cnJlbmN5PUxUTA==",
      "ss1" => "d7fbde5cb3fcfc8f55a8737621f70b02",
      "ss2" => "fBplGfKCAGOxqEd9GjheT3psaivT34sO0CcupPSQgQNqZkcbgUxtCk06j7oUiAMG_jLBuqsUs55TsD1z2eAXMY4N8Pcbqf6dQ7xOHvpshcvkAzXu3n9JHspxvEGR7Mgbv6etb0DvpEtBR9WClQTnhQbSmnCkDaCSOtn3l0ACSYI="
    }
  }

  subject{ WebToPay::Response.new(response_data, { projectid: 43272, sign_password: 'bd842a6ef17060c1bd6d096085dc8e40'}) }

  describe '#valid?' do
    context 'when fields does not match' do
      let(:validation_params) { { amount: 999, p_email: "foo@bar.baz" } }
      it 'returns false' do
        subject.valid?(validation_params).should be_false
      end
      it 'adds errors' do
        expect {
          subject.valid?(validation_params)
        }.to change{ subject.errors.size }.from(0).to(2)
      end
    end
  end

  its(:query){ should == "projectid=43272&orderid=1&amount=1400&p_email=bloomrain%40gmail.com&p_name=Tomas&p_surname=Butkevicius&payment=vb2&test=1&version=1.6&type=EMA&lang=&currency=LTL&paytext=U%C5%BEsakymas+nr%3A+1+http%3A%2F%2Flocalhost+projekte.+%28Pardav%C4%97jas%3A+Povilas+Jur%C4%8Dys%29&country=LT&_client_language=lit&status=1&requestid=53880394&name=UAB&surename=Mok%C4%97jimai.lt&payamount=1400&paycurrency=LTL" }
  its(:query_params){ should == {
    "_client_language" => "lit",
    "amount" => "1400",
    "country" => "LT",
    "currency" => "LTL",
    "lang" => "",
    "name" => "UAB",
    "orderid" => "1",
    "p_email" => "bloomrain@gmail.com",
    "p_name" => "Tomas",
    "p_surname" => "Butkevicius",
    "payamount" => "1400",
    "paycurrency" => "LTL",
    "payment" => "vb2",
    "paytext" => "Užsakymas nr: 1 http://localhost projekte. (Pardavėjas: Povilas Jurčys)",
    "projectid" => "43272",
    "requestid" => "53880394",
    "ss1" => "d7fbde5cb3fcfc8f55a8737621f70b02",
    "ss2" => "fBplGfKCAGOxqEd9GjheT3psaivT34sO0CcupPSQgQNqZkcbgUxtCk06j7oUiAMG_jLBuqsUs55TsD1z2eAXMY4N8Pcbqf6dQ7xOHvpshcvkAzXu3n9JHspxvEGR7Mgbv6etb0DvpEtBR9WClQTnhQbSmnCkDaCSOtn3l0ACSYI=",
    "status" => "1",
    "surename" => "Mokėjimai.lt",
    "test" => "1",
    "type" => "EMA",
    "version" => "1.6"
  } }

  its(:valid?){ should be_true }
end