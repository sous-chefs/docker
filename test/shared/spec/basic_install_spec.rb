shared_examples_for 'a basic docker installation' do
  describe service('docker') do 
    it { should be_running }
  end
end
