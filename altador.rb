require 'cgi'
require 'net/http'

class Array
  def +(other)
    (0...self.size).map { |i| self[i] + other[i] }
  end
end

def get(url)
  sleep Delay
  Conn.get(url, Headers).body
end

def post(url, data = {})
  sleep Delay
  data = data.is_a?(String) ? data : data.zip.flatten(1).map { |e| e * '=' } * '&'
  Conn.post(url, data, Headers)
end

def plot(which, spellbook = false)
  data = get STAR_DATA
  coords = data.split(':')[0].split('|').map { |d| d.split(',')[0..1].map &:to_i }
  map = {
    'sleeper'   => [[0, 0], [40, -30], [80, -60], [120, -60], [160, -30], [200, 0]],
    'dreamer'   => [[0, 0], [60, -20], [120, 0], [130, 40], [190, 60], [110, -90]],
    'rise'      => [[0, 0], [20, 60], [80, 80], [160, 0], [140, -60], [80, -80]],
    'farmer'    => [[0, 0], [140, -30], [10, -80], [120, -60], [160, -70], [80, 60]],
    'dancer'    => [[0, 0], [60, -30], [120, 0], [0, 140], [60, 170], [120, 140]],
    'wave'      => [[0, 0], [50, 70], [170, 40], [200, 0], [190, -90], [140, -10]],
    'gladiator' => [[0, 0], [70, 30], [140, 0], [40, -120], [70, -140], [100, -120]],
    'collector' => [[0, 0], [10, -50], [100, -130], [100, 10], [190, -50], [200, 0]],
    'thief'     => [[0, 0], [40, 40], [20, -40], [40, -80], [-50, -10], [-60, 120]],
    'gatherer'  => [[0, 0], [40, -70], [-30, -140], [10, -200], [110, -170], [120, -90]],
    'protector' => [[0, 0], [-70, 0], [70, 0], [0, -70], [0, 70], [-130, 90]],
    'hunter'    => [[0, 0], [10, -140], [120, -60], [160, -190], [170, -20], [200, 0]]
  }
  connect = {
    'sleeper'   => [[0, 1], [1, 2], [3, 4], [4, 5]],
    'dreamer'   => [[0, 1], [1, 2], [2, 3], [3, 4], [5]],
    'rise'      => [[0, 1], [1, 2], [3, 4], [4, 5]],
    'farmer'    => [[0, 1], [1, 5], [1, 4], [2, 3], [3, 4]],
    'dancer'    => [[0, 1], [1, 2], [3, 4], [4, 5]],
    'wave'      => [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5]],
    'gladiator' => [[0, 1], [1, 2], [2, 5], [3, 4], [4, 5], [0, 3]],
    'collector' => [[0, 1], [0, 3], [2, 3], [3, 5], [4, 5]],
    'thief'     => [[0, 1], [0, 2], [0, 4], [1, 5], [2, 3], [4, 5]],
    'gatherer'  => [[0, 1], [2, 3], [2, 5], [3, 4], [4, 5]],
    'protector' => [[0, 1], [0, 2], [0, 3], [0, 4], [1, 3], [1, 4], [2, 3], [2, 4], [5]],
    'hunter'    => [[0, 1], [0, 4], [1, 2], [1, 3], [2, 4], [3, 4], [4, 5]]
  }
  found = coords.map do |c|
    (seek = map[which].map { |m| m + c }).all? { |k| coords.include? k } ? seek : nil
  end.compact[0]

  x = found.map { |f| f[0] }.reduce(:+).abs
  x = x.to_s.split(//).map(&:to_i).reduce(:+) if x > 99
  y = found.map { |f| f[1] }.reduce(:+).abs
  y = y.to_s.split(//).map(&:to_i).reduce(:+) if y > 99
  return [x, y] if spellbook

  qs = connect[which].map { |e| [e, e.reverse].uniq }.flatten(1).map do |c|
    c.map { |i| found[i] * ',' } * ';'
  end * '|'
  get PLOT_DATA + CGI.escape(qs)
end

username = (print 'Username: '; gets.chomp)
password = (print 'Password: '; gets.chomp)
puts "\nSet proxy (#.#.#.#:#) / leave blank otherwise."
proxy = (print 'Proxy: '; gets.chomp)
puts "\nSet program delay (seconds):"
Delay = (print 'Delay: '; gets.chomp.to_f)

if proxy.empty?
  Conn = Net::HTTP.start('www.neopets.com')
else
  Conn = Net::HTTP::Proxy(*proxy.split(':')).start('www.neopets.com')
end

Headers = {}
resp = post '/login.phtml', 'username' => username, 'password' => password
cookie = resp.get_fields('Set-Cookie').map { |c| c.split(';')[0] } * ';'
Headers['Cookie'] = cookie

ARCHIVES    = '/altador/archives.phtml'
ARCHIVIST   = '/altador/archives.phtml?archivist=1'
BANK        = '/process_bank.phtml'
BASEMENT    = '/altador/hallofheroes.phtml?basement=1'
CLOUDS      = '/altador/clouds.phtml'
COLOSSEUM   = '/altador/colosseum.phtml'
COUNCIL     = '/altador/council.phtml'
DOCKS       = '/altador/docks.phtml'
DONNY       = '/winter/brokentoys.phtml'
FARM        = '/altador/farm.phtml'
GET_BOOK    = '/altador/archives.phtml?archivist=1&get_book=1&acpcont=1'
GET_ROCK    = '/altador/quarry.phtml?get_rock=1&acpcont=1'
HALL        = '/altador/hallofheroes.phtml'
JANITOR     = '/altador/hallofheroes.phtml?janitor=1'
PETPET      = '/altador/petpet.phtml?ppheal=1'
PLOT_DATA   = '/altador/astro.phtml?star_submit='
PUSH_BUTTON = '/altador/hallofheroes.phtml?janitor=1&push_button=1'
QUARRY      = '/altador/quarry.phtml'
SHOP        = '/objects.phtml?type=shop&obj_type='
STAIRS      = '/altador/hallofheroes.phtml?stairs=1'
STAR_DATA   = '/altador/astro.phtml?get_star_data=1'
TOMB        = '/altador/tomb.phtml'
VIEW_STATUE = '/altador/hallofheroes.phtml?view_statue_id='
WALL        = '/altador/wall.phtml'

step_finder = {
  'begin'          => "I'm Finneus",
  'get_book'       => "perhaps there's a book",
  'replace_book'   => "stabilise this table",
  'get_oil'        => "would someone print",
  'join_astro'     => "opened?  What a marvel!",
  'sleeper_act'    => "you've joined the Astronomy Club",
  'sleeper_plot'   => "front of that old tomb?",
  'dreamer_act'    => "Her eyes, in fact?",
  'dreamer_plot'   => "floating in the clouds?",
  'rise_act'       => "seems to concern Psellia",
  'rise_plot'      => "conspires to bring us wisdom",
  'farmer_act'     => "Ah, Siyana.",
  'farmer_plot'    => "in a pattern of wheat",
  'dancer_act'     => "bringing us foodstuffs",
  'dancer_plot'    => "underground dancing establishment",
  'wave_act'       => "those dancing ruffians",
  'wave_plot'      => "And the waves, too",
  'gladiator_act'  => "revealed by the sea",
  'gladiator_plot' => "on a drinking vessel?",
  'collector_act'  => "And found at the Colosseum",
  'collector_plot' => "an item relating to money",
  'thief_act'      => "suspected: Gordos",
  'thief_plot'     => "my poor Meepit plushie",
  'find_petpet'    => "constellation found on a dagger",
  'gatherer_act'   => "What a poor little Vaeolus!",
  'gatherer_plot'  => "get back to his owner",
  'protector_act'  => "Gatherer, protector of Petpets",
  'protector_plot' => "someone with nothing to hide",
  'open_ceiling'   => "we come to Jerdana",
  'basement'       => "We may as well get this over with.",
  'hunter_act'     => "probably isn't in the same",
  'hunter_plot'    => "but simple physical mechanics",
  'book_of_ages'   => "each of the twelve Heroes",
  'spellbook'      => "I'd overlooked that drawing of",
  'finish'         => "well-deserved vacation"
}

puts 'Checking next step'
status = get(ARCHIVIST)[/<IMG.+?altador.+?DIV><BR>(.+?)<cen/, 1]
steps = step_finder.keys
current = steps.find { |s| status.include? step_finder[s] }
steps.shift steps.index(current)

while step = steps.shift
  case step
  when 'begin'
    post "#{PUSH_BUTTON}&acpcont=1"
    puts 'Pushing button.'

  when 'get_book'
    post GET_BOOK
    puts 'Getting book.'

  when 'replace_book'
    post GET_BOOK
    post GET_ROCK
    puts 'Getting rock.'
    post GET_BOOK
    puts 'Replacing book.'

  when 'get_oil'
    puts 'Finding the oil.'
    get HALL
    html = get JANITOR
    unless html[/put some on the button/]
      get PUSH_BUTTON
      statue, oil_link = rand(1..12), nil
      puts "Refreshing statue #{statue}."
      until (oil_link = html[/action='(.+?soh=.+?)'/, 1])
        html = get "#{VIEW_STATUE}#{statue}"
      end
      get oil_link
    end
    puts 'Oiling the statue.'
    get PUSH_BUTTON
    post "#{PUSH_BUTTON}&acpcont=1"

  when 'join_astro'
    post ARCHIVES, 'board' => 6, 'join_club' => 1
    puts 'Joining the Astronomy Club.'

  when 'sleeper_act'
    html = get TOMB
    get html[/href="([^<>]+?thv=.+?)"/, 1]
    puts 'Found the Sleeper constellation.'
    get ARCHIVIST

  when 'sleeper_plot'
    plot 'sleeper'
    puts 'Completed the Sleeper constellation.'

  when 'dreamer_act'
    html = get CLOUDS
    get html[/href="([^<>]+?chv=.+?)"/, 1]
    puts 'Found the Dreamer constellation.'
    get ARCHIVIST

  when 'dreamer_plot'
    plot 'dreamer'
    puts 'Completed the Dreamer constellation.'

  when 'rise_act'
    html = get TOMB
    get html[/href="([^<>]+?acvhv=.+?)"/, 1]
    html = get "#{VIEW_STATUE}11"
    html = get html[/href="([^<>]+?vwhv=.+?)"/, 1]
    get html[/href="([^<>]+?rhv=.+?)"/, 1]
    puts 'Found the First to Rise constellation.'
    get ARCHIVIST

  when 'rise_plot'
    plot 'rise'
    puts 'Completed the First to Rise constellation.'

  when 'farmer_act'
    html = get FARM
    html = get html[/href="([^<>]+?windmill=.+?)"/, 1]
    html = get html[/href="([^<>]+?umhv=.+?)"/, 1]
    html = get html[/href="([^<>]+?vfhv=.+?)"/, 1]
    get html[/href="([^<>]+?wfhv=.+?)"/, 1]
    puts 'Found the Farmer constellation.'
    get ARCHIVIST

  when 'farmer_plot'
    plot 'farmer'
    puts 'Completed the Farmer constellation.'

  when 'dancer_act'
    html = get "#{ARCHIVES}?board=7"
    get html[/href="([^<>]+?swhv=.+?)"/, 1]
    puts 'Found the Dancer constellation.'
    get ARCHIVIST

  when 'dancer_plot'
    plot 'dancer'
    puts 'Completed the Dancer constellation.'

  when 'wave_act'
    html = get DOCKS
    get html[/href="([^<>]+?wchv=.+?)"/, 1]
    puts 'Found the Wave constellation.'
    get ARCHIVIST

  when 'wave_plot'
    plot 'wave'
    puts 'Completed the Wave constellation.'

  when 'gladiator_act'
    get "#{ARCHIVES}?board=6"
    puts 'Awarded a Broken Astrolabe.'
    html = get DONNY
    get (url = html[/href="([^<>]+?repair_id=.+?)"/, 1])
    post DONNY, 'repair_id' => url.split('=')[1], 'confirm' => 1
    puts 'Trying to fix the Broken Astrolabe.'

    html = get COLOSSEUM
    puts 'Finding the Punch Club.'
    links = html.scan(/href="([^<>]+?pchv=.+?)"/).flatten.shuffle
    html, arch = '487738fe33.gif', 0
    while html.include? '487738fe33.gif'
      puts "Try ##{arch += 1}."
      html = get($punch_club = links.pop)
    end
    puts 'Found the Punch Club.'
    html = get "#{$punch_club}&pc_go=1"
    bowls, found = html.scan(/punch1=(.+?)"/), nil
    puts 'Testing combinations.'
    found = nil
    [*(0..26)].shuffle.each_with_index do |n, c|
      puts "Combination ##{c + 1}."
      qs, perm = [], [n / 9, n / 3 % 3, n % 3].map { |i| bowls[i] }
      perm.each_with_index { |p, i| qs << "punch#{i + 1}=#{p[0]}"}
      html = get "#{$punch_club}&pc_go=1&#{qs * '&'}"
      break if (found = html[/href="([^<>]+?gchv=.+?)"/, 1])
    end
    html = get found
    get html[/href="([^<>]+?olhv=.+?)"/, 1]
    puts 'Found the Gladiator constellation.'
    get ARCHIVIST

  when 'gladiator_plot'
    plot 'gladiator'
    puts 'Completed the Gladiator constellation.'

  when 'collector_act'
    found = nil
    (94..96).each do |id|
      html = get "#{SHOP}#{id}"
      cur = html[/tory">(.+?)</, 1].gsub(/[^\d]/, '').to_i
      amount = html[/at <b>(.+?)%</, 1].gsub('.', '').to_i
      if cur != amount
        puts "Setting NP to #{amount}"
        post BANK, 'type' => (cur < amount ? 'withdraw' : 'deposit'), 'amount' => (cur - amount).abs
      end
      html = get "#{SHOP}#{id}"
      break if (found = html[/href="([^<>]+?gohv=.+?)"/, 1])
    end
    get found
    puts 'Found the Collector constellation.'
    get ARCHIVIST

  when 'collector_plot'
    plot 'collector'
    puts 'Completed the Collector constellation.'

  when 'thief_act'
    puts 'Meepit part.'
    get "#{ARCHIVES}?lclenny=1"
    html = get ARCHIVIST
    html = get html[/href="([^<>]+?distract=.+?)"/, 1]
    get html[/href="([^<>]+?steal=.+?)"/, 1]
    get "#{ARCHIVES}?lclenny=1"
    html = get ARCHIVES
    html = get html[/href="([^<>]+?goarch=.+?)"/, 1]
    3.times { html = get html[/href="([^<>]+?cmhv=.+?)"/, 1] }
    html = get (url = html[/href="([^<>]+?closet=.+?)"/, 1])
    post ARCHIVES, 'closet' => url.split('=')[-1], 'hide_box' => 1
    html = get ARCHIVIST
    html = get html[/href="([^<>]+?distract=.+?)"/, 1]
    get html[/href="([^<>]+?steal=.+?)"/, 1]
    html = get "#{ARCHIVES}?lclenny=1&acpcont=1"
    get html[/href="([^<>]+?rdhv=.+?)"/, 1]
    puts 'Found the Thief constellation.'
    get ARCHIVIST

  when 'thief_plot'
    plot 'thief'
    puts 'Completed the Thief constellation.'
    get "#{ARCHIVES}?board=7"

  when 'find_petpet'
    puts 'Searching Vaeolus.'
    [FARM, DOCKS, QUARRY].each do |loc|
      found = get(loc)[/href="([^<>]+?pphv=.+?)"/, 1]
      get("/altador/#{found}") if found
    end
    get ARCHIVIST

  when 'gatherer_act'
    puts 'Curing Vaeolus.'
    get PETPET
    html = get "#{ARCHIVES}?board=5"
    if (url = html[/href="([^<>]+?bmhv=.+?)"/, 1])
      get "#{url}&acpcont=1"
      puts 'Getting medicine.'
    end
    if $punch_club
      puts 'Time for Punch Club.'
    else
      html = get COLOSSEUM
      puts 'Finding Punch Club again.'
      links = html.scan(/href="([^<>]+?pchv=.+?)"/).flatten.shuffle
      html, arch = '487738fe33.gif', 0
      while html.include? '487738fe33.gif'
        puts "Try ##{arch += 1}..."
        html = get($punch_club = links.pop)
      end
      puts 'Found Punch Club.'
    end
    html = get "#{$punch_club}&pc_go=1"
    if (url = html[/href="([^<>]+?sphv=.+?)"/, 1])
      get "#{url}&acpcont=1"
      puts 'Getting Blueberry Pie.'
    end
    tomb = get(TOMB)[/href="([^<>]+?tehv=.+?)"/, 1]
    html, i = 'dc697034c4.gif', 0
    puts 'Refreshing for bandage.'
    while html.include? 'dc697034c4.gif'
      html = get tomb
      if (i += 1) > 35
        have_bandage = true
        puts 'Already have it.'
        break
      end
    end
    unless have_bandage
      html = get (url = html[/href="([^<>]+?gbhv=.+?)"/, 1])
      puts "Got bandage."
      get "#{url}&acpcont=1"
    end
    html = get PETPET
    until html.include? 'b1022d8a5a.gif'
      act = html[/act_(.)/, 1]
      links = html.split('300"')[1].split('<c')[0].scan(/href="(.+?)"/).flatten
      html = get (url = links['bacd'.index(act)])
      puts case act
        when 'a' then 'Bandaging.'
        when 'b' then 'Feeding.'
        when 'c' then 'Medicating.'
        else 'Waiting.'
      end
      delay = 60 - html[/ns = (\d+)/, 1].to_i
      puts "Waiting #{delay} seconds..."
      sleep delay
      html = get html.split('300"')[1].split('<c')[0].scan(/href="(.+?)"/).flatten[-1]
    end
    get html[/href="([^<>]+?pchv=.+?)"/, 1]
    puts 'Found the Gatherer constellation.'
    get "#{ARCHIVES}?board=6"
    get ARCHIVIST

  when 'gatherer_plot'
    plot 'gatherer'
    puts 'Completed the Gatherer constellation.'

  when 'protector_act'
    html = get QUARRY
    html = get WALL
    html = get html[/href="([^<>]+?sdhv=.+?)"/, 1]
    html = get(url = html[/href="([^<>]+?tnhv=.+?)"/, 1])
    get "#{url}&acpcont=1"
    get FARM
    switches, i = %w[r1v1 r1v2 r2v3 r2v4 r2s1 r3s2 r3s3 r3s4], 0
    puts 'Water Plant Switches.'
    until html.include? '611538397c.gif'
      s, i = switches.sample, i + 1
      html = get "/altador/plant.phtml?room=#{s[1]}&act=#{s}"
    end
    puts "A long time later (or not, if you're lucky)..."
    html = get WALL
    html = get html[/href="([^<>]+?sdhv=.+?)"/, 1]
    html = get html[/href="([^<>]+?tnhv=.+?)"/, 1]
    html = get html[/href="([^<>]+?olhv=.+?)"/, 1]
    puts "Found the Protector constellation."
    get ARCHIVIST

  when "protector_plot"
    resp = plot "protector"
    puts "Completed the Protector constellation."

  when 'open_ceiling'
    html = get STAIRS
    trip = html[/"trip" value="(.+?)"/, 1]
    html = post(HALL, 'trip' => trip).body
    get html[/href="([^<>]+?hohv=.+?)"/, 1]
    puts 'Opening the roof.'
    get ARCHIVIST

  when 'basement'
    get JANITOR
    get BASEMENT
    puts 'Activating the basement.'

  when 'hunter_act'
    html = get QUARRY
    if (url = html[/href="([^<>]+?brhv=.+?)"/, 1])
      html = get url
      post QUARRY, 'brhv' => url.split('=')[1], 'go_buy_rock' => 1
      puts 'Buying a rock.'
    end
    get JANITOR
    get "#{BASEMENT}&gear=0"
    get HALL
    get "#{BASEMENT}&gear=0"
    html = get QUARRY
    if (url = html[/href="([^<>]+?trhv=.+?)"/, 1])
      html = get url
      html = get html[/href="([^<>]+?srhv=.+?)"/, 1]
      html = get html[/href="([^<>]+?gthv=.+?)"/, 1]
      puts 'Getting the second rock.'
    end
    html = get "#{ARCHIVES}?board=1"
    html = get "#{ARCHIVES}?board=1&circus=1"
    html = get "#{ARCHIVES}?board=1&juggle=1"
    html = get QUARRY
    if (url = html[/href="([^<>]+?jjhv=.+?)"/, 1])
      html = get url
      post QUARRY, 'jjhv' => url.split('=')[1], 'r3hv' => html[/"r3hv" value="(.+?)"/, 1]
      puts 'Getting the third rock.'
    end
    puts "Sorting gears."
    begin
      html, offset, gears = '', 0, [*(0..9)].shuffle
      until html[/MAP/]
        gear = gears.pop
        get "#{BASEMENT}&gear=#{gear}"
        html = get PUSH_BUTTON
        if html[/stupid rocks and such/]
          puts 'Roof reseted'
          raise ArgumentError
        end
        moved = html[/_r(\d+)_/, 1].to_i / 5
        if (4..6) === moved - offset
          offset += moved
          puts "Gear #{gear} matches."
        else
          puts "#{gear} doesn't match."
          get "#{BASEMENT}&gear=#{gear}"
        end
      end
    rescue ArgumentError
      retry
    end
    get html[/href="([^<>]+?olhv=.+?)"/, 1]
    puts 'Found the Hunter constellation.'

  when 'hunter_plot'
    plot 'hunter'
    puts 'Completed the Hunter constellation.'

  when 'book_of_ages'
    html = get "#{ARCHIVIST}&examine_book=1&view_page=53"
    get html[/href="([^<>]+?dfhv=.+?)"/, 1]
    puts "Clicking Darkest Faerie's hands."
    get ARCHIVIST

  when 'spellbook'
    html = get ARCHIVES
    html = get html[/href="([^<>]+?goarch=.+?)"/, 1]
    url = html[/href="([^<>]+?cmhv=.+?)"/, 1]
    x, y = plot 'sleeper', true
    html = get url.gsub(/arcx=\d+&arcy=\d+/, "arcx=#{x}&arcy=#{y}")
    puts 'Found archive room, finding the book.'
    links, i = html.scan(/href="([^<>]+?read_book=.+?)"/).flatten.shuffle, 0
    until html[/52,143/]
      puts "Try ##{i += 1}..."
      html = get(data = links.pop)
    end
    puts 'Found book, casting spell #29884..'
    resp = post ARCHIVES, "#{data.split('?')[1]}&spell_id=29884"
    html = get "#{VIEW_STATUE}6"
    html = get html[/href="([^<>]+?necklace=.+?)"/, 1]
    puts 'Placing the necklace.'
    post COUNCIL, 'ephv' => html[/\?ephv=(.+?)'/, 1]

  when 'finish'
    html = get COUNCIL
    get html[/href="([^<>]+?prhv=.+?)"/, 1]
    puts 'We are now finished. Feel free to close the program.'
    gets
  end
end
