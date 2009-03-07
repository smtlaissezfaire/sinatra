require File.dirname(__FILE__) + '/helper'

describe 'In file templating' do
  it 'loads templates from source file with use_in_file_templates!' do
    mock_app {
      use_in_file_templates!
    }
    assert_equal "this is foo\n\n", @app.templates[:foo]
    assert_equal "X\n= yield\nX\n", @app.templates[:layout]
  end
end

__END__

@@ foo
this is foo

@@ layout
X
= yield
X
