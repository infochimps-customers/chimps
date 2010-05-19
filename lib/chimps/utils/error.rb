module Chimps
  ChimpsError         = Class.new(StandardError)
  AuthenticationError = Class.new(ChimpsError) # 401 from server/missing user credentials
  CLIError            = Class.new(ChimpsError) # bad input from user
  ServerError         = Class.new(ChimpsError) # 5xx from server
  PackagingError      = Class.new(ChimpsError) # IMW error
  UploadError         = Class.new(ChimpsError) # S3 error
end

