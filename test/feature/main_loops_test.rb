require 'alki/feature_test'

describe 'Main loops' do
  def get_val
    @svc
  end

  it 'should automatically reload dependencies if tagged as :main_loop' do
    @svc = @instance.main
    get_val.must_equal '<<one>>'
    set_val 'two'
    get_val.must_equal '<<two>>'
  end

  it 'should not reload depdendencies if not tagged as :main_loop' do
    @svc = @instance.not_main
    get_val.must_equal '<<one>>'
    set_val 'two'
    get_val.must_equal '<<one>>'
  end

  it 'should raise proper error when reloaded file has error' do
    @svc = @instance.main
    get_val.must_equal '<<one>>'
    set_val '#{1.foo}'
    assert_raises NoMethodError do
      get_val == '<<one>>'
    end
  end

  it 'should work again after syntax error' do
    @svc = @instance.main
    get_val.must_equal '<<one>>'
    set_val '"}"'
    assert_raises SyntaxError do
      get_val == ''
    end
    set_val 'two', false
    get_val.must_equal '<<two>>'
  end

  describe 'when a new class is added with a syntax error' do
    before do
      @svc = @instance.interface
      write_broken_service_class
      add_new_service
    end

    it 'should raise an error when accessed through main loop' do
      assert_raises SyntaxError do
        @svc.lookup('new_service')
      end
    end

    describe 'which is then fixed' do
      before do
        assert_raises SyntaxError do
          @svc.lookup('new_service')
        end

        write_service_class
      end

      it 'should allow accessing fixed service through main loop' do
        @svc.lookup('new_service').val.must_equal 1
      end

      it 'should raise correct error if invalid method on service is called' do
        assert_raises NoMethodError do
          @svc.lookup('new_service').foo
        end
      end
    end
  end
end
