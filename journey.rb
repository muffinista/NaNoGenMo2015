#!/usr/bin/env ruby

#
# rough code for my journey/travelogue entry, which never really materialized
# 

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
      #puts "current state #{current_state}"
      opts = transitions[current_state]
      #puts opts.inspect
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
      self.class.new(next_state)
    end
  end

  module ClassMethods
    #
    # transition from: :blah, to: [:bar, :baz]
    #
    def transition(opts)
      #puts "defining #{opts.inspect}"
      class_variable_get(:@@transitions_for)[opts[:from]] = opts[:to]      
    end

    def default_chance(x)
      class_variable_set :@@default_chance, x
    end
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

  transition from: :sunny, to: [ :rain, :gloomy ]
  transition from: :gloomy, to: [ :sunny, :rain ]
  transition from: :rain, to: [ :sunny, :storm ]
  transition from: :storm, to:[ :rain, :epic ]
  transition from: :epic, to:[ :epic, :sunny ]

  def initialize(val=nil)
    val ||= default_state
    set_state val
  end
  
  def to_s
    @state.to_s
  end
end

class Mood
  include FSM
  default_chance 0.25

  transition from: :good_3, to: [:good_2]
  transition from: :good_2, to: [:good_3, :good_1]
  transition from: :good_1, to: [:bad_1, :good_2]    

  transition from: :bad_1, to: [:bad_2, :good_1]    
  transition from: :bad_2, to: [:bad_3, :bad_1]
  transition from: :bad_3, to: [:bad_2]
  
  def initialize(val=nil)
    val ||= default_state
    set_state val
  end
  
  def to_s
    @state.to_s
  end
end

class JournalGenerator
  def initialize(writer, waypoint)
    @writer = writer
    @waypoint = waypoint
  end

  # general status
  # report on specific area
  # something about another person
  
  def captain
    [
      "Captain's Log, Day #{@waypoint.date}",
      "a bit about the weather",
      "According to our ",
      "remark about member of voyage"
    ]
  end

  def officer
    [
      "the date",
      "determining location",
      "report on morale"
    ]
  end

  def poet
    [
      "a bunch of poetry about conditions"
    ]
  end

  def scientist
    [
      "some scientific readings",
      "notes on science"
    ]
  end

  def machine
    [
      "lots of numbers/etc"
    ]
  end

  def artist
    [
      "photo, etc"
    ]
  end
  
  def output
    send(@writer.role)
  end
end


class Actor
  # name
  # mood
  # also :captain but you can't pick that randomly

  attr_accessor :role

  TYPES = [:officer, :poet, :scientist, :machine, :artist]
  def initialize(role=nil)
    role ||= TYPES.sample

    @role = role
    #@mood = Mood.new
    @alive = true
  end

  def alive?
    @alive
  end

  def journal(waypoint)
    JournalGenerator.new(self, waypoint).output
  end

  def to_s
    "Name, #{@role.to_s}"
  end
end


class Waypoint
  # location
  # weather
  # array of entries
  @@index = 0

  attr_accessor :speakers
  attr_accessor :last_waypoint
  
  ATTRS = [:weather, :climate, :mood]
  
  ATTRS.each { |a|
    attr_accessor a
  }
  
  def initialize(last_waypoint=nil)
    @@index = @@index + 1
    @index = @@index

    num_speakers = rand(1..4)
    if last_waypoint.nil?
      captain = $actors.select { |a| a.role == :captain }.first
      @speakers = ([captain] + $actors.sample(num_speakers)).uniq
    else
      @speakers = $actors.sample(num_speakers)
    end
    
    @last_waypoint = last_waypoint
    ATTRS.each { |a|
      klass = Object.const_get(a.to_s.capitalize)
      val = @last_waypoint.nil? ? klass.new : @last_waypoint.send(a).next
      self.send("#{a.to_s}=".to_sym, val)
    }
  end

  def date
    @index
  end

  def next
    Waypoint.new(self)
  end

  def to_s
    [
      "##{@index}",
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
    Actor.new(:artist)
  ]
end


$actors = build_actors
@waypoints = []

def generate_waypoint
  result = if @waypoints.last.nil?
             Waypoint.new
           else
             @waypoints.last.next
           end

  @waypoints << result

  result 
end


if __FILE__ == $0
  1.upto(100) {
    generate_waypoint
  }

  @waypoints.each { |w|
    puts w.to_s
    w.speakers.each { |s|
      puts "#{s} has something to say"
      puts s.journal(w).join(". ")
    }
  }
end
