require File.dirname(__FILE__) + "/helper"

describe "Resolving the rendering engine" do
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

  def resolve_engine(*args)
    Sinatra::RenderingEngine::Base.resolve_engine(*args)
  end

  it "should resolve the :erb symbol to the ERBRenderer" do
    context = self

    engine = resolve_engine(:erb, context)

    assert engine.kind_of?(Sinatra::RenderingEngine::ERBRenderer)
    assert engine.context.equal?(context)
  end

  it "should resolve the :builder symbol to the BuilderRenderer" do
    context = self

    engine = resolve_engine(:builder, context)

    assert engine.kind_of?(Sinatra::RenderingEngine::BuilderRenderer)
    assert engine.context.equal?(context)
  end

  it "should resolve the :haml symbol to the HamlRenderer" do
    context = self

    engine = resolve_engine(:haml, context)

    assert engine.kind_of?(Sinatra::RenderingEngine::HamlRenderer)
    assert engine.context.equal?(context)
  end

  it "should resolve the :sass symbol to the HamlRenderer" do
    context = self

    engine = resolve_engine(:sass, context)

    assert engine.kind_of?(Sinatra::RenderingEngine::SassRenderer)
    assert engine.context.equal?(context)
  end
end
