require 'alki/feature_test'

describe "Adding service" do
  before do
    add_new_service
  end

  describe 'that is valid' do
    before do
      write_service_class 1
    end

    it 'should make the new service available' do
      @instance.new_service.val.must_equal 1
    end

    describe 'that is then changed' do
      before do
        @instance.new_service.val.must_equal 1
        @instance.__reloading__.must_equal false

        write_service_class 2
      end

      it 'should result in changed version' do
        @instance.new_service.val.must_equal 2
      end
    end
  end

  describe 'that has no methods' do
    before do
      write_empty_service_class
      @instance.new_service
    end

    describe 'and then a method is added' do
      before do
        write_service_class 1
      end

      it 'should make new method available' do
        @instance.new_service.val.must_equal 1
      end
    end
  end

  describe 'that has a syntax error' do
    before do
      write_broken_service_class
    end

    it 'should raise a syntax error when the service is first accessed' do
      assert_raises SyntaxError do
        @instance.new_service
      end
    end

    describe 'and is then fixed' do
      before do
        assert_raises SyntaxError do
          @instance.new_service
        end
        write_service_class
      end

      it 'should work' do
        @instance.new_service.val.must_equal 1
      end

      it 'should raise a NoMethodError if an invalid method is called' do
        assert_raises NoMethodError do
          @instance.new_service.val2
        end
      end
    end
  end
end
