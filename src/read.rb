require 'jubatus'

NUM = 5
class Meal
  def initialize(host='127.0.0.1', port=9199)
    @jubatus = Jubatus::Classifier::Client::Classifier.new('127.0.0.1', 9199)
  end

  def train(label, data)
    rn = 0
    begin
      datum = Jubatus::Common::Datum.new(data)
      @jubatus.train(datum)
    rescue MessagePack::RPC::TimeoutError
      if rn < NUM
        sleep
        rn += 1
        retry
      end
    end
  end

  def read_image(path)
    label = path.split('/')[-2]
    data = {image: File.open(path).read()}
    [label, data]
  end
end
