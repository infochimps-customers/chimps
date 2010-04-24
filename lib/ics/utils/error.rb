module ICS
  ICSError            = Class.new(StandardError)
  AuthenticationError = Class.new(ICSError) # 401 from server
  CLIError            = Class.new(ICSError) # bad input from user
  ServerError         = Class.new(ICSError) # 5xx from server
  PackagingError      = Class.new(ICSError) # IMW error
  UploadError         = Class.new(ICSError) # S3 error
end

