require File.dirname(__FILE__) + "/../helper"

describe "TemplateHandler" do
  before do
    @handler = Sinatra::RenderingEngine::TemplateHandler.new(self)
  end

  it "should have a layout if given a layout name" do
    assert_equal true, @handler.layout?(:layout => :foo)
  end

  it "should not have a layout if given :layout => false" do
    assert_equal false, @handler.layout?(:layout => false)
  end

  it "should not have a layout given any layout name" do
    assert_equal true, @handler.layout?(:layout => :bar)
  end
end
