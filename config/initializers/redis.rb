###### MONKEYPATCH redis-rb
# https://github.com/redis/redis-rb/issues/364
# taken from https://github.com/redis/redis-rb/pull/389/files#diff-597c124889a64c18744b52ef9687c572R314
class Redis
  class Client
    def ensure_connected
      tries = 0

      begin
        if connected?
          if Process.pid != @pid
            reconnect
          end
        else
          connect
        end

        tries += 1

        yield
      rescue ConnectionError
        disconnect

        if tries < 2 && @reconnect
          retry
        else
          raise
        end
      rescue Exception
        disconnect
        raise
      end
    end
  end
end
## MONKEYPATCH end