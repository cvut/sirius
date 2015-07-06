require 'spec_helper'
require 'url_helper'

describe UrlHelper do
  subject(:helper) { Class.new { extend UrlHelper } }

  describe '#base_domain' do
    subject { helper.base_domain }
    it { should eql 'example.com' }
    context 'absolute' do
      subject { helper.base_domain(absolute: true) }
      context 'with FORCE_SSL' do
        before do
          allow(Config).to receive(:force_ssl).and_return(true)
        end
        it { should eql 'https://example.com'}
      end
      context 'without FORCE_SSL' do
        before do
          allow(Config).to receive(:force_ssl).and_return(false)
        end
        it { should eql 'http://example.com'}
      end
    end
  end

  describe '#base_href' do
    subject { helper.base_href }
    it { should eql '/api/v1' }
  end

  describe '#path_for' do
    subject { helper.path_for '/foo' }
    it { should eql '/api/v1/foo' }

    context 'with params' do
      subject(:path) { helper.path_for '/foo', bar: 'baz', quaz: 'quar'}
      it 'should encode params' do
        expect(path).to eql '/api/v1/foo?bar=baz&quaz=quar'
      end

      context 'when url_fragment has params' do
        subject(:path) { helper.path_for '/foo?bar=baz', quaz: 'quar'}
        it 'appends new params' do
          expect(path).to eql '/api/v1/foo?bar=baz&quaz=quar'
        end
      end
    end

    context 'when url_fragment starts with base_href' do
      subject(:path) { helper.path_for "#{helper.base_href}/foo" }
      it 'does not prepend base_href' do
        should eql "#{helper.base_href}/foo"
      end
    end
  end

  describe '#url_for' do
    let(:fragment) { '/foo' }
    subject { helper.url_for fragment }
    before do
      allow(Config).to receive(:force_ssl).and_return(false)
    end

    it { should eql 'http://example.com/api/v1/foo' }
  end

end
