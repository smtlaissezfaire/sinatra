require File.dirname(__FILE__) + "/helper"

describe "Layouts test" do
  def render_app(&block)
    mock_app {
      def render_test(template, data, options, &block)
        inner = block ? block.call : ''
        data + inner
      end
      set :views, File.dirname(__FILE__) + '/views'
      get '/', &block
      template(:layout3) { "Layout 3!\n" }
    }
    get '/'
  end

  def with_default_layout
    layout = File.dirname(__FILE__) + '/views/layout.test'
    File.open(layout, 'wb') { |io| io.write "Layout!\n" }
    yield
  ensure
    File.unlink(layout) rescue nil
  end

  it 'uses the default layout template if not explicitly overridden' do
    with_default_layout do
      render_app { render :test, :hello }
      assert ok?
      assert_equal "Layout!\nHello World!\n", body
    end
  end

  it 'uses the default layout template if not really overriden' do
    with_default_layout do
      render_app { render :test, :hello, :layout => true }
      assert ok?
      assert_equal "Layout!\nHello World!\n", body
    end
  end

  it 'uses the layout template specified' do
    render_app { render :test, :hello, :layout => :layout2 }
    assert ok?
    assert_equal "Layout 2!\nHello World!\n", body
  end

  it 'uses layout templates defined with the #template method' do
    render_app { render :test, :hello, :layout => :layout3 }
    assert ok?
    assert_equal "Layout 3!\nHello World!\n", body
  end
end
