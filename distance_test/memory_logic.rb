module MemoryLogic
  def store_memory_in_long_term
    raise "No collection set" if @col.nil?
    @col.insert({:_id=>Time.now.to_s,:memory=>@memory_queue})
  end

  def start_memory_event(event_name)
    raise "No collection set" if @col.nil?
    raise "Already processing event #{@current_event[:_id]}" unless @current_event.nil?
    raise "Invalid event name" if event_name.nil?

    @current_event = @col.find_one({:_id => event_name})
    if @current_event.nil?
      @col.insert({:_id=>event_name})
      @current_event = {:_id=>event_name}
    end
  end

  def end_memory_event(event_name)
    raise "No collection set" if @col.nil?
    @col.update({:_id=>event_name},@current_event)
    @current_event = nil
  end

  def start_memory_event_section(section_name)
    raise "No collection set" if @col.nil?
    raise "Already processing event section #{@current_event_section[:_id]}" unless @current_event_section.nil?
    raise "Invalid section name" if section_name.nil?
    raise "No current event set" if @current_event.nil?

    @current_section = @current_event[section_name.to_sym] || []
    @current_section << {:_id => Time.now.to_s, :info => {} }
    @current_section
  end

  def end_memory_event_section(section_name)
    raise "No collection set" if @col.nil?
    @current_event[section_name.to_sym] = @current_section
    @current_section = nil
  end

  def remember_event_information(info_hash)
    raise "No collection set" if @col.nil?
    @current_event = @current_event.merge(info_hash)
  end

  def remember_event_section_information(info_hash)
    raise "No collection set" if @col.nil?
    @current_section.last[:info] = @current_section.last[:info].merge(info_hash)
  end

  def we_remember_the_event?(event_name)
    raise "No collection set" if @col.nil?
    !@col.find_one({:_id => event_name}).nil?
  end

  def fetch_info_from_memory_of_event(info_to_fetch,event_name,event_section_name=nil)
    raise "No collection set" if @col.nil?
    event = @col.find_one({:_id => event_name})
    raise "Event #{event_name} unexpectedly nil" if event.nil?
    if event_section_name.nil?
      event[info_to_fetch.to_s]
    else
      event[event_section_name.to_s][info_to_fetch.to_s]
    end
  end

  def clear_short_term_memory
    @memory_queue ||= []
    @memory_queue.clear
  end
end
