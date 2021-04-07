local http = require "resty.http"
local json = require "cjson"

local TokenHandler = {
  PRIORITY = 1000,
  VERSION = "0.1",
}

function TokenHandler:access(conf)
  kong.log.inspect(conf)

  local jwt_token = kong.request.get_header(conf.token_header)
  local headers = {
    ["Content-Type"] = "application/json",
  }
  if jwt_token then
    headers[conf.token_header] = jwt_token
  end
  
  local httpc = http.new()
  httpc:connect(conf.auth_host, conf.auth_port)
  
  local res, err = httpc:request({
    method = "POST",
    path = conf.auth_urlpath,
    headers = headers,
    body = json.encode({
      clientIP = kong.client.get_ip(),
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
    if res.status ~= 500 then
      return kong.response.exit(res.status)
    else
      kong.log.err("Internal server error", res.status)
      return kong.response.exit(500)
    end
  end
end

return TokenHandler
