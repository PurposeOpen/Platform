require 'spec_helper'

describe EmailFormatValidator do
  class TestModel
    attr_accessor :from
    include ActiveModel::Validations
    validates :from, :email_format => true
    def initialize(attrs)
      self.from = attrs[:from]
    end
  end

  it 'should validate for right format' do
    TestModel.new(:from => 'a@b.com').should be_valid
    TestModel.new(:from => 'ab.com').should_not be_valid
  end

  it 'should validate email address with display-name' do
    TestModel.new(:from => 'AB <a@b.com>').should be_valid
    TestModel.new(:from => 'David Dravid   <a@b.com>').should be_valid
    TestModel.new(:from => '"Andre and Jeremy, AllOut.org" <info@allout.org>').should be_valid
    TestModel.new(:from => '"Andre & Jeremy, AllOut.org" <info@allout.org>').should be_valid
    TestModel.new(:from => "'Andre and Jeremy, AllOut.org' <info@allout.org>").should be_valid
    TestModel.new(:from => '<a@b.com>').should_not be_valid
    TestModel.new(:from => 'A B').should_not be_valid
    TestModel.new(:from => 'A B [a@b.com]').should_not be_valid
    TestModel.new(:from => 'A B (a@b.com)').should_not be_valid
    TestModel.new(:from => 'A B a@b.com').should_not be_valid
  end
end
