#!/usr/bin/env ruby

require 'to_words'

seed = ARGV[0] || Random.new_seed
STDERR.puts "USING SEED #{seed}"
$rng = Random.new(seed)

@src = File.read("i-thought-about.txt").split(/\n/)

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

def chapter_heading(i)
  base = "CHAPTER #{i.to_words.upcase}"
  underline = "-" * base.length
  "#{base}\n#{underline}\n\n"
end

def random_sentence
  @src.sample(random: $rng).dup
end

output << "WHAT I THOUGHT ABOUT"
output << "====================\n\n\n"
output << chapter_heading(chapter_index)

while output.split.length < 50_000
  sent = random_sentence
  style = $rng.rand
  if style > 0.85
    sent = "#{prefixes.sample(random: $rng)} #{sent}"
  elsif style > 0.75
    sent << " and #{random_sentence}"
  end

  sent <<  ". "
  
  if $rng.rand > 0.99
    output << "\n\n"
    1.upto($rng.rand(5..15)) do
      output << "#{sent}\n"
    end
    output << "\n\n"

    chapter_index = chapter_index + 1

    output << chapter_heading(chapter_index)

  else
    output << sent
    
    if $rng.rand > 0.95
      output << "\n\n"
    end
  end
end

output << "\n\nI thought about the end.\n\n\n\n"

output << "(Seed #{seed})"

puts output
