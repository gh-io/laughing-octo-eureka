require 'json'

module Aura
  @listeners = []

  def self.receive_event(event)
    @listeners.each { |l| l.call(event) }
    log_event(event)
    update_dashboard(event)
  end

  def self.on_event(&block)
    @listeners << block
  end

  def self.log_event(event)
    log_file = File.join(__dir__, "../logs/event_history.json")
    events = File.exist?(log_file) ? JSON.parse(File.read(log_file)) : []
    events << event
    File.write(log_file, JSON.pretty_generate(events))
  end

  def self.update_dashboard(event)
    # placeholder: live updates could use websockets or JS polling
    puts "Dashboard Update: #{event}"
  end
end
