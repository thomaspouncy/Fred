module MemoryElements
  class MemoryQueue < Array
    attr_reader :max_queue_length

    def initialize(max_queue_length,*values)
      raise "Must set a valid max queue length" if max_queue_length.nil? || !max_queue_length.is_a?(Fixnum) || max_queue_length <= 0
      @max_queue_length = max_queue_length

      values = values[0..(max_queue_length-1)] if values.is_a?(Array) && values.length > max_queue_length

      super(*values)
    end

    def push(*values)
      resulting_length = (values.is_a?(Array) ? values.length : 1) + self.length

      if resulting_length > max_queue_length
        (resulting_length - max_queue_length).times do
          self.shift
        end
      end

      super(*values)
    end

    def <<(obj)
      self.shift if (self.length+1) > max_queue_length
      super(obj)
    end
  end
end
