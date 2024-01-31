---@diagnostic disable: undefined-field, unused-local, need-check-nil, param-type-mismatch
local cwd = vim.fn.getcwd()

describe("detail.yanks", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
    vim.opt.swapfile = false
  end)

  require("fzfx.config").setup()
  local yanks = require("fzfx.detail.yanks")

  describe("[Yank]", function()
    it("creates", function()
      local yk =
        yanks.Yank:new("regname", "regtext", "regtype", "filename", "filetype")
      assert_eq(type(yk), "table")
      assert_eq(yk.regname, "regname")
      assert_eq(yk.regtext, "regtext")
      assert_eq(yk.regtype, "regtype")
      assert_eq(yk.filename, "filename")
      assert_eq(yk.filetype, "filetype")
    end)
  end)
  describe("[YankHistory]", function()
    it("creates", function()
      local yk = yanks.YankHistory:new(10)
      assert_eq(type(yk), "table")
    end)
    it("push/get", function()
      local yk = yanks.YankHistory:new(10)
      assert_eq(type(yk), "table")
      for i = 1, 10 do
        yk:push(i)
        local actual = yk:get()
        assert_eq(actual, i)
      end
    end)
  end)
  describe("[setup]", function()
    it("setup", function()
      yanks.setup()
      assert_eq(type(yanks._get_yank_history_instance()), "table")
    end)
  end)
  describe("[_get_register_info]", function()
    it("_get_register_info", function()
      yanks.setup()
      vim.cmd([[
            noautocmd edit README.md
            call feedkeys('V', 'n')
            ]])
      local actual = yanks._get_register_info("+")
      print(string.format("register info:%s\n", vim.inspect(actual)))
      assert_eq(actual.regname, "+")
      assert_eq(type(actual.regtext), "string")
      assert_true(string.len(actual.regtext) >= 0)
      assert_eq(type(actual.regtype), "string")
      assert_true(string.len(actual.regtype) >= 0)
      yanks.save_yank()
      local y = yanks.get_yank()
      print(string.format("yank:%s\n", vim.inspect(y)))
      assert_eq(type(y), "table")
      assert_eq(type(y.timestamp), "number")
      assert_true(y.timestamp >= 0)
    end)
  end)
end)
