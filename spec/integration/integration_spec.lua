local helpers = require "spec.helpers"


local PLUGIN_NAME = "custom-auth"


for _, strategy in helpers.each_strategy() do
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

    lazy_setup(function()

      local bp = helpers.get_db_utils(strategy, nil, { PLUGIN_NAME })

      -- Inject a test route. No need to create a service, there is a default
      -- service which will echo the request.
      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
      })
      -- add the plugin to test to the route we created
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route1.id },
        config = {},
      }

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins = "bundled," .. PLUGIN_NAME,
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)



    describe("request", function()
      local http = require 'resty.http'
      http.new = function()
        return {
          connect = function(self, args)
            return 1
          end,
          request = function(self, args)
            -- ... some mock implementation
            return 1
          end,
          set_timeout = function(self, args)
            -- ... some mock implementation
            return 1
          end
        }
      end
      it("gets a 'hello-world' header", function()
        local r = client:get("/request", {
          headers = {
            auth_host = "test1.com",
            auth_port = 8080,
            token_header = "asdasd"
          }
        })

      end)
    end)


  end)
end
