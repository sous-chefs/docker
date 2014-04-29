shared_examples_for 'a docker image test environment' do

  describe docker_image('docker-test-image') do
    it { should_not be_an_image }
  end

  describe docker_image('busybox') do
    it { should be_an_image }
  end

  describe docker_image('bflad/testcontainerd') do
    it { should be_an_image }
  end

  describe docker_image('docker_image_build_1') do
    it { should_not be_an_image }
  end

  describe docker_image('docker_image_build_2') do
    it { should be_an_image }
  end

end
