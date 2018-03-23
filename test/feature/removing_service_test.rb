require 'alki/feature_test'

describe 'Removing service' do
  before do
    add_new_service
    write_service_class
    @instance.new_service
  end

  describe 'when just the class file has been deleted' do
    before do
      delete_service_class
    end

    it 'should raise load error when service is called' do
      assert_raises LoadError do
        @instance.new_service
      end
    end
  end

  describe 'when just the class definition has been deleted' do
    before do
      write_service_class_file("")
    end

    it 'should raise name error when service is called' do
      assert_raises NameError do
        @instance.new_service
      end
    end
  end

  describe 'when service is removed' do
    before do
      reset_assembly
    end

    it 'should raise no method error when service is called' do
      assert_raises NoMethodError do
        @instance.new_service
      end
    end
  end
end
