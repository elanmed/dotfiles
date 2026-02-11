-- TODO: excl
local supported_flags = { "excl", "dir", "sep" }

local flags = {}

for _, raw_arg in ipairs(arg) do
  local flag_name, flag_value = raw_arg:match("^%-%-(%w+)=?(.*)")
  if flag_name == nil then
    error(("Malformed flag, supported flags are --{%s}"):format(table.concat(supported_flags, ",")))
  end

  flags[flag_name] = flag_value

  if not vim.tbl_contains(supported_flags, flag_name) then
    error(("Unsupported flag: %s, supported flags are --{%s}"):format(flag_name, table.concat(supported_flags, ",")))
  end
end

if flags["dir"] == nil then
  error("Missing required flag --dir")
end

local abs_dir = vim.fs.abspath(vim.fs.normalize(flags["dir"]))
if vim.uv.fs_stat(abs_dir) == nil then
  error("Invalid dir: " .. abs_dir)
end

local sep = flags["sep"] or "FILE: %s"

local accumed_string = ""

local accum_string
--- @param dir string
accum_string = function(dir)
  for name, type in vim.fs.dir(dir) do
    local path = vim.fs.joinpath(dir, name)
    if type == "file" then
      local content = table.concat(
        vim.fn.readfile(path
        ), "\n")
      accumed_string =
          accumed_string ..
          "\n" ..
          (sep):format(path) ..
          "\n" ..
          content
    elseif type == "directory" then
      accum_string(path)
    end
  end
end

accum_string(abs_dir)

io.write(("Accumulated content is %s characters. Print to stdout [Y/n]? "):format(#accumed_string))
local confirm_input = io.read()
if confirm_input == 'Y' then
  io.write(accumed_string)
else
  io.write("Aborting\n")
end
