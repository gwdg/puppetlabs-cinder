require 'spec_helper'

describe 'cinder::backend::quobyte' do

  shared_examples_for 'quobyte volume driver' do
    let(:title) {'myquobyte'}

    let :params do
      {
	:quobyte_volume_url      => 'quobyte://quobyte.cluster.example.com/volume-name',
        :quobyte_qcow2_volumes   => false,
        :quobyte_sparsed_volumes => true,
      }
    end

    it 'configures quobyte volume driver' do
      is_expected.to contain_cinder_config('myquobyte/volume_driver').with_value(
        'cinder.volume.drivers.quobyte.QuobyteDriver')
      is_expected.to contain_cinder_config('myquobyte/quobyte_volume_url').with_value(
        'quobyte://quobyte.cluster.example.com/volume-name')
      is_expected.to contain_cinder_config('myquobyte/quobyte_qcow2_volumes').with_value(
        false)
      is_expected.to contain_cinder_config('myquobyte/quobyte_sparsed_volumes').with_value(
        true)
    end

    context 'quobyte backend with cinder type' do
      before do
        params.merge!({:manage_volume_type => true})
      end
      it 'should create type with properties' do
        should contain_cinder_type('myquobyte').with(:ensure => :present, :properties => ['volume_backend_name=myquobyte'])
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({:os_workers => 8}))
      end

      it_configures 'quobyte volume driver'
    end
  end

end
