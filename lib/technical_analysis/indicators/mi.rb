module TechnicalAnalysis
  class Mi < Indicator

    def self.indicator_symbol
      "mi"
    end

    def self.indicator_name
      "Mass Index"
    end

    def self.valid_options
      %i(ema_period sum_period)
    end

    def self.validate_options(options)
      Validation.validate_options(options, valid_options)
    end

    def self.min_data_size(ema_period: 9, sum_period: 25)
      (ema_period.to_i * 2) + sum_period.to_i - 2
    end

    # Calculates the mass index (MI) for the data over the given period
    # https://en.wikipedia.org/wiki/Mass_index
    #
    # @param data [Array] Array of hashes with keys (:date_time, :high, :low)
    # @param ema_period [Integer] The given period to calculate the EMA and EMA of EMA
    # @param sum_period [Integer] The given period to calculate the sum of EMA ratios
    # @return [Hash] A hash of the results with keys (:date_time, :value)
    def self.calculate(data, ema_period: 9, sum_period: 25)
      ema_period = ema_period.to_i
      sum_period = sum_period.to_i
      Validation.validate_numeric_data(data, :high, :low)
      Validation.validate_length(data, (ema_period * 2) + sum_period - 2)

      data = data.sort_by_hash_date_time_asc

      double_emas = []
      high_low_diffs = []
      output = []
      ratio_of_emas = []
      single_emas = []

      data.each do |v|
        high_low_diff = v[:high] - v[:low]
        high_low_diffs << high_low_diff

        if high_low_diffs.size == ema_period
          single_ema = StockCalculation.ema(high_low_diff, high_low_diffs, ema_period, single_emas.last)
          single_emas << single_ema

          if single_emas.size == ema_period
            double_ema = StockCalculation.ema(single_emas.last, single_emas, ema_period, double_emas.last)
            double_emas << double_ema

            ratio_of_emas << (single_ema / double_ema)

            if ratio_of_emas.size == sum_period
              output << { date_time: v[:date_time], value: ratio_of_emas.sum }

              double_emas.shift
              ratio_of_emas.shift
            end

            single_emas.shift
          end

          high_low_diffs.shift
        end
      end

      output.sort_by_hash_date_time_desc
    end

  end
end