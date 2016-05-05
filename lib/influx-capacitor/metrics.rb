module InfluxCapacitor
  class Metrics < Array
    attr_reader :metrics
    attr_reader

    def initialize data
      begin
        @metrics = JSON.load(data).map(&InfluxCapacitor::Metric.new)
        true
      rescue StandardError => e
        @metrics = []
        false
      end
    end

    def to_influx
      @influx ||= @metrics.map(&:to_influx).join("\n")
    end
  end

  class Metric < Hash
    def to_influx
      "#{self.name} #{self.tags} #{self.fields} #{self.timestamp}"
    end

    def name
      self[:name]
    end

    def tags
      self[:tags].map(){|k,v| "#{k.to_s}=#{v.to_s}"}.join(',')
    end

    def fields
      self[:fields].map(){|k,v| "#{k.to_s}=#{v.to_f.to_s}"}.join(',')
    end

    def timestamp (scale=:ms)
      multiplicator = case scale
      when :ms
        1000.0
      when :us
        1000000.0
      when :ns
        1000000000.0
      else
        1.0
      end

      return (Time.now.to_f*multiplicator).to_i if !self[:timestamp]
      (Time.at(self[:timestamp]).to_f*multiplicator).to_i
    end
  end
end
