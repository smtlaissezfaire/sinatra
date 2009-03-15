require File.dirname(__FILE__) + "/helper"

describe "Markaby test" do
  def markaby_app(&block)
    mock_app do
      set :views, File.dirname(__FILE__) + "/views"
      get '/', &block
    end
    
    get "/"
  end

  it "renders inline blocks" do
    markaby_app do
      mab do
        html do
          "something"
        end
      end
    end
    
    assert ok?
    assert_equal "<html>something</html>", body
  end

  it "renders the string given by mab" do
    markaby_app do
      mab do
        html do
          "foo"
        end
      end
    end
    
    assert ok?
    assert_equal "<html>foo</html>", body
  end

  it "has scope to the rest of the action" do
    markaby_app do
      bar = "foo"

      mab do
        html do
          bar
        end
      end
    end

    assert ok?
    assert_equal "<html>foo</html>", body
  end

  it "renders .mab files in the views path" do
    markaby_app { mab :hello }
    assert ok?
    assert_equal "<html>Hello World</html>", body
  end

  it "can pass locals with a template name, accessing the locals as instance variables" do
    markaby_app do
      var = "value"
      mab :locals_test, :locals => { :var => "value" }
    end

    assert ok?
    assert_equal "<html>value</html>", body
  end

  it "renders with block layouts, using the special ivar '@content_for_layout'" do
    mock_app do
      layout do
        html do
          text "THIS IS #{@content_for_layout}"
        end
      end
      
      get('/') do
        mab do
          "SPARTA"
        end
      end
    end
    
    get '/'
    assert ok?
    assert_equal "<html>THIS IS SPARTA</html>", body
  end

  it "renders with file layouts" do
    mock_app do
      set :views, File.dirname(__FILE__) + "/views"

      get '/' do
        mab :hello, :layout => :layout2
      end
    end

    get '/'
    assert ok?
    assert_equal "<html>markaby Layout: Hello World</html>", body
  end

  it "renders with file layouts, using the special ivar '@content_for_layout'" do
    mock_app do
      set :views, File.dirname(__FILE__) + "/views"

      get '/' do
        mab :hello2, :layout => :layout3
      end
    end

    get '/'
    assert ok?
    assert_equal "<html>markaby Layout: <body>Hello World</body></html>", body
  end
end
