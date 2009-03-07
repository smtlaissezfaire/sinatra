class String #:nodoc:
  # Define String#each under 1.9 for Rack compatibility. This should be
  # removed once Rack is fully 1.9 compatible.
  alias_method :each, :each_line  unless ''.respond_to? :each

  # Define String#bytesize as an alias to String#length for Ruby 1.8.6 and
  # earlier.
  alias_method :bytesize, :length unless ''.respond_to? :bytesize
end
