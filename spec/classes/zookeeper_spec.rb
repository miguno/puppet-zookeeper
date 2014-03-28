require 'spec_helper'

describe 'zookeeper' do
  context 'supported operating systems' do
    ['RedHat', 'Debian'].each do |osfamily|
      ['RedHat', 'CentOS', 'Amazon', 'Fedora', 'Ubuntu', 'Debian'].each do |operatingsystem|
        let(:facts) {{
          :osfamily        => osfamily,
          :operatingsystem => operatingsystem,
        }}

        default_configuration_file = '/etc/zookeeper/conf/zoo.cfg'

        describe "zookeeper class with default settings on #{osfamily}" do
          let(:params) {{ }}
          # We must mock $::operatingsystem because otherwise this test will
          # fail when you run the tests on e.g. Mac OS X.
          it { should compile.with_all_deps }

          it { should contain_class('zookeeper::params') }
          it { should contain_class('zookeeper::install').that_comes_before('zookeeper::config') }
          it { should contain_class('zookeeper::config') }
          it { should contain_class('zookeeper::service').that_subscribes_to('zookeeper::config') }

          it { should contain_package('zookeeper-server').with_ensure('present') }

          it { should contain_file('/var/lib/zookeeper').with({
            'ensure'       => 'directory',
            'owner'        => 'zookeeper',
            'group'        => 'zookeeper',
            'mode'         => '0755',
            'recurse'      => true,
            'recurselimit' => 0,
            'require'      => 'Package[zookeeper-server]',
          })}

          it { should_not contain_file('zookeeper-myid') }

          it { should contain_file('/usr/bin/zookeeper-server').with({
            'ensure'  => 'file',
            'source'  => "puppet:///modules/zookeeper/zookeeper-server",
            'owner'   => 'root',
            'group'   => 'root',
            'require' => 'Package[zookeeper-server]',
          })}

          it { should contain_file(default_configuration_file).
            with({
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => 'Class[Zookeeper::Install]',
            }).
            with_content(/^autopurge\.purgeInterval=24$/).
            with_content(/^autopurge\.snapRetainCount=5$/).
            with_content(/^clientPort=2181$/).
            with_content(/^dataDir=\/var\/lib\/zookeeper$/).
            with_content(/^initLimit=10$/).
            with_content(/^maxClientCnxns=50$/).
            with_content(/^syncLimit=5$/).
            with_content(/^tickTime=2000$/)
          }

        end

        describe "zookeeper class with a custom quorum on #{osfamily}" do
          let(:params) {{
            :quorum => ['server.1=zk1:2888:3888', 'server.2=zk2:2888:3888', 'server.3=zk3:2888:3888']
          }}

          it { should contain_file(default_configuration_file).
            with_content(/^server\.1=zk1:2888:3888$/).
            with_content(/^server\.2=zk2:2888:3888$/).
            with_content(/^server\.3=zk3:2888:3888$/)
          }

          it { should contain_file('zookeeper-myid').with({
            'ensure'       => 'file',
            'path'         => '/var/lib/zookeeper/myid',
            'owner'        => 'zookeeper',
            'group'        => 'zookeeper',
            'mode'         => '0644',
            'content'      => "1\n",
            'require'      => 'Class[Zookeeper::Install]',
          })}

          it { should contain_exec('zookeeper-initialize').with({
              'command' => 'service zookeeper-server init',
              'path'    => ['/usr/bin', '/usr/sbin', '/sbin', '/bin'],
              'user'    => 'root',
              'onlyif'  => 'test ! -d /var/lib/zookeeper/version-2 -o ! -s /var/lib/zookeeper/myid',
              'require' => [ 'Class[Zookeeper::Install]', 'Class[Zookeeper::Config]' ],
          })}

          it { should contain_exec('restart-zookeeper').with({
            'command'     => 'supervisorctl restart zookeeper',
            'path'        => ['/usr/bin', '/usr/sbin', '/sbin', '/bin'],
            'user'        => 'root',
            'refreshonly' => true,
            'subscribe'   => [ 'File[/etc/zookeeper/conf/zoo.cfg]', 'File[zookeeper-myid]' ],
            'onlyif'      => 'which supervisorctl &>/dev/null',
            'require'     => 'Class[Supervisor]',
          })}
        end

        describe "zookeeper class with quorum set to a string instead of an array on #{osfamily}" do
          let(:params) {{
            :quorum => 'server.1=zookeeper1:2888:3888,server.2=zookeeper2:2888:3888',
          }}
          it { expect { should contain_class('zookeeper') }.to raise_error(Puppet::Error,
            /"server.1=zookeeper1:2888:3888,server.2=zookeeper2:2888:3888" is not an Array.  It looks to be a String/)
          }
        end
        describe "Zookeeper class with package_origin something other than the Cloudera repo" do
          let(:params) { {:package_origin => 'Ant-package'} }
          it { should contain_exec('zookeeper-initialize').with({
            'command' => 'service zookeeper-server init',
            'path'    => ['/usr/bin', '/usr/sbin', '/sbin', '/bin'],
            'user'    => 'root',
            'onlyif'  => false,
            'require' => [ 'Class[Zookeeper::Install]', 'Class[Zookeeper::Config]' ],
          })}
        end
        describe "Zookeeper class with package name different than zookeeper-server" do
          let(:params) { {:package_name => 'zoo-keeper'} }
          it { should contain_exec('zookeeper-initialize').with({
            'command' => 'service zoo-keeper init',
            'path'    => ['/usr/bin', '/usr/sbin', '/sbin', '/bin'],
            'user'    => 'root',
            'onlyif'  => 'test ! -d /var/lib/zookeeper/version-2',
            'require' => [ 'Class[Zookeeper::Install]', 'Class[Zookeeper::Config]' ],
          })}
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'zookeeper class without any parameters on Debian' do
      let(:facts) {{
        :osfamily => 'Non-RHEL-non-Debian',
      }}

      it { expect { should contain_package('zookeeper') }.to raise_error(Puppet::Error,
        /The zookeeper module is not supported on a Non-RHEL-non-Debian based system./) }
    end
  end
end
