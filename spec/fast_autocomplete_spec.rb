require 'spec_helper'

describe FastAutocomplete do
  describe 'public methods' do
    before(:all) do
      f = File.read("#{Dir.pwd}/spec/data/abridged.json")
      if f.nil?
        f = File.read("#{Dir.pwd}/spec/data/abridged.json")
      end
      @dictionary = JSON.parse(f)
      @autocompleter = FastAutocomplete::Autocompleter.new(@dictionary.keys.map(&:downcase))
    end

    describe '#build' do
      it 'should build the related tries without error' do
        expect(@autocompleter).to_not be_nil
      end
    end

    describe '#autocomplete_prefix' do
      it 'should autocomplete a prefix string with the complete list of matches' do
        expect(@autocompleter.autocomplete_prefix('inner').sort).to eq keys_start_with(@dictionary, 'inner').sort
      end

      it 'should contain the word itself if the word is in the trie' do
        expect(@autocompleter.autocomplete_prefix('innerly')).to eq keys_start_with(@dictionary, 'innerly').sort
      end
    end

    describe '#autocomplete_suffix' do
      it 'should autocomplete a suffix string with the complete list of matches' do
        expect(@autocompleter.autocomplete_suffix('inner')).to eq []
        expect(@autocompleter.autocomplete_suffix('ner').sort).to eq keys_end_with(@dictionary, 'ner').sort
      end

      it 'should contain the word itself if the word is in the trie' do
        expect(@autocompleter.autocomplete_suffix('innerly')).to eq keys_end_with(@dictionary, 'innerly').sort
      end
    end

    describe '#autocomplete' do
      it 'should autocomplete a prefix & suffix string with the intersection' do
        expect(@autocompleter.autocomplete('inter*tion').sort).to eq (keys_start_with(@dictionary, 'inter') & keys_end_with(@dictionary, 'tion')).sort
      end
    end
  end
end