require 'jubatus/classifier/client'

NUM = 5
class Meal
  def initialize(host='127.0.0.1', port=9199)
    @jubatus = Jubatus::Classifier::Client::Classifier.new(host, port)
  end

  def train(label, data)
    rn = 0
    begin
      datum = Jubatus::Common::Datum.new
      datum.add_binary(data)
      @jubatus.train(datum)
    rescue MessagePack::RPC::TimeoutError
      if rn < NUM
        rn += 1
        retry
      end
    end
  end

  def read_image(path)
    label = path.split('/')[-2]
    data = File.open(path).read()
    [label, data]
  end
end

m = Meal.new
path = 'images'

option = ARGV[0]
if option == 'train'
  Dir.entries(path).each do |dir|
    p = [path, dir].join('/')
    if File.directory?(p) && dir =~ /^\./
      Dir.entries(p).each do |jpg|
        if jpg =~ /^\./
          label, data = m.read_image([p,jpg].join('/'))
          m.train(label, data)
        end
      end
    end
  end
else
  Dir.entries(path).each do |file|
    p = [path, file].join('/')
    unless File.directory?(p)
      image = m.read_image(p)[1]
      r = m.classify(image)
      m.result(r)
    end
  end
end
