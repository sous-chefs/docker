shared_examples_for 'a docker container test environment' do
  describe docker_container('busybox', 'sleep 1111') do
    it { should be_a_container }
    it { should be_running }
  end

  describe docker_container('busybox', 'sleep 2222') do
    it { should be_a_container }
    it { should be_running }
  end

  describe docker_container('busybox', 'sleep 3333') do
    it { should be_a_container }
    it { should_not be_running }
  end

  describe docker_container('busybox', 'sleep 4444') do
    it { should be_a_container }
    it { should be_running }
  end

  describe docker_container('busybox', 'sleep 5555') do
    it { should_not be_a_container }
    it { should_not be_running }
  end

  describe docker_container('busybox', 'sleep 7777') do
    it { should_not be_a_container }
    it { should_not be_running }
  end

  describe docker_container('busybox', 'sleep 8888') do
    it { should be_a_container }
    it { should be_running }
  end

  describe docker_container('bflad/testcontainerd') do
    it { should be_a_container }
    it { should be_running }
  end
end
