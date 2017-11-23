require 'alki/feature_test'
require 'thread'

describe 'Main loops' do
  def run_loop(method)
    @input = Queue.new
    @output = Queue.new
    main_thread = Thread.current
    @thread = Thread.new do
      begin
        @instance.send(method).call @input, @output
      rescue => e
        main_thread.raise e
      end
    end
  end

  after do
    @input.push false
    @thread.join
  end

  def get_val
    @input.push true
    @output.pop
  end

  it 'should automatically reload dependencies if tagged as :main_loop' do
    run_loop :main
    get_val.must_equal '<<one>>'
    set_val 'two'
    get_val.must_equal '<<two>>'
  end

  it 'should not reload depdendencies if not tagged as :main_loop' do
    run_loop :not_main
    get_val.must_equal '<<one>>'
    set_val 'two'
    get_val.must_equal '<<one>>'
  end

  it 'should raise proper error when reloaded file has error' do
    run_loop :main
    get_val.must_equal '<<one>>'
    set_val '#{1.foo}'
    assert_raises NoMethodError do
      get_val == '<<one>>'
    end
  end
end
