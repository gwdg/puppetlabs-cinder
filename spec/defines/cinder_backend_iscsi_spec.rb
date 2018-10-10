require 'spec_helper'

describe 'cinder::backend::iscsi' do

  let(:title) {'hippo'}

  let :req_params do {
    :iscsi_ip_address => '127.0.0.2',
    :iscsi_helper => 'tgtadm',
  }
  end

  let :facts do
    OSDefaults.get_facts({
      :osfamily => 'Debian',
      :os       => { :name  => 'Debian', :family => 'Debian', :release => { :major => '8', :minor => '0' } },
    })
  end

  let :params do
    req_params
  end

  let :iser_params do
    {:iscsi_protocol => 'iser'}
  end

  let :volumes_dir_params do
    {:volumes_dir => '/etc/cinder/volumes'}
  end

  describe 'with default params' do

    it 'should configure iscsi driver' do
      is_expected.to contain_cinder_config('hippo/volume_backend_name').with(
        :value => 'hippo')
      is_expected.to contain_cinder_config('hippo/backend_availability_zone').with(
        :value => '<SERVICE DEFAULT>')
      is_expected.to contain_cinder_config('hippo/volume_driver').with(
        :value => 'cinder.volume.drivers.lvm.LVMVolumeDriver')
      is_expected.to contain_cinder_config('hippo/iscsi_ip_address').with(
        :value => '127.0.0.2')
      is_expected.to contain_cinder_config('hippo/iscsi_helper').with(
        :value => 'tgtadm')
      is_expected.to contain_cinder_config('hippo/volume_group').with(
        :value => '<SERVICE DEFAULT>')
      is_expected.to contain_cinder_config('hippo/volumes_dir').with(
        :value => '/var/lib/cinder/volumes')
      is_expected.to contain_cinder_config('hippo/iscsi_protocol').with(
        :value => '<SERVICE DEFAULT>')
    end
  end

  describe 'with iser protocol' do
    before :each do
      params.merge!(iser_params)
    end

    it 'should configure iscsi driver with iser protocol' do
      is_expected.to contain_cinder_config('hippo/iscsi_protocol').with(
        :value => 'iser')
    end
  end

  describe 'with non-default $volumes_dir' do
    before :each do
      params.merge!(volumes_dir_params)
    end

    it 'should configure iscsi driver with /etc/cinder/volumes as volumes_dir' do
      is_expected.to contain_cinder_config('hippo/volumes_dir').with(
        :value => '/etc/cinder/volumes'
      )
    end
  end

  describe 'iscsi backend with cinder type' do
    before :each do
      params.merge!({:manage_volume_type => true})
    end
    it 'should create type with properties' do
      should contain_cinder_type('hippo').with(:ensure => :present, :properties => ['volume_backend_name=hippo'])
    end
  end

  describe 'iscsi backend with additional configuration' do
    before :each do
      params.merge!({:extra_options => {'hippo/param1' => {'value' => 'value1'}}})
    end

    it 'configure iscsi backend with additional configuration' do
      is_expected.to contain_cinder_config('hippo/param1').with({
        :value => 'value1',
      })
    end
  end

  describe 'with RedHat' do

    let :facts do
      OSDefaults.get_facts({
        :osfamily => 'RedHat',
        :os       => { :name  => 'CentOS', :family => 'RedHat', :release => { :major => '7', :minor => '0' } },
      })
    end

    it { is_expected.to contain_file_line('cinder include').with(
      :line => 'include /var/lib/cinder/volumes/*',
      :path => '/etc/tgt/targets.conf'
    ) }

  end
end
