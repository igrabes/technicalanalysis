module TechnicalAnalysis
  class Obv < Indicator

    def self.indicator_symbol
      "obv"
    end

    def self.indicator_name
      "On-balance Volume"
    end

    def self.valid_options
      []
    end

    def self.validate_options(options)
      return true if options == {}
      raise Validation::ValidationError.new "This indicator doesn't accept any options."
    end

    def self.min_data_size(**params)
      1
    end

    # Calculates the on-balance volume (OBV) for the data over the given period
    # https://en.wikipedia.org/wiki/On-balance_volume
    #
    # @param data [Array] Array of hashes with keys (:date_time, :close, :volume)
    # @return [Hash] A hash of the results with keys (:date_time, :value)
    def self.calculate(data)
      Validation.validate_numeric_data(data, :close, :volume)
      Validation.validate_length(data, 1)

      data = data.sort_by_hash_date_time_asc

      current_obv = 0
      output = []
      prior_close = nil
      prior_volume = nil

      data.each do |v|
        volume = v[:volume]
        close = v[:close]

        unless prior_close.nil?
          current_obv += volume if close > prior_close
          current_obv -= volume if close < prior_close
        end

        output << { date_time: v[:date_time], value: current_obv }

        prior_volume = volume
        prior_close = close
      end

      output.sort_by_hash_date_time_desc
    end

  end
end