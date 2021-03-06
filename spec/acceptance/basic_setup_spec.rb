require 'spec_helper_acceptance'

describe 'logstash class' do

  context 'basic setup ' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'logstash': }

      logstash::input::tcp { 'tcp-1234':
        port => '1234',
      }

      logstash::input::syslog { 'syslog': }

      logstash::input::redis { 'redis': }

      logstash::input::file { 'files':
        paths => [ '/var/log/messages', '/var/log/syslog' ],
      }

      logstash::output::elasticsearch { 'elasticsearch': }

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)

    end

    describe file("/etc/logstash/conf.d/00_input.conf") do
      it { should be_file }
      its(:content) { should match 'tcp' }
      its(:content) { should match 'syslog' }
      its(:content) { should match 'redis' }
      its(:content) { should match 'file' }
    end

    describe file("/etc/logstash/conf.d/99_output.conf") do
      it { should be_file }
      its(:content) { should match 'elasticsearch' }
    end

  end

end
