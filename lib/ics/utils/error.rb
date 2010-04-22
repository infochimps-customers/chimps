module ICS
  ICSError            = Class.new(StandardError)
  AuthenticationError = Class.new(ICSError)
  CLIError            = Class.new(ICSError)
  ServerError         = Class.new(ICSError)
  PackagingError      = Class.new(ICSError)
end

