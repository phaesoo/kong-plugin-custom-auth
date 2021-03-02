local http = require "resty.http"
local json = require "cjson"

local TokenHandler = {
  PRIORITY = 1000,
  VERSION = "0.1",
}

function TokenHandler:access(conf)
  kong.log.inspect(conf)

  local jwt_token = kong.request.get_header(conf.token_header)
  if not jwt_token then
    kong.log.debug("Token not found in header")
    kong.response.exit(401)
  end

  local token_type = jwt_token:sub(0,7)
  if token_type ~= "Bearer " then
    kong.log.debug("Invalid token type: ", token_type)
    kong.response.exit(401)
  end
  
  kong.log.debug(conf.auth_host, conf.auth_port)

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
      path = kong.request.get_path(),
      raw_query = kong.request.get_raw_query(),
    }),
  })

  if not res then
    kong.log.err("Failed to call auth_endpoint:", err)
    return kong.response.exit(500)
  end

  if res.status ~= 200 then
    kong.log.debug("Authentication failed", res.status)
    return kong.response.exit(401) -- unauthorized
  end
end

return TokenHandler
