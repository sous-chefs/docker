# var
caroot = '/tmp/kitchen/tls'

# CA skeleton
directory "#{caroot}" do
  action :create
end

bash 'creating PKI index file' do
  code "/bin/touch #{caroot}/index.txt"
  not_if "/usr/bin/test -f #{caroot}/index.txt"
  action :run
end

bash 'starting PKI serial file' do
  code "/bin/echo '01' > #{caroot}/serial"
  not_if "/usr/bin/test -f #{caroot}/serial"
  action :run
end

bash 'starting crlnumber' do
  code "echo '01' > #{caroot}/ca.srl"
  not_if "/usr/bin/test -f #{caroot}/ca.srl"
  action :run
end

# Self sicned CA
bash 'generating CA private key' do
  cmd = 'openssl req'
  cmd += ' -x509'
  cmd += ' -nodes'
  cmd += ' -days 3650'
  cmd += " -subj '/O=kitchen2docker/'"
  cmd += ' -newkey rsa:2048'
  cmd += " -keyout #{caroot}/cakey.pem"
  cmd += " -out #{caroot}/ca.pem"
  cmd += ' 2>&1>/dev/null'
  code cmd
  not_if "/usr/bin/test -f #{caroot}/cakey.pem"
  not_if "/usr/bin/test -f #{caroot}/ca.pem"
  action :run
end

# server certs
bash 'creating private key for docker server' do
  code "openssl genrsa -out #{caroot}/serverkey.pem 2048"
  not_if "/usr/bin/test -f #{caroot}/serverkey.pem"
  action :run
end

bash 'generating certificate request for server' do
  cmd = 'openssl req'
  cmd += ' -new'
  cmd += ' -nodes'
  cmd += " -subj '/O=kitchen2docker/'"
  cmd += " -key #{caroot}/serverkey.pem"
  cmd += " -out #{caroot}/server.csr"
  code cmd
  only_if "/usr/bin/test -f #{caroot}/serverkey.pem"
  not_if "/usr/bin/test -f #{caroot}/server.csr"
  action :run
end

file "#{caroot}/server-extfile.cnf" do
  content "subjectAltName = IP:#{node['ipaddress']},IP:127.0.0.1\n"
  action :create
end

bash 'signing request for server' do
  cmd = 'openssl x509'
  cmd += ' -req'
  cmd += " -CA #{caroot}/ca.pem"
  cmd += " -CAkey #{caroot}/cakey.pem"
  cmd += " -in #{caroot}/server.csr"
  cmd += " -out #{caroot}/server.pem"
  cmd += " -extfile #{caroot}/server-extfile.cnf"
  not_if "/usr/bin/test -f #{caroot}/server.pem"
  code cmd
  action :run
end

# client certs
bash 'creating private key for docker client' do
  code "openssl genrsa -out #{caroot}/key.pem 2048"
  not_if "/usr/bin/test -f #{caroot}/key.pem"
  action :run
end

bash 'generating certificate request for client' do
  cmd = 'openssl req'
  cmd += ' -new'
  cmd += ' -nodes'
  cmd += " -subj '/O=kitchen2docker/'"
  cmd += " -key #{caroot}/key.pem"
  cmd += " -out #{caroot}/cert.csr"
  code cmd
  only_if "/usr/bin/test -f #{caroot}/key.pem"
  not_if "/usr/bin/test -f #{caroot}/cert.csr"
  action :run
end

file "#{caroot}/client-extfile.cnf" do
  content "extendedKeyUsage = clientAuth\n"
  action :create
end

bash 'signing request for client' do
  cmd = 'openssl x509'
  cmd += ' -req'
  cmd += " -CA #{caroot}/ca.pem"
  cmd += " -CAkey #{caroot}/cakey.pem"
  cmd += " -in #{caroot}/cert.csr"
  cmd += " -out #{caroot}/cert.pem"
  cmd += " -extfile #{caroot}/client-extfile.cnf"
  code cmd
  not_if "/usr/bin/test -f #{caroot}/cert.pem"
  action :run
end

# start docker service listening on TCP port
docker_service 'tls_test:2376' do
  host 'tcp://127.0.0.1:2376'
  tlscacert "#{caroot}/ca.pem"
  tlscert "#{caroot}/server.pem"
  tlskey "#{caroot}/serverkey.pem"
  tlsverify true
  # provider Chef::Provider::DockerService::Execute
  action [:create, :start]
end
