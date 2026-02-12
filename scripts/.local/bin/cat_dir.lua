local supported_flags = { "excl", "dir", "sep", "help" }

local flags = {}

for _, raw_arg in ipairs(arg) do
  local flag_name, flag_value = raw_arg:match("^%-%-(%w+)=?(.*)")
  if flag_name == nil then
    error(("Malformed flag, supported flags are --{%s}"):format(table.concat(supported_flags, ",")))
  end

  flags[flag_name] = (function()
    if flag_value == "" then return nil end
    return flag_value
  end)()

  if not vim.tbl_contains(supported_flags, flag_name) then
    error(("Unsupported flag: %s, supported flags are --{%s}"):format(flag_name, table.concat(supported_flags, ",")))
  end
end

if flags["help"] then
  io.write(table.concat({
    "Usage: cat_dir --dir=<path> [options]",
    "",
    "Options:",
    "  --dir=<path>          Directory to recursively concatenate (required)",
    "  --excl=<p1,p2,...>    Comma-separated Lua patterns to exclude",
    "  --sep=<format>        Separator format (default: 'FILE: %s')",
    "  --help                Show this message",
    "",
  }, "\n"))
  os.exit(0)
end

if flags["dir"] == nil then
  error("Missing required flag --dir")
end

local abs_dir = vim.fs.normalize(vim.fs.abspath(flags["dir"]))
if vim.uv.fs_stat(abs_dir) == nil then
  error("Invalid dir: " .. abs_dir)
end

local sep = flags["sep"] or "FILE: %s"
local excl_tbl = (function()
  if flags["excl"] == nil then return {} end
  return vim.split(flags['excl'], ",")
end)()

local accumed_files = {}

local accum_string
--- @param dir string
accum_string = function(dir)
  for name, type in vim.fs.dir(dir) do
    local matches_excl_pattern = vim.iter(excl_tbl):any(function(excl_pattern)
      return name:find(excl_pattern) ~= nil
    end)

    if matches_excl_pattern then
      goto continue
    end

    local path = vim.fs.joinpath(dir, name)
    if type == "file" then
      local content = table.concat(
        vim.fn.readfile(path
        ), "\n")
      table.insert(accumed_files, sep:format(path))
      table.insert(accumed_files, content)
    elseif type == "directory" then
      accum_string(path)
    end

    ::continue::
  end
end

accum_string(abs_dir)

io.write(table.concat(accumed_files, "\n"))
