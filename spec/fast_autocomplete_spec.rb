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
        expect(@autocompleter.autocomplete_prefix('inner').sort)
            .to eq downcase_keys_start_with(@dictionary, 'inner').sort
      end

      it 'should contain the word itself if the word is in the trie' do
        expect(@autocompleter.autocomplete_prefix('innerly'))
            .to eq downcase_keys_start_with(@dictionary, 'innerly').sort
      end

      it 'should return the same results if autocompleter is case insensitive' do
        expect(@autocompleter.autocomplete_prefix('INNER')).to_not eq []
        expect(@autocompleter.autocomplete_prefix('INNER'))
            .to eq @autocompleter.autocomplete_prefix('inner')
      end
    end

    describe '#autocomplete_suffix' do
      it 'should autocomplete a suffix string with the complete list of matches' do
        expect(@autocompleter.autocomplete_suffix('inner')).to eq []
        expect(@autocompleter.autocomplete_suffix('ner').sort)
            .to eq downcase_keys_end_with(@dictionary, 'ner').sort
      end

      it 'should contain the word itself if the word is in the trie' do
        expect(@autocompleter.autocomplete_suffix('innerly'))
            .to eq downcase_keys_end_with(@dictionary, 'innerly').sort
      end

      it 'should return the same results if autocompleter is case insensitive' do
        expect(@autocompleter.autocomplete_suffix('NER')).to_not eq []
        expect(@autocompleter.autocomplete_suffix('NER'))
            .to eq @autocompleter.autocomplete_suffix('ner')
      end
    end

    describe '#autocomplete' do
      it 'should autocomplete a prefix & suffix string with the intersection' do
        expect(@autocompleter.autocomplete('inter*tion').sort)
            .to eq (downcase_keys_start_with(@dictionary, 'inter') &
                    downcase_keys_end_with(@dictionary, 'tion')).sort
      end

      it 'should return the same results if autocompleter is case insensitive' do
        expect(@autocompleter.autocomplete('INNER')).to_not eq []
        expect(@autocompleter.autocomplete('INNER')).to eq @autocompleter.autocomplete('inner')
      end
    end

    context 'with hash' do
      before(:all) do
        @autocompleter_hash = FastAutocomplete::Autocompleter.new(@dictionary)
      end

      describe '#autocomplete' do
        it 'should return an array if autocomplete called' do
          expect(@autocompleter_hash.autocomplete('INNER')).to be_a(Array)
        end
      end

      describe '#autocomplete_matches' do
        it 'should return a hash if a hash is passed in' do
          expect(@autocompleter_hash.autocomplete_matches('INNER')).to be_a(Hash)
        end

        it 'should return a mapping to the actual result when autocompleted' do
          expect(@autocompleter_hash.autocomplete_matches('INNER').keys.sort)
              .to eq keys_start_with(@dictionary, 'inner').sort
        end
      end
    end
  end
end