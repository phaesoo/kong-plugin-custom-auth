local http = require "resty.http"
local json = require "cjson"

local TokenHandler = {
  PRIORITY = 1000,
  VERSION = "0.1",
}

function TokenHandler:access(conf)
  kong.log.inspect(conf)
  
  local httpc = http.new()
  httpc:connect(conf.auth_host, conf.auth_port)
  
  local res, err = httpc:request({
    method = "POST",
    path = conf.auth_urlpath,
    headers = {
      ["Content-Type"] = "application/json",
      [conf.token_header] = jwt_token
    },
    body = json.encode({
      method = kong.request.get_method(),
      urlPath = kong.request.get_path(),
      queryString = kong.request.get_raw_query(),
    }),
  })

  if not res then
    kong.log.err("Failed to call auth_endpoint:", err)
    return kong.response.exit(500)
  end

  if res.status ~= 200 then
    if res.status == 401 then
      kong.log.debug("Authentication failed", res.status)
      return kong.response.exit(401) -- unauthorized
    else
      kong.log.debug("Internal server error", res.status)
      return kong.response.exit(500)
    end
  end
end

return TokenHandler
