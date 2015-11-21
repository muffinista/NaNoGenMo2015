#!/usr/bin/env ruby

module FSM
  class << self
    def included(base)
      base.send :class_variable_set, :@@transitions_for, Hash.new
      base.send :class_variable_set, :@@default_chance, 0.25
      base.send :class_variable_set, :@@default_state, :unknown
      
      base.send :include, InstanceMethods
      base.extend(ClassMethods)
    end
  end

  module InstanceMethods
    def transitions
      self.class.class_variable_get :@@transitions_for
    end

    def default_chance
      self.class.class_variable_get :@@default_chance
    end

    def default_state
      tmp = transitions.first
      tmp.is_a?(Array) ? tmp.first : tmp
    end
   
    def do_transition?
      rand <= default_chance
    end

    def set_state(x)
      @state = x
    end
    
    def current_state
      @state
    end
    
    def pick_next_state
      puts "current state #{current_state}"
      opts = transitions[current_state]
      puts opts.inspect
      if opts.is_a?(Array)
        opts.sample
      else
        val = rand
        base = 0.0
        opts.detect { |type, chance|
          val < (base = base + chance)
        }.first
      end
    end
    
    def next_state
      do_transition? ? pick_next_state : current_state
    end

    def next
      puts "FSM NEXT"
      self.class.new(next_state)
    end
  end

  module ClassMethods
    #
    # transition from: :blah, to: [:bar, :baz]
    #
    def transition(opts)
      puts "defining #{opts.inspect}"
      class_variable_get(:@@transitions_for)[opts[:from]] = opts[:to]      
    end

    def default_chance(x)
      class_variable_set :@@default_chance, x
    end
  end
end


class Setting
  include FSM

  default_chance 0.3
  
  transition from: :ocean, to: [:river]
  transition from: :river, to: {
               :river => 0.25,
               :valley => 0.25,
               :plains => 0.25,
               :village => 0.25
             }
  transition from: :valley, to: [:river, :plains, :mountains]
  transition from: :plains, to: [:river, :mountains, :village]
  transition from: :village, to: [:river]
  
  def initialize(val=nil)
    val ||= default_state
    set_state val
  end

  def to_s
    @state.to_s
  end
end

class Climate
  include FSM

  transition from: :temperate, to: {
               hot: 0.5,
               cold: 0.5
             }

  transition from: :hot, to: {
               temperate: 0.75,
               blazing: 0.25
             }

  transition from: :blazing, to: [ :hot, :temperate ]
  transition from: :cold, to: [ :freezing, :temperate ]
  transition from: :freezing, to: [ :cold ]

  def initialize(val=nil)
    val ||= default_state
    set_state val
  end
  
  def to_s
    @state.to_s
  end
end

class Weather
  include FSM
  default_chance 0.25

  transition from: :sunny, to: [ :rain ]
  transition from: :rain, to: [ :sunny ]  

  def initialize(val=nil)
    val ||= default_state
    set_state val
  end
  
  def to_s
    @state.to_s
  end
end

class Food
  # start nice, degrade
  # hunting
end

class Mood
  include FSM
  default_chance 0.25

  transition from: :good, to: [:good, :bad]
  transition from: :bad, to: [:good]  

  def initialize(val=nil)
    val ||= default_state
    set_state val
  end
  
  def to_s
    @state.to_s
  end
end

class Actor
  # name
  # mood
  # also :captain but you can't pick that randomly
  TYPES = [:officer, :poet, :scientist, :machine, :artist, :stowaway]
  def initialize(role=nil)
    @role ||= TYPES.sample
    @mood = Mood.new
    @alive = true
  end

  def alive?
    @alive
  end

  def to_s
    "Name, #{@role.to_s}"
  end
end


# class Location
#   attr_accessor :setting

#   def initialize
#     @setting = Setting.new
#   end

#   def to_s
#     @setting.to_s
#   end 
# end


WAYPOINT_ATTRS = [:weather, :setting, :climate, :mood]

class Waypoint
  # location
  # weather
  # array of entries
  @@index = 0

  WAYPOINT_ATTRS.each { |a|
    attr_accessor a
  }
  
  def initialize(last_waypoint=nil)
    @@index = @@index + 1
    @index = @@index

    num_speakers = rand(1..4)
    @speakers = $actors.sample(num_speakers)
    
    @last_waypoint = last_waypoint
    WAYPOINT_ATTRS.each { |a|
      puts a
      klass = Object.const_get(a.to_s.capitalize)
      val = @last_waypoint.nil? ? klass.new : @last_waypoint.send(a).next
      self.send("#{a.to_s}=".to_sym, val)
    }
  end

  def next
    Waypoint.new(self)
  end

  def to_s
    [
      "##{@index}",
      #"Location: #{@location}",
      "Weather: #{@weather}",
      "Mood: #{@mood}",
      "Speakers: #{@speakers.collect(&:to_s).join(' ')}"
    ].join(", ")
  end

end

def build_actors
  [
    Actor.new(:captain),
    Actor.new(:officer),
    Actor.new(:officer),
    Actor.new(:officer),
    Actor.new(:poet),    
    Actor.new(:scientist),
    Actor.new(:scientist),    
    Actor.new(:machine),
    Actor.new(:artist),
    Actor.new(:stowaway)    
  ]
end


$actors = build_actors
#@current_location = Location.new
@waypoints = []

def generate_waypoint
  result = if @waypoints.last.nil?
             Waypoint.new
           else
             @waypoints.last.generate_waypoint(@waypoints.last)
           end

  @waypoints << result

  result 
end
