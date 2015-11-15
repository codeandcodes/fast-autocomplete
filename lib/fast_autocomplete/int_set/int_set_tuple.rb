module FastAutocomplete
  module IntSet
    class IntSetTuple
      # Tuple to support int sets
      # unnecessary for hash
      attr_accessor :key, :value
      def initialize(key, value)
        @key = key
        @value = value
      end
    end
  end
end