require File.dirname(__FILE__) + "/helper"

describe "Layouts test" do
  def render_app(&block)
    mock_app {
      set :views, File.dirname(__FILE__) + '/views'
      get '/', &block
      template(:layout3) { "Layout 3!\n<%= yield %>" }
    }
    get '/'
  end

  def with_default_layout
    layout = File.dirname(__FILE__) + '/views/layout.erb'
    File.open(layout, 'wb') { |io| io.write "Layout!\n<%= yield %>" }
    yield
  ensure
    File.unlink(layout) rescue nil
  end

  it 'uses the default layout template if not explicitly overridden' do
    with_default_layout do
      render_app { render :erb, :hello_generic }
      assert ok?
      assert_equal "Layout!\nHello World!\n", body
    end
  end

  it 'uses the default layout template if not really overriden' do
    with_default_layout do
      render_app { render :erb, :hello_generic, :layout => true }
      assert ok?
      assert_equal "Layout!\nHello World!\n", body
    end
  end

  it 'uses the layout template specified' do
    render_app { render :erb, :hello_generic, :layout => :layout2_generic }
    assert ok?
    assert_equal "Layout 2!\nHello World!\n", body
  end

  it 'uses layout templates defined with the #template method' do
    render_app { render :erb, :hello_generic, :layout => :layout3 }
    assert ok?
    assert_equal "Layout 3!\nHello World!\n", body
  end
end
