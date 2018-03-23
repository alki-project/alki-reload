require 'alki/feature_test'

describe 'Instances' do
  it 'should automatically reload when files change' do
    @instance.settings.val.must_equal '<<one>>'
    set_val 'two'
    @instance.settings.val.must_equal '<<two>>'
  end

  it 'should reload again if files change again' do
    @instance.settings.val.must_equal '<<one>>'
    set_val 'two'
    @instance.settings.val.must_equal '<<two>>'
    set_val 'three'
    @instance.settings.val.must_equal '<<three>>'
  end

  it 'should work again after syntax error' do
    @instance.settings.val.must_equal '<<one>>'
    set_val '"}"'
    assert_raises SyntaxError do
      @instance.settings.val
    end
    set_val 'two', false
    @instance.settings.val.must_equal '<<two>>'
  end
end
