# encoding: utf-8
require 'integration/elasticsearch/spec_helper'
require 'chewy/multi_search_index'
require 'ostruct'

describe MultiSearchIndex, :elasticsearch do

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



  describe '.search' do

    describe 'finds course by' do

      it 'exact code' do
        expect( search_ids('MI-RUB') ).to eq ['MI-RUB']
      end

      it 'code in different case' do
        expect( search_ids('mi-Rub') ).to eq ['MI-RUB']
      end

      it 'parts of FIT code' do
        expect( search_ids('BI') ).to eq ['BI-PYT']
        expect( search_ids('PYT') ).to eq ['BI-PYT']
      end

      it 'first two chars from second part of FIT code' do
        expect( search_ids('PY') ).to eq ['BI-PYT']
      end

      it 'last part of FEL code' do
        expect( search_ids('DBS') ).to eq ['A7B36DBS']
      end

      it 'one word from czech name without accents' do
        expect( search_ids('databaze') ).to eq ['A7B36DBS']
      end

      it 'one word from czech name in different inflection' do
        expect( search_ids('pythonem') ).to eq ['BI-PYT']
      end

      it 'two words from czech name' do
        expect( search_ids('programovani ruby') ).to eq ['MI-RUB']
      end
    end

    describe 'finds person by' do

      it 'exact username' do
        expect( search_ids('flynnkev') ).to eq ['flynnkev']
      end

      it 'username in different case' do
        expect( search_ids('FLYNNkev') ).to eq ['flynnkev']
      end

      it 'first three chars of username' do
        expect( search_ids('fly') ).to match_array ['flynnkev', 'flynnsam']
      end

      it 'exact last name' do
        expect( search_ids('Šílená') ).to eq ['inkogeli']
      end

      it 'last name in different case and without accents' do
        expect( search_ids('silena') ).to eq ['inkogeli']
      end

      it 'first three chars of last name' do
        expect( search_ids('sil') ).to eq ['inkogeli']
      end

      it 'first name in different case and without accents' do
        expect( search_ids('eliska') ).to eq ['inkogeli']
      end

      it 'first three chars of first name' do
        expect( search_ids('eli') ).to match_array ['rubyelis', 'inkogeli']
      end

      it 'first two chars of first name and last name' do
        expect( search_ids('sa fl') ).to eq ['flynnsam']
      end
    end

    describe 'finds room by' do

      it 'exact code' do
        expect( search_ids('T9:105') ).to eq ['T9:105']
      end

      it 'code in different case' do
        expect( search_ids('th:a-1342') ).to eq ['TH:A-1342']
      end

      it 'one part of code' do
        expect( search_ids('105') ).to eq ['T9:105']  # FIXME!
        expect( search_ids('t9') ).to match_array ['T9:105', 'T9:350']
      end
    end

    describe 'finds mixed types' do

      it 'course and person' do
        expect( search_ids('ruby') ).to match_array ['MI-RUB', 'rubyelis']
      end
    end
  end


  describe '.extract_last_name' do
    {
      'Sam Flynn'                     => 'Flynn',
      'Dr. Kevin Flynn, PhD.'         => 'Flynn',
      'Mgr. Eliška Šílená MBA'        => 'Šílená',
      'RNDr. Ender Noname, CSc. PhD.' => 'Noname'
    }
    .each do |input, expected|
      it "returns '#{expected}' for '#{input}'" do
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

  def search_ids(*args)
    described_class.search(*args).map(&:id)
  end
end
