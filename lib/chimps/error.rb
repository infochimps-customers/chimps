module Chimps
  # Base exception class for Chimps. All Chimps exceptions are
  # subclasses of Chimps::Error so they can be easily caught.
  Error = Class.new(StandardError)

  # Raised when the user hasn't specified any API credentials or the
  # server rejects the user's API credentials.
  #
  # Roughly corresponds to HTTP status code 401/403.
  AuthenticationError = Class.new(Error) 

  # Raised when the Infochimps server response is unexpected or
  # missing.
  #
  # Roughly corresponds to HTTP status code 5xx.
  ServerError = Class.new(Error)

  # Raised when there is an error in uploading to S3 or in notifiying
  # Infochimps of the new package.
  UploadError = Class.new(Error)

  # Raised when a subclass doesn't fails to implement required
  # methods.
  NotImplementedError = Class.new(Error)

  # Raised when the response from Infochimps isn't well-formed.
  ParseError = Class.new(Error)
end

