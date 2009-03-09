require File.dirname(__FILE__) + "/helper"

describe "Using a rendering engine" do
  def engines
    Sinatra::RenderingEngine::Base.engines
  end

  it "should have a map of the symbol => constant (as a symbol)" do
    default_engines = {
      :erb     => :ERBRenderer,
      :builder => :BuilderRenderer,
      :haml    => :HamlRenderer,
      :sass    => :SassRenderer
    }

    assert_equal default_engines, engines
  end

  def use_engine(*args)
    Sinatra::RenderingEngine::Base.use_engine(*args)
  end

  it "should use a ERBRenderer when given :erb" do
    context = self

    engine = use_engine(:erb, context)

    assert engine.kind_of?(Sinatra::RenderingEngine::ERBRenderer)
    assert engine.context.equal?(context)
  end

  it "should use a BuilderRenderer when given :builder" do
    context = self

    engine = use_engine(:builder, context)

    assert engine.kind_of?(Sinatra::RenderingEngine::BuilderRenderer)
    assert engine.context.equal?(context)
  end

  it "should use a HamlRenderer when given :haml" do
    context = self

    engine = use_engine(:haml, context)

    assert engine.kind_of?(Sinatra::RenderingEngine::HamlRenderer)
    assert engine.context.equal?(context)
  end

  it "should use a HamlRenderer when given :sass" do
    context = self

    engine = use_engine(:sass, context)

    assert engine.kind_of?(Sinatra::RenderingEngine::SassRenderer)
    assert engine.context.equal?(context)
  end

  it "should be able to use an engine when given a string" do
    context = self

    engine = use_engine("sass", context)

    assert engine.kind_of?(Sinatra::RenderingEngine::SassRenderer)
    assert engine.context.equal?(context)
  end

  it "should raise an EngineNotFound error if it cannot use the symbol" do
    assert_raise Sinatra::RenderingEngine::Base::EngineNotFound do
      use_engine(:foo, self)
    end
  end
end
