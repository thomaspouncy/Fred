class Body
  attr_reader :central_nervous_system,
              :reflexes,
              :senses

  def initialize(cns,reflexes,senses)
    raise "Invalid central nervous system: #{cns.inspect}" if cns.nil? || !cns.is_a?(DecisionMaker)
    raise "Invalid reflexes: #{reflexes.inspect}" if reflexes.nil? || !reflexes.is_a?(DecisionMaker)
    raise "Invalid senses: #{senses.inspect}" if senses.nil? || !senses.is_a?(Hash)

    @central_nervous_system = cns
    @reflexes = reflexes
    @senses = senses

    self
  end
end
