module TechnicalAnalysis
  class Dlr < Indicator

    def self.indicator_symbol
      "dlr"
    end

    def self.indicator_name
      "Daily Log Return"
    end

    def self.valid_options
      %i(price_key)
    end

    def self.validate_options(options)
      Validation.validate_options(options, valid_options)
    end

    def self.min_data_size(**params)
      1
    end

    # Calculates the daily log return (percent expressed as a decimal) for the data over the given period
    # https://www.quora.com/What-are-daily-log-returns-of-an-equity
    # https://en.wikipedia.org/wiki/Rate_of_return#Logarithmic_or_continuously_compounded_return
    #
    # @param data [Array] Array of hashes with keys (:date_time, :value)
    # @param price_key [Symbol] The hash key for the price data. Default :value
    # @return [Hash] A hash of the results with keys (:date_time, :value)
    def self.calculate(data, price_key: :value)
      price_key = price_key.to_sym
      Validation.validate_numeric_data(data, price_key)
      Validation.validate_length(data, 1)

      data = data.sort_by_hash_date_time_asc

      output = []
      prev_price = data.first[price_key].to_f

      data.each do |v|
        current_price = v[:close].to_f

        output << { date_time: v[:date_time], value: Math.log(current_price / prev_price) }

        prev_price = current_price
      end

      output.sort_by_hash_date_time_desc
    end

  end
end