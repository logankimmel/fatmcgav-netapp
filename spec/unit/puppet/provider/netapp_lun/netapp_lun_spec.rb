#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:netapp_lun).provider(:netapp_lun) do

  before :each do
    described_class.stubs(:suitable?).returns true
    Puppet::Type.type(:netapp_lun).stubs(:defaultprovider).returns described_class
  end

  let :lun_create do
    Puppet::Type.type(:netapp_lun).new(
    :name        => '/vol/testVolumeFCoE/testLun_test',
    :ensure      => :present,
    :size_bytes  => '20000000',
    :ostype      => 'linux'
    )
  end

  let :lun_destroy do
    Puppet::Type.type(:netapp_lun).new(
    :name     => '/vol/testVolumeFCoE/testLun_test',
    :ensure   => :absent
    )
  end

  let :provider do
    described_class.new()
  end

  context "when netapp lun provider is created " do
    it "should have create method defined for netapp lun" do
      lun_create.provider.class.instance_method(:create).should_not == nil
    end

    it "should have destroy method defined for netapp lun" do
      lun_create.provider.class.instance_method(:destroy).should_not == nil
    end

    it "should have exists? method defined for netapp lun" do
      lun_create.provider.class.instance_method(:exists?).should_not == nil
    end

  end

  context "when creating a lun resource" do
    it "should be able to create a lun resource" do
      #Then
      lun_create.provider.expects(:luncreate).at_most(3).with('path', '/vol/testVolumeFCoE/testLun_test', 'size', '20000000', 'ostype', 'linux').returns ""
      lun_create.provider.expects(:get_lun_existence_status).at_most(2).with().returns('false','true')
      provider.expects(:err).never

      #When
      lun_create.provider.create
    end

    it "should not be able to create a lun resource" do
      #Then
      lun_create.provider.expects(:luncreate).at_most(3).with('path', '/vol/testVolumeFCoE/testLun_test', 'size', '20000000', 'ostype', 'linux').returns ""
      lun_create.provider.expects(:get_lun_existence_status).at_most(2).with().returns('false','false')
      lun_create.provider.expects(:info).never

      #When
      expect {lun_create.provider.create}.to raise_error(Puppet::Error)
    end

    context "when destroying a lun resource" do
      it "should be able to delete a lun resource" do
        #Then
        lun_destroy.provider.expects(:lundestroy).at_most(3).with('path', '/vol/testVolumeFCoE/testLun_test').returns ""
        lun_destroy.provider.expects(:get_lun_existence_status).at_most(2).with().returns('true','false')
        lun_destroy.provider.expects(:err).never

        #When
        lun_destroy.provider.destroy
      end

      it "should not be able to delete a lun resource" do
        #Then
        lun_destroy.provider.expects(:lundestroy).at_most(3).with('path', '/vol/testVolumeFCoE/testLun_test').returns ""
        lun_destroy.provider.expects(:get_lun_existence_status).at_most(2).with().returns('true','true')
        lun_destroy.provider.expects(:info).never

        #When
        expect {lun_destroy.provider.destroy}.to raise_error(Puppet::Error)
      end

    end
  end
end