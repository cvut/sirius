# encoding: utf-8
require 'corefines'
require 'integration/elasticsearch/spec_helper'
require 'chewy/multi_search_index'
require 'ostruct'
require 'rspec-parameterized'

describe MultiSearchIndex, :elasticsearch do

  using RSpec::Parameterized::TableSyntax
  using Corefines::Hash::only

  before(:context) do
    DatabaseCleaner.cleaning do

      # Insert seed data to SQL database.
      Fabricate(:course, id: 'MI-RUB',   name: Sequel.hstore(cs: 'Programování v Ruby'))
      Fabricate(:course, id: 'BI-PYT',   name: Sequel.hstore(cs: 'Programování v Pythonu'))
      Fabricate(:course, id: 'A7B36DBS', name: Sequel.hstore(cs: 'Databáze'))

      Fabricate(:person, id: 'flynnkev', full_name: 'Dr. Kevin Flynn, PhD.')
      Fabricate(:person, id: 'flynnsam', full_name: 'Sam Flynn')
      Fabricate(:person, id: 'inkogeli', full_name: 'Mgr. Eliška Šílená MBA')
      Fabricate(:person, id: 'rubyelis', full_name: 'Elisia Ruby')

      Fabricate(:room, id: 'T9:105')
      Fabricate(:room, id: 'T9:350')
      Fabricate(:room, id: 'TH:A-1342')

      # Purges index and imports data for all types.
      MultiSearchIndex.reset!
    end
  end

  after(:context) do
    MultiSearchIndex.delete
  end

  shared_examples 'paged collection' do
    it 'returns object with page_meta' do
      expect( results.page_meta ).to eq page_meta
    end
  end


  describe '.search' do

    shared_examples :search_results do |type|
      with_them ->{ "by #{desc}: \"#{input}\"" } do
        it "finds #{type}: #{row.expected.map(&:inspect).join(', ') }" do
          expect( search(input).map(&:id) ).to match_array expected
        end
      end
    end

    describe 'courses' do
      where :input,           :expected,     :desc do
        'MI-RUB'            | ['MI-RUB']   | 'exact code'
        'mi-Rub'            | ['MI-RUB']   | 'code in different case'
        'BI'                | ['BI-PYT']   | 'part of FIT code'
        'PYT'               | ['BI-PYT']   | 'part of FIT code'
        'PY'                | ['BI-PYT']   | 'first two chars from second part of FIT code'
        'DBS'               | ['A7B36DBS'] | 'last part of FEL code'
        'databaze'          | ['A7B36DBS'] | 'one word from czech name without accents'
        'pythonem'          | ['BI-PYT']   | 'one word from czech name in different inflection'
        'programovani ruby' | ['MI-RUB']   | 'two words from czech name'
      end
      include_examples :search_results, 'courses'
    end

    describe 'people' do
      where :input,  :expected,                 :desc do
        'flynnkev' | ['flynnkev']             | 'exact username'
        'FLYNNkev' | ['flynnkev']             | 'username in different case'
        'fly'      | ['flynnkev', 'flynnsam'] | 'first three chars of username'
        'Šílená'   | ['inkogeli']             | 'exact last name'
        'silena'   | ['inkogeli']             | 'last name in different case and without accents'
        'sil'      | ['inkogeli']             | 'first three chars of last name'
        'eliska'   | ['inkogeli']             | 'first name in different case and without accents'
        'eli'      | ['rubyelis', 'inkogeli'] | 'first three chars of first name'
        'sa fl'    | ['flynnsam']             | 'first two chars of first name and last name'
      end
      include_examples :search_results, 'people'
    end

    describe 'rooms' do
      where :input,   :expected,             :desc do
        'T9:105'    | ['T9:105']           | 'exact code'
        'th:a-1342' | ['TH:A-1342']        | 'code in different case'
        't9'        | ['T9:105', 'T9:350'] | 'letter part of code'
        'TH:A'      | ['TH:A-1342']        | 'letter part of code'
        '105'       | ['T9:105']           | 'numeric part of code'
        '1342'      | ['TH:A-1342']        | 'numeric part of code'
      end
      include_examples :search_results, 'rooms'
    end

    describe 'mixed types' do
      it 'finds course and person' do
        expect( search('ruby').map(&:id) ).to match_array ['MI-RUB', 'rubyelis']
      end
    end

    it_behaves_like 'paged collection' do
      subject(:results) { search('rub') }
      let(:page_meta) { {offset: 0, limit: 10, count: 2} }
    end

    context 'with non-default offset and limit' do
      subject(:results) { search('rub', **page_meta.only(:offset, :limit)) }
      let(:page_meta) { {offset: 1, limit: 1, count: 2} }

      it 'returns limited number of results' do
        should have(1).item
      end

      it_behaves_like 'paged collection'
    end
  end


  describe '.extract_last_name' do
    where :input,                       :expected do
      'Sam Flynn'                     | 'Flynn'
      'Dr. Kevin Flynn, PhD.'         | 'Flynn'
      'Mgr. Eliška Šílená MBA'        | 'Šílená'
      'RNDr. Ender Noname, CSc. PhD.' | 'Noname'
    end

    with_them ->{ "for '#{input}'" } do
      it "returns '#{row.expected}'" do
        expect( described_class.send(:extract_last_name, input) ).to eq expected
      end
    end
  end


  describe 'indexed object' do
    subject(:attributes) { described_class.find(id).attributes }

    describe 'course' do
      let(:id) { 'MI-RUB' }

      it 'contains attributes: id, name.cs as title' do
        should include 'id' => 'MI-RUB', 'title' => 'Programování v Ruby'
      end
    end

    describe 'person' do
      let(:id) { 'rubyelis' }

      it 'contains attributes: id, full_name as title, last_name' do
        should include 'id' => 'rubyelis', 'title' => 'Elisia Ruby', 'last_name' => 'Ruby'
      end
    end

    describe 'room' do
      let(:id) { 'T9:350' }

      it 'contains attributes: id' do
        should include 'id' => 'T9:350'
      end
    end
  end


  def search(*args)
    described_class.search(*args)
  end
end
