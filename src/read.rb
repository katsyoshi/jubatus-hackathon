require 'jubatus/classifier/client'

NUM = 5
class Meal
  def initialize(host: '127.0.0.1', port: 9199, name: '')
    @jubatus = Jubatus::Classifier::Client::Classifier.new(host, port, name)
  end

  def train(data)
    rn = 0
    begin
      @jubatus.train(data)
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

m = Meal.new(name: 'hoge')
path = 'images'

Dir.entries(path).each do |dir|
  p = [path, dir].join('/')
  if File.directory?(p) && dir !~ /^\./
    Dir.entries(p).each do |jpg|
      if jpg !~ /^\./
        label, data = m.read_image([p,jpg].join('/'))
        datum = Jubatus::Common::Datum.new
        datum.add_binary('image', data)
        m.train([[label, datum]])
      end
    end
  end
end
