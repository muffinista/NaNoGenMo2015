#!/usr/bin/env ruby

require 'to_words'

seed = ARGV[0] || Random.new_seed
STDERR.puts "USING SEED #{seed}"
$rng = Random.new(seed)

src = File.read("i-thought-about.txt").split(/\n/)

chapter_index = 1

prefixes = [
  "I admit",
  "I thought about things like",
  "I thought about how easily",
  "I mean",
  "I thought about it while",
  "I thought about you while",
  "I said",
  "I think",
  "I suppose",
  "I thought about this and",
  "I know"
]

output = ""

output << "CHAPTER #{chapter_index.to_words.upcase}\n\n"

while output.split.length < 50_000
  sent = src.sample
  if $rng.rand > 0.99
    output << "\n\n"
    1.upto($rng.rand(5..15)) do
      output << "#{sent}.\n"
    end
    output << "\n\n"

    chapter_index = chapter_index + 1

    output << "CHAPTER #{chapter_index.to_words.upcase}\n\n"

  else
    if $rng.rand > 0.85
      sent = "#{prefixes.sample} #{sent}"
    end
    output << "#{sent}. "
    
    if $rng.rand > 0.95
      output << "\n\n"
    end
  end
end

output << "\n\nI thought about the end.\n\n\n\n"

puts output
