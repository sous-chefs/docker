shared_examples_for 'a docker image test environment' do

    describe docker_imag('docker-test-image') do
      it { should_not be_a_image }
    end

    describe docker_imag('busybox') do
      it { should be_a_image }
    end

    describe docker_imag('bflad/testcontainerd') do
      it { should be_a_image }
    end

    describe docker_imag('docker_image_build_1') do
      it { should_not be_a_image }
    end

    describe docker_imag('docker_image_build_2') do
      it { should be_a_image }
    end
end
