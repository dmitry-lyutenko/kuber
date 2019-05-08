INTENT_TYPE="internal-net"

MACHINES = {
  :"gw" => {
             :box_name => "centos/7",
             :net => [
                      {ip: '10.10.10.10', adapter: 2, netmask: "255.255.255.0"},
                      {ip: '10.12.12.1', adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: INTENT_TYPE},
                     ],
             :cpus => 1,
             :memory => 256,
             :default_gw => "10.10.10.1"
            },
  :"node1" => {
              :box_name => "centos/7",
              :net => [
                       #{ip: '10.10.10.11', adapter: 2, netmask: "255.255.255.0"},
                       {ip: '10.12.12.11', adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: INTENT_TYPE},
                      ],
              :cpus => 2,
              :memory => 1024
                    },
  :"node2" => {
              :box_name => "centos/7",
              :net => [
                       #{ip: '10.10.10.12', adapter: 2, netmask: "255.255.255.0"},
                       {ip: '10.12.12.12', adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: INTENT_TYPE},
                      ],
              :cpus => 2,
              :memory => 1024
             },
  :"node3" => {
              :box_name => "centos/7",
              :net => [
                       #{ip: '10.10.10.13', adapter: 2, netmask: "255.255.255.0"},
                       {ip: '10.12.12.13', adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: INTENT_TYPE},
                      ],
              :cpus => 2,
              :memory => 1024
             },
  :"master" => {
              :box_name => "centos/7",
              :net => [
                       #{ip: '10.10.10.10', adapter: 2, netmask: "255.255.255.0"},
                       {ip: '10.12.12.10', adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: INTENT_TYPE},
                      ],
              :cpus => 2,
              :memory => 2048
             }
}

hosts_file="127.0.0.1\tlocalhost\n"

MACHINES.each do |hostname,config|  
  config[:net].each do |ip|
    hosts_file=hosts_file+ip[:ip]+"\t"+hostname.to_s+"\n"
  end
end

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxname.to_s
      boxconfig[:net].each do |ipconf|
        box.vm.network "private_network", ipconf
      end
      if boxconfig.key?(:forwarded_port)
        boxconfig[:forwarded_port].each do |port|
          box.vm.network "forwarded_port", port
        end
      end
      box.vm.provider "virtualbox" do |v|
        v.memory = boxconfig[:memory]
        v.cpus = boxconfig[:cpus]
      end
      box.vm.provision "shell" do |shell|
        shell.inline = 'echo -e "$1" > /etc/hosts'
        shell.args = [hosts_file]
      end
      # Create user core with auth by key
      box.vm.provision "shell" do |shell|
        shell.inline = 'useradd -m core && cd /home/core && mkdir .ssh && cat /vagrant/id_core.pub > .ssh/authorized_keys && chmod -R 700 .ssh && chown -R core:core .ssh && echo "core        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/core'
      end
      if boxname.to_s =~ /(node\d|master)/
        box.vm.provision "shell" do |shell|          
          shell.inline = 'ip route del $(ip route | grep default) && ip route add default via "$1"'
          shell.args = [MACHINES[:gw][:net][1][:ip]]
        end
      end
      if boxname.to_s =~ /gw/
        box.vm.provision "shell" do |shell|          
          shell.inline = 'ip route del $(ip route | grep default) && ip route add default via "$1" && echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p'
          shell.args = [MACHINES[:gw][:default_gw]]
        end
      end      
    end
  end
end
