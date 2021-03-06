require './lib/atm.rb'

describe Atm do
    let(:account) { instance_double('Account', pin_code: '1234', exp_date: '04/21', account_status: :active) }

    before do
      allow(account).to receive(:balance).and_return(100)
      allow(account).to receive(:balance=)
    end

    it 'has 1000$ on initialize' do
        expect(subject.funds).to eq 1000
    end

    it 'funds are reduced at withdraw' do 
        subject.withdraw(50, '1234', account)
        expect(subject.funds).to eq 950
    end

    it 'allow withdraw if the account has enough balance' do
        expected_output = { status: true, message: 'Successful', date: Date.today, amount: 95, bills: [20, 20, 20, 20, 10, 5] }
        expect(subject.withdraw(95, '1234', account)).to eq expected_output
    end
    
    it 'rejects withdraw if the account has insufficient funds' do
        expected_output = { status: false, message: 'Unsuccessful because of insufficient funds', date: Date.today }
        expect(subject.withdraw(105, '1234', account)).to eq expected_output   
    end
    
    it 'reject withdraw if ATM has insufficient funds' do
        subject.funds = 50
        expected_output = { status: false, message: 'Unsuccessful because insufficient funds in ATM', date: Date.today }
        expect(subject.withdraw(100, '1234', account)).to eq expected_output
    end

    it 'reject withdraw because the pin is wrong' do
        expected_output = { status: false, message: 'Unsuccessful because of wrong pin code', date: Date.today }
        expect(subject.withdraw(100, '1235', account)).to eq expected_output
    end 

    it 'reject the withdraw if the card is expired' do 
        allow(account).to receive(:exp_date).and_return('12/15')
        expected_output = { status: false, message: 'Unsuccessful because card has expired', date: Date.today }
        expect(subject.withdraw(20, '1234', account)).to eq expected_output
    end

    it 'reject withdraw if the account is inactive' do
        allow(account).to receive(:account_status).and_return(:inactive)
        expected_output = { status: false, message: 'Unsuccessful because the account is inactive', date: Date.today }
        expect(subject.withdraw(20, '1234', account)).to eq expected_output
    end

end