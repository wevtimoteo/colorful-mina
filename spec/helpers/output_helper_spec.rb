require 'spec_helper'

describe 'Output Helpers' do
  before :each do
    @out = Object.new
    @out.send :extend, Mina::OutputHelpers
  end

  it 'print_str to stdout' do
    expect(@out.print_str "Hello there\n" ).to include '       Hello there'
  end

  it 'print_str to status' do
    expect(@out.print_str "-----> Getting password" ).to include "[32m----->\e[0m Getting password"
  end

  it 'print_str to status (2)' do
    expect(@out.print_str "-> Getting password" ).to include "[32m----->\e[0m Getting password"
  end

  it 'print_str to error' do
    expect(@out.print_str "! Something went wrong" ).to include "[31mSomething went wrong"
  end
end
