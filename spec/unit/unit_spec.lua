local PLUGIN_NAME = "custom-auth"


-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()


  it("accepts distinct request_header and response_header", function()
    local ok, err = validate({
        auth_host = "My-Request-Header",
        auth_port = 8080,
        auth_urlpath = "/url/path",
        token_header = "Authorization",
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)


end)
