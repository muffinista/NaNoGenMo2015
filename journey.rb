#!/usr/bin/env ruby

class Setting
  TYPES = [:ocean, :river, :valley, :plains, :mountains, :village]
end

class Climate
  TYPES = [:desert, :temperate, :cold]

  # barren
  # lush
  # etc
end

class Weather

end

class Food
  # start nice, degrade
  # hunting
end

class Mood
  # start high, chance of degrading
end

class Actor
  # name
  # mood
  # role - captain, officer, poet, scientist, artist
end


class Location
  attr_accessor :setting
  attr_accessor :climate
end

class Waypoint
  # location
  # weather
  # array of entries
end



# at some point a murderer starts murdering

# Ocean -> River -> Land -> vague destination

# Captain's Log

# ____th Officer's Log

# The log of ____, passenger

# The journal of someone back home

#pick next location type

#describe it

#should have a mood

#establish feelings in the party -- different people like/dislike things?

