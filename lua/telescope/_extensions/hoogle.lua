local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local previewers = require('telescope.previewers')
local conf = require('telescope.config').values
local Job = require('plenary.job')
local json = require('json')
local a = require('plenary.async_lib')
local entry_display = require('telescope.pickers.entry_display')
local async, await = a.async, a.await
local flatten = vim.tbl_flatten

function trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local B = {}

B.search = function(opts)
  opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()
  local displayer = entry_display.create {
    separator = "▏",
    items = {
      { width = 8 },
      { remaining = true }
    }
  }

  local maker = function(deets)
    deets.valid   = true
    deets.display = function(entry) 
      return displayer {
        entry["package"]["name"],
        entry["item"],
      }
    end
    deets.value   = deets["item"]
    deets.ordinal = deets["item"]
    return deets
  end

  local hoogle_finder = async(function(prompt)
    -- Wait for 2 characters to search
    if string.len(trim(prompt)) < 2 then
      return {}
    end

    local job = Job:new {
        command = 'hoogle',
        -- Important to specify j to return JSON
        args = {'search', '-j', prompt},
      }

    local lines = job:sync()
    local parsed_results = json.decode(table.concat(lines, "\n"))
    -- TODO Reverse this?
    return parsed_results
  end)

  local w3m_preview = previewers.new_termopen_previewer {
    get_command = function(entry, status)
      return { 'w3m', entry['url'] }
    end
  }

  pickers.new(opts, {
    prompt_title = 'Hoogle',
    finder = finders.new_dynamic {
      entry_maker = maker,
      fn = hoogle_finder,
    },
    previewer = w3m_preview,
    sorter = conf.generic_sorter(opts),
  }):find()
end

return require('telescope').register_extension {
    exports= {
      search = B.search
    },
}
