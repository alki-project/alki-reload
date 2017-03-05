require 'alki/feature_test'

describe 'Instances' do
  it 'should automatically reload when files change' do
    @instance.settings.val.must_equal '<<one>>'
    set_val 'two'
    @instance.settings.val.must_equal '<<two>>'
  end
end
