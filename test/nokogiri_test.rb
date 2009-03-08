require File.dirname(__FILE__) + "/helper"

describe "Nokogiri test" do
  def nokogiri_app(&block)
    mock_app do
      set :views, File.dirname(__FILE__) + "/views"
      get '/', &block
    end
    
    get "/"
  end

  it "renders inline blocks" do
    nokogiri_app do
      ng do
        html do
          text "something"
        end
      end
    end
    
    assert ok?
    assert_equal "<html>something</html>", body
  end

  it "renders the string given by ng" do
    nokogiri_app do
      ng do
        html do
          text "foo"
        end
      end
    end
    
    assert ok?
    assert_equal "<html>foo</html>", body
  end

  it "has scope to the rest of the action" do
    nokogiri_app do
      bar = "foo"

      ng do
        html do
          text bar
        end
      end
    end

    assert ok?
    assert_equal "<html>foo</html>", body
  end

  it "renders .ng files in the views path" do
    nokogiri_app { ng :hello }
    assert ok?
    assert_equal "<html>Hello World</html>", body
  end

  it "can pass locals with a template name" do
    nokogiri_app do
      var = "value"
      ng :locals_test, :locals => { :var => var }
    end

    assert ok?
    assert_equal "<html>value</html>", body
  end

  it "renders with block layouts" do
    mock_app do
      layout do
        html do
          text "THIS IS "
          cdata content_for_layout
        end
      end
      
      get('/') do
        ng do
          span do
            text "SPARTA"
          end
        end
      end
    end
    
    get '/'
    assert ok?
    assert_equal "<html>THIS IS <span>SPARTA</span>\n</html>", body
  end

  it "renders with file layouts" do
    mock_app do
      set :views, File.dirname(__FILE__) + "/views"

      get '/' do
        ng :hello, :layout => :layout2
      end
    end

    get '/'
    assert ok?
    assert_equal "<html>nokogiri Layout: Hello World</html>", body
  end

  it "renders with file layouts, using the special variable 'content_for_layout'" do
    mock_app do
      set :views, File.dirname(__FILE__) + "/views"

      get '/' do
        ng :hello2, :layout => :layout3
      end
    end

    get '/'
    assert ok?
    assert_equal "<html>nokogiri Layout: <body>Hello World</body>\n</html>", body
  end
end
